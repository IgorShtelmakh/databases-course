import { BaseModel, column, belongsTo } from '@adonisjs/lucid/orm'
import type { BelongsTo } from '@adonisjs/lucid/types/relations'
import { DateTime } from 'luxon'
import Customer from '#models/customer'
import Address from '#models/address'

export default class Order extends BaseModel {
  static table = 'orders'

  @column({ isPrimary: true })
  declare id: number

  @column({ serializeAs: 'customer_id' })
  declare customer_id: number

  @column({ serializeAs: 'shipping_address_id' })
  declare shipping_address_id: number

  @column()
  declare status: 'new' | 'paid' | 'shipped' | 'completed' | 'cancelled'

  @column.dateTime({ autoCreate: true, serializeAs: 'created_at' })
  declare created_at: DateTime

  @belongsTo(() => Customer, { foreignKey: 'customer_id' })
  declare customer: BelongsTo<typeof Customer>

  @belongsTo(() => Address, { foreignKey: 'shipping_address_id' })
  declare shipping_address: BelongsTo<typeof Address>
}
