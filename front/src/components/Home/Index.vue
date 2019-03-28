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
        <div class="form-group col-6">
          <div class="input-icon mb-3">
            <label class="form-label">Bar de recherche</label>
            <div>
              <input
                v-model="search"
                type="text"
                class="form-control"
                placeholder="Recherche..."
                @keyup.enter="openBrowser()"
              >
              <span
                class="input-icon-addon btn"
                style="margin-top:1.6em"
                @click="openBrowser()"
              >
                <i class="fe fe-search" />
              </span>
            </div>
          </div>
        </div>
        <div class="form-group col-3">
          <label class="form-label">Choix du moteur de recherche</label>
          <select
            v-model="searchEngine"
            class="form-control custom-select"
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
            class="form-control custom-select"
          >
            <option value="web">
              Web
            </option>
          </select>
        </div>
      </div>
    </div>
    <div class="container">
      <div class="page-header">
        <h1 class="page-title">
          Dashboard
        </h1>
      </div>
      <div class="row row-cards">
        <div
          v-for="(item, index) in apps"
          :key="index"
          class="col-6 col-sm-4 col-lg-4"
        >
          <card-service :app="item" />
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import CardService from './CardService.vue'
export default {
  components: {
    'card-service': CardService
  },
  data () {
    return {
      apps: [
        {
          'name': 'Nextcloud',
          'description': 'Votre cloud privé pour stocker vos documents, photos qui vous appartiennent.',
          'img': 'here'
        },
        {
          'name': 'Sogo',
          'description': 'Vous allez pouvoir gérer tous vos calendriers',
          'img': 'here'
        }
      ],
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
