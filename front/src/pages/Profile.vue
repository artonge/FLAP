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
import Profile from 'components/Profile/Index.vue'
import Header from 'components/Header/Index'
import Header2 from 'components/Header/Index2'
import Footer from 'components/Footer/Index'

export default {
  components: {
    Profile,
    Header,
    Header2,
    Footer
  }
}
</script>
