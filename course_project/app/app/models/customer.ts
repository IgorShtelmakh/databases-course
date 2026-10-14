import { BaseModel, column } from '@adonisjs/lucid/orm'
import { DateTime } from 'luxon'

export default class Customer extends BaseModel {
  static table = 'customers'

  @column({ isPrimary: true })
  declare id: number

  @column({ serializeAs: 'full_name' })
  declare full_name: string

  @column()
  declare email: string

  @column.dateTime({ autoCreate: true, serializeAs: 'created_at' })
  declare created_at: DateTime
}
