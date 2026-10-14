import type { HttpContext } from '@adonisjs/core/http'
import db from '@adonisjs/lucid/services/db'
import { renderOrderReport } from '#services/order_report_view'
import type { OrderReportRow } from '#services/order_report_view'

export default class ReportsController {
  async orders({ request, response, session }: HttpContext) {
    if (!session.get('adminUser')) return response.redirect('/admin/login')

    response.header('Cache-Control', 'no-store')
    const html = request.input('format') === 'html'
    const minTotal = String(request.input('min_total', '0'))
    if (!/^\d{1,10}(\.\d{1,2})?$/.test(minTotal)) {
      const error = 'min_total: невід’ємне число, до 2 знаків після крапки'
      if (html)
        return response
          .status(400)
          .type('html')
          .send(renderOrderReport(minTotal, [], error))
      return response.badRequest({ error })
    }

    const [rows] = await db.rawQuery(
      `
      SELECT o.id, c.full_name, o.status, o.created_at,
             SUM(oi.quantity * oi.unit_price) AS total
      FROM orders AS o
      JOIN customers AS c ON c.id = o.customer_id
      JOIN order_items AS oi ON oi.order_id = o.id
      WHERE o.status <> 'cancelled'
      GROUP BY o.id, c.full_name, o.status, o.created_at
      HAVING SUM(oi.quantity * oi.unit_price) >= CAST(? AS DECIMAL(12,2))
      ORDER BY total DESC, o.id DESC
      LIMIT 100
    `,
      [minTotal]
    )

    if (html) {
      return response.type('html').send(renderOrderReport(minTotal, rows as OrderReportRow[]))
    }
    return { min_total: minTotal, limit: 100, orders: rows }
  }
}
