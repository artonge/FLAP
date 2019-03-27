<template>
  <div class="page">
    <div class="page-main">
      <Header />
      <Header2 />
      <Search />
    </div>
    <Footer />
  </div>
</template>

<script>
import Search from 'components/Search/Index'
import Header from 'components/Header/Index'
import Header2 from 'components/Header/Index2'
import Footer from 'components/Footer/Index'
export default {
  components: {
    Search,
    Header,
    Header2,
    Footer
  }
}
</script>
