import Vue from 'vue'
import router from './router'
import App from './App'
import 'tabler-ui/dist/assets/css/dashboard.css'
import './style/index.css'
import Notifications from 'vue-notification'
Vue.use(Notifications)

/* eslint-disable-next-line no-new */
new Vue({
  el: '#app',
  router,
  render: h => h(App)
})
