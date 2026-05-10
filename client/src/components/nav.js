import { escapeHtml } from '../helpers.js';

export function renderNav(user) {
    return `
        <div class="topbar">
            <div id="home">
                <button id="home-button">Jirea</button>
            </div>
            <a id="app-title">Jirea</a>
            ${renderLogout(user)}
        </div>
        <div class="nav">
            <button id="home-button">Home</button>
            <button id="nav-projects">Projects</button>
            <button id="nav-commits">Commits</button>
            <button id="nav-userstories">User Stories</button>
        </div>
    `;
}

export function renderLogout(user) {
  return `<a>Signed in as ${escapeHtml(user.username || user.email || 'Gitea User')}</a><a class="logout" href="/auth/logout">Logout</a>`;
}

export function wireNav({ onHome, onProjects, onCommits, onUserStories }) {
    document.querySelectorAll('#home-button').forEach(button => {
        button.addEventListener('click', onHome);
    });

    document.querySelector('#nav-projects').addEventListener('click', onProjects);
    document.querySelector('#nav-commits').addEventListener('click', onCommits);
    document.querySelector('#nav-userstories').addEventListener('click', onUserStories);
}