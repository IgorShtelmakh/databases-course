import router from '@adonisjs/core/services/router'

router.get('/', ({ response }) => response.redirect('/admin'))

const ReportsController = () => import('#controllers/reports_controller')
router.get('/reports/orders', [ReportsController, 'orders'])
