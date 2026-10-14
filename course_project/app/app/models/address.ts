import { BaseModel, column, belongsTo } from '@adonisjs/lucid/orm'
import type { BelongsTo } from '@adonisjs/lucid/types/relations'
import Customer from '#models/customer'

export default class Address extends BaseModel {
  static table = 'addresses'

  @column({ isPrimary: true })
  declare id: number

  @column({ serializeAs: 'customer_id' })
  declare customer_id: number

  @column()
  declare city: string

  @column()
  declare street: string

  @column({ serializeAs: 'postal_code' })
  declare postal_code: string

  @belongsTo(() => Customer, { foreignKey: 'customer_id' })
  declare customer: BelongsTo<typeof Customer>
}
