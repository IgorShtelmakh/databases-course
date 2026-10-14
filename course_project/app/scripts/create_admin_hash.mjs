import { readFileSync, writeFileSync } from 'node:fs'
import { randomBytes, scryptSync } from 'node:crypto'
import { createInterface } from 'node:readline/promises'

const prompt = createInterface({ input: process.stdin, output: process.stdout })
try {
  const password = await prompt.question('Новий пароль адміністратора (ввід видимий): ')
  if (password.length < 12) {
    throw new Error('Використайте пароль щонайменше з 12 символів')
  }
  const salt = randomBytes(16).toString('hex')
  const digest = scryptSync(password, salt, 64).toString('hex')
  const line = `ADMIN_PASSWORD_HASH=${salt}:${digest}`
  const current = readFileSync('.env', 'utf8')
  const next = /^ADMIN_PASSWORD_HASH=.*$/m.test(current)
    ? current.replace(/^ADMIN_PASSWORD_HASH=.*$/m, line)
    : `${current.trimEnd()}\n${line}\n`
  writeFileSync('.env', next)
  console.log('Хеш записано в .env')
} finally {
  prompt.close()
}
