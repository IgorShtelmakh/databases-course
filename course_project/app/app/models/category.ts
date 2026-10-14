import { BaseModel, column } from '@adonisjs/lucid/orm'

export default class Category extends BaseModel {
  static table = 'categories'

  @column({ isPrimary: true })
  declare id: number

  @column()
  declare name: string
}
