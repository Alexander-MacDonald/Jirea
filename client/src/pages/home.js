export async function renderHomePage(container, { apiGet, user }) {
  container.innerHTML = `
    <section class="page page-home">
      <button id="run-query" class="button">Reload MVP SQL Query</button>
      <pre id="query-output" class="output">Loading...</pre>
    </section>
  `;

  const output = container.querySelector('#query-output');
  const runQueryButton = container.querySelector('#run-query');

  async function loadPrototypeQuery() {
    try {
      output.textContent = 'Loading...';
      const data = await apiGet('/api/prototype-test');
      output.textContent = JSON.stringify(data, null, 2);
    } catch (error) {
      output.textContent = error.message;
    }
  }

  runQueryButton.addEventListener('click', loadPrototypeQuery);

  await loadPrototypeQuery();
}