import { test } from '@japa/runner'
import assert from 'node:assert/strict'
import { renderOrderReport } from '#services/order_report_view'

test('report escapes user input and customer names', () => {
  const html = renderOrderReport('"><script>alert(1)</script>', [
    { id: 1, full_name: '<img src=x onerror=alert(1)>', status: 'new', total: '2598.00' },
  ])
  assert.ok(!html.includes('<script>'))
  assert.ok(!html.includes('<img'))
  assert.ok(html.includes('&lt;script&gt;'))
  assert.ok(html.includes('&lt;img'))
  assert.ok(html.includes('2598.00'))
})

test('report shows an empty result and escapes validation errors', () => {
  const html = renderOrderReport('0', [], '<b>Invalid</b>')
  assert.ok(html.includes('За заданими умовами записів немає.'))
  assert.ok(html.includes('&lt;b&gt;Invalid&lt;/b&gt;'))
})
