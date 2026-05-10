import { TabulatorFull as Tabulator } from 'tabulator-tables';
import "tabulator-tables/dist/css/tabulator.min.css";

export async function renderGrid(container, columns, data, { apiGet, user }) {
    container.innerHTML = '';

    const gridElement = document.createElement('div');
    gridElement.id = 'nice-grid';
    container.appendChild(gridElement);

    return new Tabulator(gridElement, {
        layout: "fitColumns",
        pagination: true,
        paginationSize: 10,
        columns: columns,
        data: data
    });
}


export async function testGrid(container, { apiGet, user }) {
    const columns = [
        { title: "ID", field: "id", headerFilter: "input", headerFilterFunc: "=" },
        { title: "Name", field: "name", headerFilter: "input", headerFilterFunc: "like" },
        { title: "Value", field: "value", headerFilter: "input", headerFilterFunc: "like" }
    ];

    const data = [
        { id: 1, name: "Item 1", value: "Value 1" },
        { id: 2, name: "Item 2", value: "Value 2" },
        { id: 3, name: "Item 3", value: "Value 3" }
    ];

    return renderGrid(container, columns, data, { apiGet, user });
}
