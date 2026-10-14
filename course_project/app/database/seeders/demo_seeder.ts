import { BaseSeeder } from '@adonisjs/lucid/seeders'
import Category from '#models/category'
import Customer from '#models/customer'
import Address from '#models/address'
import Product from '#models/product'

export default class extends BaseSeeder {
  async run() {
    const category = await Category.updateOrCreate({ name: 'Ноутбуки' }, { name: 'Ноутбуки' })
    const customer = await Customer.updateOrCreate(
      { email: 'olena@example.test' },
      { full_name: 'Олена Тестова' }
    )
    await Address.updateOrCreate(
      { customer_id: customer.id, city: 'Київ', street: 'Навчальна, 1' },
      { postal_code: '01001' }
    )
    await Product.updateOrCreate(
      { sku: 'LAPTOP-001' },
      {
        category_id: category.id,
        name: 'Навчальний ноутбук',
        price: '25000.00',
        stock_quantity: 10,
        is_active: true,
      }
    )
  }
}
