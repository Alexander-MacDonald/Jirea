import crypto from 'node:crypto';
import express from 'express';
import {
  buildAuthorizeUrl,
  exchangeCodeForToken,
  getGiteaUserInfo,
} from '../auth/giteaOAuth.js';
import { config } from '../config/env.js';

export const authRouter = express.Router();

authRouter.get('/auth/gitea', (req, res) => {
  const state = crypto.randomBytes(32).toString('hex');

  req.session.oauthState = state;

  req.session.save((saveError) => {
    if (saveError) {
      return res.status(500).send('Failed to persist OAuth session state.');
    }

    const authorizeUrl = buildAuthorizeUrl(state);
    return res.redirect(authorizeUrl);
  });
});

authRouter.get('/auth/gitea/callback', async (req, res, next) => {
  try {
    const { code, state, error, error_description } = req.query;

    if (error) {
      return res.status(400).send(`Gitea OAuth error: ${error_description || error}`);
    }

    if (!code || !state) {
      return res.status(400).send('Missing OAuth code or state.');
    }

    if (state !== req.session.oauthState) {
      return res.status(400).send(
        `Invalid OAuth state. Open the prototype using ${config.appPublicBaseUrl} and make sure the Gitea OAuth callback URL exactly matches ${config.appPublicBaseUrl}/auth/gitea/callback.`,
      );
    }

    delete req.session.oauthState;

    const token = await exchangeCodeForToken(String(code));
    const userInfo = await getGiteaUserInfo(token.access_token);

    req.session.gitea = {
      accessToken: token.access_token,
      refreshToken: token.refresh_token,
      tokenType: token.token_type,
      expiresAt: token.expires_in
        ? Date.now() + Number(token.expires_in) * 1000
        : null,
    };

    req.session.user = {
      id: userInfo.sub || userInfo.id || userInfo.login || userInfo.username,
      username:
        userInfo.preferred_username ||
        userInfo.username ||
        userInfo.login ||
        userInfo.name,
      email: userInfo.email || null,
      raw: userInfo,
    };

    req.session.save((saveError) => {
      if (saveError) {
        return next(saveError);
      }

      return res.redirect(config.appPublicBaseUrl);
    });
  } catch (error) {
    next(error);
  }
});

authRouter.get('/auth/logout', (req, res) => {
  req.session.destroy(() => {
    res.clearCookie(config.sessionName);
    res.redirect(config.appPublicBaseUrl);
  });
});
