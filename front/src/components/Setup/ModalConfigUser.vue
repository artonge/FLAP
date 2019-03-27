<template>
  <div class="col-lg-8 offset-md-2">
    <div class="card">
      <div class="card-header">
        <h3 class="card-title">
          Configuration du premier utilisateur
        </h3>
        <div class="card-options">
          <a
            class="btn btn-success btn-lg"
            @click="nextRoute()"
          ><font color="white">Suivant</font></a>
        </div>
      </div>
      <div class="card-body">
        <div class="form-group">
          <p>Pour cette première étape, nous allons configurer le premier utilisateur. Cet utilisateur sera par défaut un administrateur.</p>
          <p>Vous allez devoir suivre plusieurs étapes permettant de configurer votre box Flap.</p>
        </div>
        <div class="form-group">
          <label class="form-label">Nom d'utilisateur<span class="form-required">*</span></label>
          <input
            v-model="userInfo.username"
            type="text"
            class="form-control"
            placeholder="Nom d'utilisateur"
          >
        </div>
        <div class="form-group">
          <label class="form-label">Nom complet<span class="form-required">*</span></label>
          <input
            v-model="userInfo.name"
            type="text"
            class="form-control"
            placeholder="Nom complet"
          >
        </div>
        <div class="form-group">
          <label class="form-label">Adresse mail<span class="form-required">*</span></label>
          <input
            v-model="userInfo.mail"
            type="email"
            class="form-control"
          >
        </div>
        <div class="form-group">
          <label class="form-label">Mot de passe<span class="form-required">*</span></label>
          <input
            v-model="userInfo.password"
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
      </div>
    </div>
  </div>
</template>

<script>
import router from '../../router'
export default {
  data () {
    return {
      userInfo: {
        username: '',
        name: '',
        mail: '',
        password: ''
      }
    }
  },
  methods: {
    nextRoute () {
      router.push({
        path: '/setup/2'
      })
    }
  }
}
</script>
