import dotenv from 'dotenv';
import path from 'node:path';
import { fileURLToPath } from 'node:url';

const currentFile = fileURLToPath(import.meta.url);
const currentDir = path.dirname(currentFile);
const workspaceRoot = path.resolve(currentDir, '../../..');

const envFile = process.env.ENV_FILE || '.env.prototype';

dotenv.config({
  path: path.resolve(workspaceRoot, envFile),
});

function required(name) {
  const value = process.env[name];

  if (!value || value.trim() === '') {
    throw new Error(`Missing required environment variable: ${name}`);
  }

  return value;
}

function optional(name, fallback) {
  const value = process.env[name];
  return value === undefined || value === '' ? fallback : value;
}

function booleanEnv(name, fallback) {
  const value = optional(name, String(fallback)).toLowerCase();
  return value === 'true' || value === '1' || value === 'yes';
}

function stripTrailingSlash(value) {
  return value.replace(/\/+$/, '');
}

export const config = {
  nodeEnv: optional('NODE_ENV', 'development'),
  serverPort: Number(optional('SERVER_PORT', '3001')),

  appPublicBaseUrl: stripTrailingSlash(required('APP_PUBLIC_BASE_URL')),
  giteaBaseUrl: stripTrailingSlash(required('GITEA_BASE_URL')),

  giteaClientId: required('GITEA_CLIENT_ID'),
  giteaClientSecret: required('GITEA_CLIENT_SECRET'),
  giteaScopes: optional('GITEA_SCOPES', 'openid profile email'),
  allowInsecureGiteaTls: booleanEnv('ALLOW_INSECURE_GITEA_TLS', false),

  databaseUrl: required('DATABASE_URL'),

  sessionName: optional('SESSION_NAME', 'jirea.sid'),
  sessionSecret: required('SESSION_SECRET'),

  trustProxy: optional('TRUST_PROXY', 'false'),
  cookieSecure: booleanEnv('COOKIE_SECURE', false),

  clientDistPath: path.resolve(workspaceRoot, optional('CLIENT_DIST_PATH', 'client/dist')),
};
