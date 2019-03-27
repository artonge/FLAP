<template>
  <div class="my-3 my-md-5">
    <div class="container">
      <router-link
        to="/users"
        href="#"
        class="btn btn-gray"
      >
        Revenir
      </router-link>
    </div>
    <div class="container">
      <div class="col-6 offset-md-3 my-md-5">
        <div class="card">
          <div class="card-header">
            Création d'un utilisateur
          </div>
          <div class="card-body">
            <div class="form-group">
              <label class="form-label">Nom d'utilisateur<span class="form-required">*</span></label>
              <input
                type="text"
                class="form-control"
                placeholder="Nom d'utilisateur"
              >
            </div>
            <div class="form-group">
              <label class="form-label">Nom complet<span class="form-required">*</span></label>
              <input
                type="text"
                class="form-control"
                placeholder="Nom complet"
              >
            </div>
            <div class="form-group">
              <label class="form-label">Adresse mail<span class="form-required">*</span></label>
              <input
                type="email"
                class="form-control"
              >
            </div>
            <div class="form-group">
              <label class="form-label">Mot de passe<span class="form-required">*</span></label>
              <input
                type="password"
                class="form-control"
              >
            </div>
            <div class="form-group">
              <label class="form-label">Retapez le mot de passe<span class="form-required">*</span></label>
              <input
                type="password"
                class="form-control"
              >
            </div>
            <div class="form-group">
              <a
                class="btn btn-success"
                @click="validateUserCreation()"
              >Créer</a>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import router from '../../router'
export default {
  components: {
  },
  data () {
    return {
    }
  },
  methods: {
    validateUserCreation () {
      this.$notify({
        group: 'notif',
        type: 'success',
        duration: '3000',
        title: 'Création utilisateur',
        text: 'L\'utilisateur a bien été créé'
      })
      router.push({ path: '/users' })
    }
  }
}
</script>
