import { test } from '@japa/runner'
import assert from 'node:assert/strict'
import { createOrder, OrderInputError } from '#services/order_service'

// These invalid inputs must be rejected before opening a database transaction.
test.group('Order input validation', () => {
  test('rejects orders without items', async () => {
    await assert.rejects(
      () => createOrder({ customerId: 1, addressId: 1, items: [] }),
      OrderInputError
    )
  })

  test('rejects repeated products', async () => {
    await assert.rejects(
      () =>
        createOrder({
          customerId: 1,
          addressId: 1,
          items: [
            { productId: 1, quantity: 1 },
            { productId: 1, quantity: 2 },
          ],
        }),
      OrderInputError
    )
  })

  test('rejects invalid quantities and IDs', async () => {
    for (const quantity of [0, -1, 1.5, Number.NaN, 4294967296]) {
      await assert.rejects(
        () =>
          createOrder({
            customerId: 1,
            addressId: 1,
            items: [{ productId: 1, quantity }],
          }),
        OrderInputError
      )
    }
    await assert.rejects(
      () => createOrder({ customerId: 0, addressId: 1, items: [{ productId: 1, quantity: 1 }] }),
      OrderInputError
    )
  })
})
