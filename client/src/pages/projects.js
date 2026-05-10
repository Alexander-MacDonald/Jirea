import { testGrid } from  '../components/grid.js';

export async function renderProjects (container, { apiGet, user }) {
    container.innerHTML = `<h1>Loading...</h1>`;
    return testGrid(container, { apiGet, user });
}