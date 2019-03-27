<template>
  <div class="page">
    <div class="page-main">
      <Header />
      <Header2 />
      <router-view></router-view>
    </div>
    <Footer />
  </div>
</template>

<script>
import Header from 'components/Header/Index'
import Header2 from 'components/Header/Index2'
import Footer from 'components/Footer/Index'

export default {
  components: {
    Header,
    Header2,
    Footer
  }
}
</script>
