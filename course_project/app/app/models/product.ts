import { BaseModel, column, belongsTo } from '@adonisjs/lucid/orm'
import type { BelongsTo } from '@adonisjs/lucid/types/relations'
import Category from '#models/category'

export default class Product extends BaseModel {
  static table = 'products'

  @column()
  declare description: string | null

  @column({ isPrimary: true })
  declare id: number

  @column({ serializeAs: 'category_id' })
  declare category_id: number

  @column()
  declare sku: string

  @column()
  declare name: string

  @column()
  declare price: string

  @column({ serializeAs: 'stock_quantity' })
  declare stock_quantity: number

  @column({ serializeAs: 'is_active' })
  declare is_active: boolean

  @belongsTo(() => Category, { foreignKey: 'category_id' })
  declare category: BelongsTo<typeof Category>
}
