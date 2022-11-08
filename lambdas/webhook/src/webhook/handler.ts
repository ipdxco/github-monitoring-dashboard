import { Webhooks } from '@octokit/webhooks';
import { IncomingHttpHeaders } from 'http';

import { Response } from '../lambda';
import { RDS } from '../rds';
import { getParameterValue } from '../ssm';
import { LogFields, logger as rootLogger } from './logger';

const logger = rootLogger.getChildLogger();

export async function handle(headers: IncomingHttpHeaders, body: string, timestamp: number): Promise<Response> {
  // ensure header keys lower case since github headers can contain capitals.
  for (const key in headers) {
    headers[key.toLowerCase()] = headers[key];
  }

  const event = headers['x-github-event'] as string;
  const delivery = headers['x-github-delivery'] as string;
  const organization = headers['x-github-organization'] as string;
  const repository = headers['x-github-repository'] as string;
  const receipt = timestamp / 1000;

  LogFields.fields.event = event;
  LogFields.fields.delivery = delivery;
  LogFields.fields.organization = organization;
  LogFields.fields.repository = repository;

  logger.info(`Processing Github event`, LogFields.print());

  let response: Response = await verifySignature(headers, body);

  if (response.statusCode != 200) {
    return response;
  }

  response = await verifyOrganization(headers, body);

  if (response.statusCode != 200) {
    return response;
  }

  const rds = await RDS.get()
  const insert = await rds.insert(event, delivery, organization, repository, receipt, body)

  if (insert.rowCount != 1) {
    return {
      statusCode: 500,
      body: JSON.stringify({
        statusMessage: "Failed to insert the event into the database."
      })
    }
  }

  return {
    statusCode: 201
  };
}

async function verifyOrganization(headers: IncomingHttpHeaders, body: string): Promise<Response> {
  const organizationAllowListEnv = process.env.ORGANIZATION_ALLOW_LIST || '[]';
  const organizationAllowList = JSON.parse(organizationAllowListEnv) as Array<string>;

  const organization = headers['x-github-organization'] as string;

  if (!organization) {
    return {
      statusCode: 500,
      body: JSON.stringify({
        statusMessage: "Github event doesn't have organization. This webhook requires an organization header to be configured."
      })
    }
  }

  if (! organizationAllowList.includes(organization)) {
    return {
      statusCode: 403,
      body: JSON.stringify({
        statusMessage: `Received event from unauthorized organization ${organization}`
      })
    }
  }

  return {
    statusCode: 200
  }
}

async function verifySignature(headers: IncomingHttpHeaders, body: string): Promise<Response> {
  let signature;
  if ('x-hub-signature-256' in headers) {
    signature = headers['x-hub-signature-256'] as string;
  } else {
    signature = headers['x-hub-signature'] as string;
  }
  if (!signature) {
    return {
      statusCode: 500,
      body: JSON.stringify({
        statusMessage: "Github event doesn't have signature. This webhook requires a secret to be configured."
      })
    }
  }

  const secret = await getParameterValue('github_app_webhook_secret');

  const webhooks = new Webhooks({
    secret: secret,
  });
  if (!(await webhooks.verify(body, signature))) {
    return {
      statusCode: 401,
      body: JSON.stringify({
        statusMessage: "Unable to verify signature!"
      })
    }
  }
  return {
    statusCode: 200
  }
}
