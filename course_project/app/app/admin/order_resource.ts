import { LucidResource } from '@adminjs/adonis'
import { ValidationError } from 'adminjs'
import type { ResourceWithOptions } from 'adminjs'
import Order from '#models/order'
import { createOrder, OrderInputError } from '#services/order_service'
import { Components } from './component_loader.js'

const orderResource: ResourceWithOptions = {
  resource: new LucidResource(Order, 'mysql'),
  options: {
    navigation: 'Продажі',
    listProperties: ['id', 'customer_id', 'shipping_address_id', 'status', 'created_at'],
    showProperties: ['id', 'customer_id', 'shipping_address_id', 'status', 'created_at'],
    editProperties: ['customer_id', 'shipping_address_id', 'product_id', 'quantity'],
    properties: {
      customer_id: { reference: 'customers' },
      shipping_address_id: { reference: 'addresses' },
      product_id: {
        type: 'reference',
        reference: 'products',
        isRequired: true,
        description: 'Перший товар замовлення',
        isVisible: { edit: true, filter: false, list: false, show: false },
      },
      quantity: {
        type: 'number',
        isRequired: true,
        props: { min: 1, step: 1 },
        isVisible: { edit: true, filter: false, list: false, show: false },
      },
    },
    actions: {
      report: {
        actionType: 'resource',
        icon: 'BarChart',
        component: Components.OrderReport,
        handler: async () => ({}),
      },

      new: {
        handler: async (request, _response, context) => {
          const { resource, currentAdmin, h } = context
          if (request.method !== 'post') {
            return { record: resource.build({}).toJSON(currentAdmin) }
          }
          const payload = request.payload ?? {}
          try {
            const order = await createOrder({
              customerId: Number(payload.customer_id),
              addressId: Number(payload.shipping_address_id),
              items: [
                {
                  productId: Number(payload.product_id),
                  quantity: Number(payload.quantity),
                },
              ],
            })
            const record = await resource.findOne(String(order.id))
            if (!record) throw new Error('Створене замовлення не знайдено')
            return {
              record: record.toJSON(currentAdmin),
              redirectUrl: h.recordActionUrl({
                resourceId: resource.id(),
                recordId: String(order.id),
                actionName: 'show',
              }),
              notice: { message: 'Замовлення та позицію створено', type: 'success' },
            }
          } catch (error) {
            if (error instanceof OrderInputError) {
              throw new ValidationError({ quantity: { message: error.message } })
            }
            throw error
          }
        },
      },
      edit: { isAccessible: false },
      delete: { isAccessible: false },
      bulkDelete: { isAccessible: false },
    },
  },
}

export default orderResource
