<template>
  <div class="col-lg-8 offset-md-2">
    <div class="card">
      <div class="card-header">
        <h3 class="card-title">
          Configuration du nom de domaine
        </h3>
        <div class="card-options">
          <router-link
            to="/setup"
            class="btn btn-primary btn-lg"
          >
            Précédent
          </router-link>
          <a
            class="btn btn-danger btn-lg ml-2"
            @click="validate()"
          >
            <font color="white">Finish</font>
          </a>
        </div>
      </div>
      <div class="card-body">
        <div class="form-group">
          <p>Il faut maintenant configurer un nom de domaine, nous vous proposons pour le moment un seul fournisseur de nom de domaine. Nous ajouterons par la suite plusieurs autres possibilités.</p>
        </div>
        <div class="form-group">
          <select
            v-model="dns"
            class="form-control custom-select"
          >
            <option value="duckdns">
              Duck Dns
            </option>
          </select>
        </div>
        <div
          v-if="dns == 'duckdns'"
          class="form-group"
        >
          <label class="form-label">Token duckdns<span class="form-required">*</span></label>
          <input
            v-if="dns == 'duckdns'"
            v-model="token"
            type="text"
            class="form-control"
            placeholder="token"
          >
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import router from '../../router'
export default {
  data () {
    return {
      dns: 'duckdns',
      token: ''
    }
  },
  created () {
  },
  methods: {
    validate () {
      router.push({ path: '/' })
    }
  }
}
</script>
