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
import Header from 'components/Header/Index'
import Header2 from 'components/Header/Index2'
import Footer from 'components/Footer/Index'

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
