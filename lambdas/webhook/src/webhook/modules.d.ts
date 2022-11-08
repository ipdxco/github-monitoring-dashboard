declare namespace NodeJS {
  export interface ProcessEnv {
    LOG_LEVEL: 'silly' | 'trace' | 'debug' | 'info' | 'warn' | 'error' | 'fatal';
    LOG_TYPE: 'json' | 'pretty' | 'hidden';
    ORGANIZATION_ALLOW_LIST: string;
  }
}
