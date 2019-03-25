<template>
  <div class="page">
    <div class="page-main">
      <Header />
      <Header2 />
      <UsersAdd />
      <Users />
    </div>
    <Footer />
  </div>
</template>

<script>
import Users from 'components/Users/Index'
import UsersAdd from 'components/Users/UsersAdd'
import Header from 'components/Header/index'
import Header2 from 'components/Header/index2'
import Footer from 'components/Footer/index'

export default {
  components: {
    Users,
    UsersAdd,
    Header,
    Header2,
    Footer
  }
}
</script>
