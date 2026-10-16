import { DefaultAuthProvider } from 'adminjs'
import env from '#start/env'
import componentLoader from './component_loader.js'

export default new DefaultAuthProvider({
  componentLoader,
  authenticate: async ({ email, password }) => {
    if (typeof email !== 'string' || typeof password !== 'string') return null
    if (email !== env.get('ADMIN_EMAIL') || password !== env.get('ADMIN_PASSWORD')) return null

    return { email, title: 'Адміністратор магазину' }
  },
})
