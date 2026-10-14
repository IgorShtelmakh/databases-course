import type { AdminJSProviderConfig } from '@adminjs/adonis'
import { LucidResource } from '@adminjs/adonis'
import componentLoader from '../app/admin/component_loader.js'
import authProvider from '../app/admin/auth.js'
import Category from '#models/category'
import Customer from '#models/customer'
import Address from '#models/address'
import Product from '#models/product'
import orderResource from '../app/admin/order_resource.js'
import OrderItem from '#models/order_item'
import Payment from '#models/payment'

const readOnlyActions = {
  new: { isAccessible: false },
  edit: { isAccessible: false },
  delete: { isAccessible: false },
  bulkDelete: { isAccessible: false },
}

const adminjsConfig: AdminJSProviderConfig = {
  adapter: { enabled: true },
  auth: { enabled: true, provider: authProvider, middlewares: [] },
  middlewares: [],
  adminjs: {
    rootPath: '/admin',
    loginPath: '/admin/login',
    logoutPath: '/admin/logout',
    componentLoader,
    branding: { companyName: 'Навчальний магазин' },
    resources: [
      {
        resource: new LucidResource(Category, 'mysql'),
        options: {
          navigation: 'Каталог',
          properties: { name: { isTitle: true } },
          editProperties: ['name'],
        },
      },
      {
        resource: new LucidResource(Product, 'mysql'),
        options: {
          navigation: 'Каталог',
          listProperties: [
            'id',
            'sku',
            'name',
            'price',
            'stock_quantity',
            'is_active',
            'description',
          ],
          editProperties: [
            'category_id',
            'sku',
            'name',
            'price',
            'stock_quantity',
            'is_active',
            'description',
          ],
          properties: {
            name: { isTitle: true },
            description: { type: 'textarea' },
            category_id: { reference: 'categories' },
            price: { type: 'string', description: 'Додатна сума, наприклад 25000.00' },
            stock_quantity: { type: 'number', props: { min: 0, step: 1 } },
            is_active: { type: 'boolean' },
          },
        },
      },
      {
        resource: new LucidResource(Customer, 'mysql'),
        options: {
          navigation: 'Клієнти',
          editProperties: ['full_name', 'email'],
          properties: {
            full_name: { isTitle: true },
            email: { type: 'string', props: { type: 'email' } },
          },
        },
      },
      {
        resource: new LucidResource(Address, 'mysql'),
        options: {
          navigation: 'Клієнти',
          editProperties: ['customer_id', 'city', 'street', 'postal_code'],
          properties: {
            street: { isTitle: true },
            customer_id: { reference: 'customers' },
          },
        },
      },
      orderResource,
      {
        resource: new LucidResource(OrderItem, 'mysql'),
        options: {
          navigation: 'Продажі',
          actions: readOnlyActions,
          properties: {
            order_id: { reference: 'orders' },
            product_id: { reference: 'products' },
            quantity: { type: 'number' },
            unit_price: { type: 'string' },
          },
        },
      },
      {
        resource: new LucidResource(Payment, 'mysql'),
        options: {
          navigation: 'Продажі',
          editProperties: ['order_id', 'amount', 'status'],
          properties: {
            order_id: { reference: 'orders' },
            amount: { type: 'string' },
            status: {
              availableValues: [
                { value: 'pending', label: 'Очікується' },
                { value: 'successful', label: 'Успішний' },
                { value: 'failed', label: 'Невдалий' },
                { value: 'refunded', label: 'Повернення' },
              ],
            },
          },
        },
      },
    ],
  },
}

export default adminjsConfig
