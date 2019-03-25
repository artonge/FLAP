import Vue from 'vue'
import Router from 'vue-router'

import Home from 'pages/Home'
import Login from 'pages/Login'
import Users from 'pages/Users'
import Profile from 'pages/Profile'

Vue.use(Router)

const routes = [
  {
    path: '/',
    component: Home
  },
  {
    path: '/login',
    component: Login
  },
  {
    path: '/users',
    component: Users
  },
  {
    path: '/profile',
    component: Profile
  }
]

const router = new Router({
  routes,
  linkExactActiveClass: 'active'
})

router.afterEach((to, from) => {
  // undefined when no token
  if (localStorage.token === 'test') {
    router.push('/login')
  }
})

export default router
