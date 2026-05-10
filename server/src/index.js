import express from 'express';
import session from 'express-session';
import fs from 'node:fs';
import path from 'node:path';
import { config } from './config/env.js';
import { authRouter } from './routes/auth.routes.js';
import { apiRouter } from './routes/api.routes.js';

const app = express();

if (config.trustProxy !== 'false') {
  app.set('trust proxy', config.trustProxy);
}

app.use(express.json());

app.use(
  session({
    name: config.sessionName,
    secret: config.sessionSecret,
    proxy: config.trustProxy !== 'false',
    resave: false,
    saveUninitialized: false,
    cookie: {
      httpOnly: true,
      sameSite: 'lax',
      secure: config.cookieSecure,
      maxAge: 8 * 60 * 60 * 1000,
    },
  }),
);

app.use(authRouter);
app.use('/api', apiRouter);

if (fs.existsSync(config.clientDistPath)) {
  app.use(express.static(config.clientDistPath));

  app.use((req, res) => {
    res.sendFile(path.join(config.clientDistPath, 'index.html'));
  });
} else {
  app.get('/', (req, res) => {
    res.send(`
      <h1>Jirea Local Web Server</h1>
      <p>Express is running. In prototype mode, open Vite at ${config.appPublicBaseUrl}.</p>
    `);
  });
}

app.use((error, req, res, next) => {
  console.error(error);

  res.status(500).json({
    error: 'Internal server error',
    detail: config.nodeEnv === 'development' ? error.message : undefined,
  });
});

app.listen(config.serverPort, '127.0.0.1', () => {
  console.log(`Express listening at http://127.0.0.1:${config.serverPort}`);
  console.log(`Public base URL: ${config.appPublicBaseUrl}`);
  console.log(`Gitea base URL: ${config.giteaBaseUrl}`);
});
