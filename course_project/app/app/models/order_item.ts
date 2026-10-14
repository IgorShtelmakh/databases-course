import { BaseModel, column, belongsTo } from '@adonisjs/lucid/orm'
import type { BelongsTo } from '@adonisjs/lucid/types/relations'
import Order from '#models/order'
import Product from '#models/product'

export default class OrderItem extends BaseModel {
  static table = 'order_items'

  @column({ isPrimary: true })
  declare id: number

  @column({ serializeAs: 'order_id' })
  declare order_id: number

  @column({ serializeAs: 'product_id' })
  declare product_id: number

  @column()
  declare quantity: number

  @column({ serializeAs: 'unit_price' })
  declare unit_price: string

  @belongsTo(() => Order, { foreignKey: 'order_id' })
  declare order: BelongsTo<typeof Order>

  @belongsTo(() => Product, { foreignKey: 'product_id' })
  declare product: BelongsTo<typeof Product>
}
