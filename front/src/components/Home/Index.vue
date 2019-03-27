<template>
  <div class="my-3 my-md-5">
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
      ]
    }
  }
}
</script>
