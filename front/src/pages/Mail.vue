<template>
  <div class="page">
    <div class="page-main">
      <Header />
      <Header2 />
      <div class="my-3 my-md-5">
        <div class="container">
          <div class="row">
            <Mail />
            <router-view />
          </div>
        </div>
      </div>
    </div>
    <Footer />
  </div>
</template>

<script>
import Mail from 'components/Mail/Index.vue'
import Header from 'components/Header/Index'
import Header2 from 'components/Header/Index2'
import Footer from 'components/Footer/Index'

export default {
  components: {
    Mail,
    Header,
    Header2,
    Footer
  }
}
</script>
