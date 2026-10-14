import { BaseSchema } from '@adonisjs/lucid/schema'

export default class extends BaseSchema {
  async up() {
    this.schema.alterTable('orders', (table) => {
      table.index(['created_at'], 'orders_created_idx')
    })
  }

  async down() {
    this.schema.alterTable('orders', (table) => {
      table.dropIndex(['created_at'], 'orders_created_idx')
    })
  }
}
