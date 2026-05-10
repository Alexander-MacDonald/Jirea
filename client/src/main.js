import './style.css';
import './pages/projects.js';
import './pages/commits.js';

import { renderNav, wireNav } from './components/nav.js';
import { renderHomePage } from './pages/home.js';
import { renderProjects } from './pages/projects.js';
import { renderCommits } from './pages/commits.js';
import { renderUserStories } from './pages/userstories.js';

const app = document.querySelector('#app');
document.title = "Jirea";

async function apiGet(path) {
  const response = await fetch(path, {
    method: 'GET',
    credentials: 'include',
    headers: {
      Accept: 'application/json',
    },
  });

  if (!response.ok) {
    const errorText = await response.text();
    throw new Error(errorText || `Request failed: ${response.status}`);
  }

  return response.json();
}

function renderLogin() {
  app.innerHTML = `
    <main class="shell">
      <section class="card">
        <h1>Jirea Local Web</h1>
        <p>You must sign in with Gitea to use this application.</p>
        <a class="button" href="/auth/gitea">Sign in with Gitea</a>
      </section>
    </main>
  `;
}

function renderShell(user) {
  app.innerHTML = `
      ${renderNav(user)}
      <hr />
      <div id="page-content"></div>
  `;

  wireNav({
    onHome: () => renderPage('home', user),
    onProjects: () => renderPage('projects', user),
    onCommits: () => renderPage('commits', user),
    onUserStories: () => renderPage('userstories', user)
  });
}

async function renderPage(pageName, user) {
  const container = document.querySelector('#page-content');
  
  switch(pageName) {
    case 'home':
      await renderHomePage(container, { apiGet, user});
      break;
    case 'projects':
      await renderProjects(container, { apiGet, user });
      break;
    case 'commits':
      await renderCommits(container, { apiGet, user });
      break;
    case 'userstories':
      await renderUserStories(container, { apiGet, user });
      break;
    default:
      container.innerHTML = `<p>Page not found: ${pageName}</p>`;
      break;
  }
}

async function bootstrap() {
  try {
    const me = await apiGet('/api/me');
    const user = me.user;

    renderShell(user);
    await renderPage('home', user);
  } catch {
    renderLogin();
  }
}

bootstrap();
