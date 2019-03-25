<template>
  <div class="page">
    <div class="page-main">
      <Header />
      <Header2 />
      <Home />
    </div>
    <Footer />
  </div>
</template>

<script>
import Home from 'components/Home/index'
import Header from 'components/Header/index'
import Header2 from 'components/Header/index2'
import Footer from 'components/Footer/index'

export default {
  components: {
    Home,
    Header,
    Header2,
    Footer
  }
}
</script>
