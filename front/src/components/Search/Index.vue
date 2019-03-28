<template>
  <div class="my-3 my-md-5">
    <div class="container">
      <div class="page-header">
        <h1 class="page-title">
          Recherche sur Internet
        </h1>
      </div>
    </div>
    <div class="container">
      <div class="row">
        <div class="form-group col-3">
          <label class="form-label">Choix du moteur de recherche</label>
          <select
            v-model="searchEngine"
            class="form-control-lg custom-select"
          >
            <option value="qwant">
              Qwant
            </option>
            <option value="duckduck">
              DuckDuck Go
            </option>
            <option value="google">
              Google
            </option>
          </select>
        </div>
        <div class="form-group col-3">
          <label class="form-label">La catégorie</label>
          <select
            v-model="category"
            class="form-control-lg custom-select"
          >
            <option value="web">
              Web
            </option>
          </select>
        </div>
      </div>
    </div>
    <div class="container">
      <div class="form-group">
        <div class="input-icon mb-3">
          <input
            v-on:keyup.enter="openBrowser()"
            v-model="search"
            type="text"
            class="form-control"
            placeholder="Recherche..."
          >
          <span class="input-icon-addon">
            <i class="fe fe-search" />
          </span>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  components: {
  },
  data () {
    return {
      search: '',
      searchEngine: 'qwant',
      category: 'web'
    }
  },
  methods: {
    openBrowser () {
      if (this.searchEngine === 'qwant') {
        window.open(`https://www.qwant.com/?q=${this.search}&t=web`, '_blank')
      }
      if (this.searchEngine === 'duckduck') {
        window.open(`https://duckduckgo.com/?q=${this.search}&t=h_&ia=web`, '_blank')
      }
      if (this.searchEngine === 'google') {
        window.open(`https://www.google.com/search?q=${this.search}`, '_blank')
      }
    }
  }
}
</script>
