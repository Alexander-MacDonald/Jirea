import { config } from '../config/env.js';

if (config.allowInsecureGiteaTls) {
  process.env.NODE_TLS_REJECT_UNAUTHORIZED = '0';
}

export function getRedirectUri() {
  return `${config.appPublicBaseUrl}/auth/gitea/callback`;
}

export function buildAuthorizeUrl(state) {
  const url = new URL('/login/oauth/authorize', config.giteaBaseUrl);

  url.searchParams.set('client_id', config.giteaClientId);
  url.searchParams.set('redirect_uri', getRedirectUri());
  url.searchParams.set('response_type', 'code');
  url.searchParams.set('scope', config.giteaScopes);
  url.searchParams.set('state', state);

  return url.toString();
}

export async function exchangeCodeForToken(code) {
  const tokenUrl = new URL('/login/oauth/access_token', config.giteaBaseUrl);

  const body = new URLSearchParams({
    client_id: config.giteaClientId,
    client_secret: config.giteaClientSecret,
    code,
    grant_type: 'authorization_code',
    redirect_uri: getRedirectUri(),
  });

  const response = await fetch(tokenUrl, {
    method: 'POST',
    headers: {
      Accept: 'application/json',
      'Content-Type': 'application/x-www-form-urlencoded',
    },
    body,
  });

  const data = await response.json().catch(() => null);

  if (!response.ok) {
    throw new Error(`Gitea token exchange failed: ${JSON.stringify(data)}`);
  }

  return data;
}

export async function getGiteaUserInfo(accessToken) {
  const userInfoUrl = new URL('/login/oauth/userinfo', config.giteaBaseUrl);

  const response = await fetch(userInfoUrl, {
    method: 'GET',
    headers: {
      Accept: 'application/json',
      Authorization: `Bearer ${accessToken}`,
    },
  });

  const data = await response.json().catch(() => null);

  if (!response.ok) {
    throw new Error(`Gitea userinfo request failed: ${JSON.stringify(data)}`);
  }

  return data;
}
