import { Env } from '@adonisjs/core/env'

export default await Env.create(new URL('../', import.meta.url), {})
