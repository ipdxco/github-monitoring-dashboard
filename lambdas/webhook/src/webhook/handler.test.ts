import { Webhooks } from '@octokit/webhooks';
import { mocked } from 'jest-mock';
import nock from 'nock';

import workflowjob_event from '../../test/resources/github_workflowjob_event.json';
import { getParameterValue } from '../ssm';
import { handle } from './handler';
import { RDS } from '../rds';

jest.mock('../ssm');
jest.mock('../rds');

const GITHUB_APP_WEBHOOK_SECRET = 'TEST_SECRET';

const secret = 'TEST_SECRET';
const webhooks = new Webhooks({
  secret: secret,
});

describe('handler', () => {
  let originalError: Console['error'];

  beforeEach(async () => {
    nock.disableNetConnect();
    process.env.ORGANIZATION_ALLOW_LIST = '["philips-labs"]';
    originalError = console.error;
    console.error = jest.fn();
    jest.clearAllMocks();
    jest.resetAllMocks();

    const mockedGetParameterValue = mocked(getParameterValue);
    mockedGetParameterValue.mockResolvedValueOnce(GITHUB_APP_WEBHOOK_SECRET);

    const mockedRds = mocked(RDS);
    const mockedInsert = jest.fn();
    mockedInsert.mockResolvedValue({rowCount: 1})
    mockedRds.get.mockResolvedValueOnce({
      insert: mockedInsert
    } as unknown as RDS)
  });

  afterEach(() => {
    console.error = originalError;
  });

  it('returns 500 if no signature available', async () => {
    const resp = await handle({}, '', 0);
    expect(resp.statusCode).toBe(500);
  });

  it('returns 401 if signature is invalid', async () => {
    const resp = await handle({ 'X-Hub-Signature': 'bbb' }, 'aaaa', 0);
    expect(resp.statusCode).toBe(401);
  });

  describe('Test for workflowjob event: ', () => {
    it('handles workflow job events', async () => {
      const event = JSON.stringify(workflowjob_event);
      const resp = await handle(
        { 'X-Hub-Signature': await webhooks.sign(event), 'X-GitHub-Event': 'workflow_job', 'X-GitHub-Organization': 'philips-labs' },
        event,
        0,
      );
      expect(resp.statusCode).toBe(201);
    });

    it('handles workflow job events with 256 hash signature', async () => {
      const event = JSON.stringify(workflowjob_event);
      const resp = await handle(
        { 'X-Hub-Signature-256': await webhooks.sign(event), 'X-GitHub-Event': 'workflow_job', 'X-GitHub-Organization': 'philips-labs' },
        event,
        0,
      );
      expect(resp.statusCode).toBe(201);
    });

    it('does not handle workflow_job events from unlisted organizations', async () => {
      const event = JSON.stringify(workflowjob_event);
      process.env.ORGANIZATION_ALLOW_LIST = '[]';
      const resp = await handle(
        { 'X-Hub-Signature': await webhooks.sign(event), 'X-GitHub-Event': 'workflow_job', 'X-GitHub-Organization': 'philips-labs' },
        event,
        0,
      );
      expect(resp.statusCode).toBe(403);
    });
  });
});
