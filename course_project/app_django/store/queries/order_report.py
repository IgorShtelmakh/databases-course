from django.db import connection


def order_report(min_total):
    with connection.cursor() as cursor:
        cursor.execute(
            """
            SELECT o.id, c.full_name, o.status, o.created_at,
                   SUM(oi.quantity * oi.unit_price) AS total
            FROM orders AS o
            JOIN customers AS c ON c.id = o.customer_id
            JOIN order_items AS oi ON oi.order_id = o.id
            WHERE o.status <> 'cancelled'
            GROUP BY o.id, c.full_name, o.status, o.created_at
            HAVING SUM(oi.quantity * oi.unit_price) >= %s
            ORDER BY total DESC, o.id DESC
            LIMIT 100
        """,
            [min_total],
        )
        columns = [column[0] for column in cursor.description]
        return [dict(zip(columns, row)) for row in cursor.fetchall()]
