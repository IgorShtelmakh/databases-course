import { ComponentLoader } from 'adminjs'

const componentLoader = new ComponentLoader()

export const Components = {
  OrderReport: componentLoader.add('OrderReport', './components/order_report.jsx'),
}

export default componentLoader
