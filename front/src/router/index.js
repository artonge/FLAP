import Vue from 'vue'
import Router from 'vue-router'

import Home from 'pages/Home'
import Login from 'pages/Login'
import Users from 'pages/Users'
import Profile from 'pages/Profile'
import Setup from 'pages/Setup'
import Mail from 'pages/Mail'
import Modal1 from 'components/Setup/ModalConfigUser'
import Modal2 from 'components/Setup/ModalDomain'
import UserList from 'components/Users/Index'
import AddUser from 'components/Users/AddUser'
import Inbox from 'components/Mail/Inbox'
import NewMail from 'components/Mail/NewMessage'
import ImportantMail from 'components/Mail/Important'
import SendMail from 'components/Mail/Send'
import TrashMail from 'components/Mail/Trash'

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
    path: '/mail',
    component: Mail,
    children: [
      {
        path: '/',
        component: Inbox
      },
      {
        path: 'new',
        component: NewMail
      },
      {
        path: 'send',
        component: SendMail
      },
      {
        path: 'important',
        component: ImportantMail
      },
      {
        path: 'trash',
        component: TrashMail
      }
    ]
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
        component: Modal1,
        props: true
      },
      {
        path: '2',
        component: Modal2,
        props: true
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
