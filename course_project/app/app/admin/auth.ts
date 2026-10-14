import { scryptSync, timingSafeEqual } from 'node:crypto'
import { DefaultAuthProvider } from 'adminjs'
import env from '#start/env'
import componentLoader from './component_loader.js'

export default new DefaultAuthProvider({
  componentLoader,
  authenticate: async ({ email, password }) => {
    if (typeof email !== 'string' || typeof password !== 'string') return null
    if (password.length > 256) return null

    const [salt, stored] = env.get('ADMIN_PASSWORD_HASH').split(':')
    if (!/^[a-f0-9]{32}$/.test(salt ?? '') || !/^[a-f0-9]{128}$/.test(stored ?? '')) {
      throw new Error('Некоректний ADMIN_PASSWORD_HASH: запустіть скрипт генерації')
    }
    const actual = scryptSync(password, salt, 64)
    const expected = Buffer.from(stored, 'hex')
    const validPassword = timingSafeEqual(actual, expected)
    if (!validPassword || email !== env.get('ADMIN_EMAIL')) return null

    return { email, title: 'Адміністратор магазину' }
  },
})
