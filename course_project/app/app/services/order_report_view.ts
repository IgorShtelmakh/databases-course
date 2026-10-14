export type OrderReportRow = {
  id: number
  full_name: string
  status: string
  total: string
}

function escapeHtml(value: unknown): string {
  return String(value).replace(
    /[&<>"']/g,
    (char) =>
      ({
        '&': '&amp;',
        '<': '&lt;',
        '>': '&gt;',
        '"': '&quot;',
        "'": '&#39;',
      })[char]!
  )
}

export function renderOrderReport(minTotal: string, rows: OrderReportRow[], error = '') {
  const body = rows.length
    ? rows
        .map(
          (row) => `<tr>
        <td>${escapeHtml(row.id)}</td>
        <td>${escapeHtml(row.full_name)}</td>
        <td>${escapeHtml(row.status)}</td>
        <td>${escapeHtml(row.total)}</td>
      </tr>`
        )
        .join('')
    : '<tr><td colspan="4">За заданими умовами записів немає.</td></tr>'

  return `<!doctype html>
<html lang="uk">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width, initial-scale=1">
  <title>Вартість замовлень</title>
  <style>
    body { font: 18px system-ui, sans-serif; max-width: 960px; margin: 32px auto; padding: 0 16px; }
    table { width: 100%; border-collapse: collapse; margin-top: 24px; }
    th, td { padding: 12px; border: 1px solid #ccc; text-align: left; }
    caption { text-align: left; margin-bottom: 12px; }
    input, button { font: inherit; padding: 8px; }
    .error { color: #a40000; }
    .table-wrap { overflow-x: auto; }
  </style>
</head>
<body>
  <a href="/admin">Керування магазином</a>
  <h1>Вартість замовлень</h1>
  <p>Сума позицій нескасованих замовлень у гривнях. Показано до 100 записів.</p>
  <form method="get" action="/reports/orders">
    <input type="hidden" name="format" value="html">
    <label for="min_total">Мінімальна вартість</label>
    <input id="min_total" name="min_total" type="number" min="0" max="9999999999.99"
      step="0.01" required value="${escapeHtml(minTotal)}">
    <button type="submit">Показати</button>
  </form>
  ${error ? `<p class="error" role="alert">${escapeHtml(error)}</p>` : ''}
  <div class="table-wrap">
    <table>
      <caption>Результат вибірки</caption>
      <thead><tr><th scope="col">Номер</th><th scope="col">Клієнт</th>
        <th scope="col">Статус</th><th scope="col">Вартість, грн</th></tr></thead>
      <tbody>${body}</tbody>
    </table>
  </div>
</body>
</html>`
}
