import { BaseSchema } from '@adonisjs/lucid/schema'

export default class extends BaseSchema {
  async up() {
    this.schema.createTable('categories', (table) => {
      table.increments('id')
      table.string('name', 100).notNullable().unique()
      table.check('CHAR_LENGTH(TRIM(name)) > 0', [], 'category_name_nonempty')
    })

    this.schema.createTable('customers', (table) => {
      table.increments('id')
      table.string('full_name', 150).notNullable()
      table.string('email', 254).notNullable().unique()
      table.timestamp('created_at').notNullable().defaultTo(this.now())
      table.check('CHAR_LENGTH(TRIM(full_name)) > 0', [], 'customer_name_nonempty')
      table.check('CHAR_LENGTH(TRIM(email)) > 0', [], 'customer_email_nonempty')
    })

    this.schema.createTable('addresses', (table) => {
      table.increments('id')
      table
        .integer('customer_id')
        .unsigned()
        .notNullable()
        .references('id')
        .inTable('customers')
        .onDelete('RESTRICT')
      table.string('city', 100).notNullable()
      table.string('street', 200).notNullable()
      table.string('postal_code', 20).notNullable()
      // Ціль для складеного FK із orders.
      table.unique(['id', 'customer_id'], 'address_id_customer_unique')
    })

    this.schema.createTable('products', (table) => {
      table.increments('id')
      table
        .integer('category_id')
        .unsigned()
        .notNullable()
        .references('id')
        .inTable('categories')
        .onDelete('RESTRICT')
      table.string('sku', 40).notNullable().unique()
      table.string('name', 200).notNullable()
      table.decimal('price', 12, 2).notNullable()
      table.integer('stock_quantity').unsigned().notNullable().defaultTo(0)
      table.boolean('is_active').notNullable().defaultTo(true)
      table.check('price > 0', [], 'product_price_positive')
      table.check('CHAR_LENGTH(TRIM(sku)) > 0', [], 'product_sku_nonempty')
      table.check('CHAR_LENGTH(TRIM(name)) > 0', [], 'product_name_nonempty')
    })

    this.schema.createTable('orders', (table) => {
      table.increments('id')
      table
        .integer('customer_id')
        .unsigned()
        .notNullable()
        .references('id')
        .inTable('customers')
        .onDelete('RESTRICT')
      table.integer('shipping_address_id').unsigned().notNullable()
      table.string('status', 20).notNullable().defaultTo('new')
      table.timestamp('created_at').notNullable().defaultTo(this.now())
      table
        .foreign(['shipping_address_id', 'customer_id'], 'order_address_owner_fk')
        .references(['id', 'customer_id'])
        .inTable('addresses')
        .onDelete('RESTRICT')
        .onUpdate('RESTRICT')
      table.check(
        "status IN ('new','paid','shipped','completed','cancelled')",
        [],
        'order_status_valid'
      )
    })

    this.schema.createTable('order_items', (table) => {
      table.increments('id')
      table
        .integer('order_id')
        .unsigned()
        .notNullable()
        .references('id')
        .inTable('orders')
        .onDelete('CASCADE')
      table
        .integer('product_id')
        .unsigned()
        .notNullable()
        .references('id')
        .inTable('products')
        .onDelete('RESTRICT')
      table.integer('quantity').unsigned().notNullable()
      table.decimal('unit_price', 12, 2).notNullable()
      table.unique(['order_id', 'product_id'], 'order_product_unique')
      table.check('quantity > 0', [], 'item_quantity_positive')
      table.check('unit_price > 0', [], 'item_price_positive')
    })

    this.schema.createTable('payments', (table) => {
      table.increments('id')
      table
        .integer('order_id')
        .unsigned()
        .notNullable()
        .references('id')
        .inTable('orders')
        .onDelete('RESTRICT')
      table.decimal('amount', 12, 2).notNullable()
      table.string('status', 20).notNullable().defaultTo('pending')
      table.timestamp('created_at').notNullable().defaultTo(this.now())
      table.check('amount > 0', [], 'payment_amount_positive')
      table.check(
        "status IN ('pending','successful','failed','refunded')",
        [],
        'payment_status_valid'
      )
    })
  }

  async down() {
    this.schema.dropTable('payments')
    this.schema.dropTable('order_items')
    this.schema.dropTable('orders')
    this.schema.dropTable('products')
    this.schema.dropTable('addresses')
    this.schema.dropTable('customers')
    this.schema.dropTable('categories')
  }
}
