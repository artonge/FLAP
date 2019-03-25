import Vue from 'vue'
import router from './router'
import App from './App'

import 'tabler-ui/dist/assets/css/dashboard.css'
import './style/index.css'

/* eslint-disable-next-line no-new */
new Vue({
  el: '#app',
  router,
  render: h => h(App)
})
