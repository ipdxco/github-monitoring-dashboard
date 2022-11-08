import { SSM } from '@aws-sdk/client-ssm';

export async function getParameterValue(name: string): Promise<string> {
  const parameter_name = `/events_observer/${name}`;
  const client = new SSM({ region: process.env.AWS_REGION as string });
  return (await client.getParameter({ Name: parameter_name, WithDecryption: true })).Parameter?.Value as string;
}
