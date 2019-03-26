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
import Home from 'components/Home/Index'
import Header from 'components/Header/Index'
import Header2 from 'components/Header/Index2'
import Footer from 'components/Footer/Index'

export default {
  components: {
    Home,
    Header,
    Header2,
    Footer
  }
}
</script>
