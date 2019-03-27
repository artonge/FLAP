import router from '../router'

export default {
  logout () {
    localStorage.removeItem('token')
    router.push({ path: '/login' })
  },
  login () {
    router.push({ path: '/' })
  }
}
