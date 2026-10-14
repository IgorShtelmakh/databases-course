/* global window */
import { createElement, useEffect } from 'react'

export default function OrderReport() {
  useEffect(() => {
    // The report belongs to AdonisJS, outside the AdminJS client-side router.
    window.location.assign('/reports/orders?format=html')
  }, [])

  return createElement('a', { href: '/reports/orders?format=html' }, 'Відкрити звіт')
}
