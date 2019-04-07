import router from '../router'
import axios from 'axios'

export default {
  logout () {
    localStorage.removeItem('token')
    router.push({ path: '/login' })
  },
  login (username, password) {
    axios.post(`https://flap.localhost/login`, { username: username, password: password }).then(response => {
      console.log(response)
      router.push({ path: '/' })
    }).catch(e => {
      console.log(e)
    })
    router.push({ path: '/login' })
  }
}
