import db from '@adonisjs/lucid/services/db'
import Address from '#models/address'
import Product from '#models/product'
import Order from '#models/order'
import OrderItem from '#models/order_item'

export class OrderInputError extends Error {}

type Line = { productId: number; quantity: number }
type Input = { customerId: number; addressId: number; items: Line[] }

const positiveInteger = (value: number) =>
  Number.isSafeInteger(value) && value > 0 && value <= 4294967295

export async function createOrder(input: Input) {
  if (!positiveInteger(input.customerId) || !positiveInteger(input.addressId)) {
    throw new OrderInputError('Оберіть клієнта й адресу')
  }
  if (input.items.length === 0 || input.items.length > 100) {
    throw new OrderInputError('Замовлення повинно мати від 1 до 100 позицій')
  }
  const ids = input.items.map((item) => item.productId)
  if (new Set(ids).size !== ids.length) {
    throw new OrderInputError('Товар не може повторюватись у замовленні')
  }
  if (
    input.items.some((item) => !positiveInteger(item.productId) || !positiveInteger(item.quantity))
  ) {
    throw new OrderInputError('Товар і кількість мають бути додатними цілими числами')
  }

  return db.transaction(async (trx) => {
    const address = await Address.query({ client: trx })
      .where('id', input.addressId)
      .where('customer_id', input.customerId)
      .forUpdate()
      .first()
    if (!address) throw new OrderInputError('Адреса не належить обраному клієнту')

    // Однаковий порядок блокування зменшує ризик deadlock між замовленнями.
    const products = await Product.query({ client: trx })
      .whereIn(
        'id',
        [...ids].sort((a, b) => a - b)
      )
      .orderBy('id')
      .forUpdate()

    if (products.length !== ids.length || products.some((product) => !product.is_active)) {
      throw new OrderInputError('Усі товари мають існувати й бути активними')
    }
    const byId = new Map(products.map((product) => [product.id, product]))

    const order = await Order.create(
      {
        customer_id: input.customerId,
        shipping_address_id: input.addressId,
        status: 'new',
      },
      { client: trx }
    )

    for (const item of input.items) {
      await OrderItem.create(
        {
          order_id: order.id,
          product_id: item.productId,
          quantity: item.quantity,
          unit_price: byId.get(item.productId)!.price,
        },
        { client: trx }
      )
    }
    return order
  })
}
