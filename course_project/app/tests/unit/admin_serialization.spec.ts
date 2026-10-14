import { test } from '@japa/runner'
import assert from 'node:assert/strict'
import { DateTime } from 'luxon'
import Product from '#models/product'
import Customer from '#models/customer'
import Address from '#models/address'
import Order from '#models/order'
import OrderItem from '#models/order_item'
import Payment from '#models/payment'

test('serialized fields match the property names used by AdminJS', () => {
  const cases = [
    {
      record: new Product().fill({ category_id: 1, stock_quantity: 5, is_active: true }),
      keys: ['category_id', 'stock_quantity', 'is_active'],
    },
    {
      record: new Customer().fill({ full_name: 'Тест', created_at: DateTime.utc() }),
      keys: ['full_name', 'created_at'],
    },
    {
      record: new Address().fill({ customer_id: 1, postal_code: '01001' }),
      keys: ['customer_id', 'postal_code'],
    },
    {
      record: new Order().fill({
        customer_id: 1,
        shipping_address_id: 1,
        created_at: DateTime.utc(),
      }),
      keys: ['customer_id', 'shipping_address_id', 'created_at'],
    },
    {
      record: new OrderItem().fill({ order_id: 1, product_id: 1, unit_price: '100.00' }),
      keys: ['order_id', 'product_id', 'unit_price'],
    },
    {
      record: new Payment().fill({ order_id: 1, created_at: DateTime.utc() }),
      keys: ['order_id', 'created_at'],
    },
  ]

  for (const { record, keys } of cases) {
    const serialized = record.toJSON()
    for (const key of keys)
      assert.ok(Object.hasOwn(serialized, key), `${record.constructor.name}.${key}`)
  }
})
