import { existsSync, readFileSync, writeFileSync } from 'node:fs'
import { randomBytes } from 'node:crypto'

// Prepare the local environment before starting AdonisJS.
const filename = '.env'
let contents = readFileSync(existsSync(filename) ? filename : '.env.example', 'utf8')
const key = contents.match(/^APP_KEY=(.*)$/m)?.[1]?.trim()
if (!key || key === '""' || key === "''") {
  const line = `APP_KEY=${randomBytes(32).toString('base64')}`
  contents = /^APP_KEY=.*$/m.test(contents)
    ? contents.replace(/^APP_KEY=.*$/m, line)
    : `${contents.trimEnd()}\n${line}\n`
}
writeFileSync(filename, contents, { mode: 0o600 })
console.log('.env готовий. Заповніть DB_*, ADMIN_EMAIL та ADMIN_PASSWORD у .env')
