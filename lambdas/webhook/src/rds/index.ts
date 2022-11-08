import { Pool, PoolConfig, QueryResult } from 'pg'
import { getParameterValue } from '../ssm'

export class RDS {
  private static rds?: RDS
  private pool: Pool
  private database: string
  private table: string
  private constructor(config: PoolConfig) {
    this.database = process.env.RDS_DATABASE || 'postgres'
    this.table = process.env.RDS_TABLE || 'github_events'
    this.pool = new Pool({
      database: this.database,
      ...config
    })
  }
  static async get(): Promise<RDS> {
    if (! this.rds) {
      const host = await getParameterValue('rds_address')
      const port = +(await getParameterValue('rds_port'))
      const user = await getParameterValue('rds_username')
      const password = await getParameterValue('rds_password')
      this.rds = new RDS({
        host,
        port,
        user,
        password
      })
    }
    return this.rds
  }
  async insert(event: string, delivery: string, organization: string, repository: string, receipt: number, payload: string): Promise<QueryResult> {
    return this.pool.query(
      `INSERT INTO ${this.table} (event, delivery, organization, repository, receipt, payload) VALUES($1, $2, $3, $4, TO_TIMESTAMP($5), $6)`,
      [event, delivery, organization, repository, receipt, payload]
    )
  }
}
