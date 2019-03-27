import Vue from 'vue'
import Router from 'vue-router'

import Home from 'pages/Home'
import Login from 'pages/Login'
import Users from 'pages/Users'
import Profile from 'pages/Profile'
import Setup from 'pages/Setup'
import Modal1 from 'components/Setup/Modal1'
import Modal2 from 'components/Setup/Modal2'
import UserList from 'components/Users/Index'
import AddUser from 'components/Users/AddUser'

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
    component: Users,
    children: [
      {
        path: '/',
        component: UserList
      },
      {
        path: 'add',
        component: AddUser
      }
    ]
  },
  {
    path: '/profile',
    component: Profile
  },
  {
    path: '/setup',
    component: Setup,
    children: [
      {
        path: '/',
        component: Modal1
      },
      {
        path: '2',
        component: Modal2
      }
    ]
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
