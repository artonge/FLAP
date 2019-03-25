<template>
  <div class="page">
    <div class="page-main">
      <Header />
      <Header2 />
      <Profile />
    </div>
    <Footer />
  </div>
</template>

<script>
import Profile from 'components/Profile/index.vue'
import Header from 'components/Header/index'
import Header2 from 'components/Header/index2'
import Footer from 'components/Footer/index'

export default {
  components: {
    Profile,
    Header,
    Header2,
    Footer
  }
}
</script>
