<template>
  <div class="page">
    <div class="page-single">
      <div class="container">
        <div class="row">
          <div class="col col-login mx-auto">
            <div class="text-center mb-6">
              <img
                src="static/img/logo.png"
                class="h-15"
                alt=""
              >
            </div>
            <form
              class="card"
              action="#"
            >
              <div class="card-body p-6">
                <div class="card-title">
                  Connecte toi au compte
                </div>
                <div class="form-group">
                  <label class="form-label">Identifiant</label>
                  <input
                    id="exampleInputEmail1"
                    type="text"
                    class="form-control"
                    aria-describedby="emailHelp"
                    placeholder="Identifiant"
                    v-model="username"
                    required
                  >
                </div>
                <div class="form-group">
                  <label class="form-label">
                    Mot de passe
                    <a
                      href="./forgot-password.html"
                      class="float-right small"
                    >Mot de passe oublié</a>
                  </label>
                  <input
                    id="exampleInputPassword1"
                    type="password"
                    class="form-control"
                    placeholder="Mot de passe"
                    v-model="password"
                  >
                </div>
                <div class="form-group">
                  <label class="custom-control custom-checkbox">
                    <input
                      type="checkbox"
                      class="custom-control-input"
                    >
                    <span class="custom-control-label">Se souvenir de moi</span>
                  </label>
                </div>
                <div class="form-footer">
                  <button
                    class="btn btn-primary btn-block"
                    @click="authentification()"
                  >
                    Connexion
                  </button>
                </div>
              </div>
            </form>
            <div class="text-center text-muted">
              Vous n'avez pas de compte ? <a href="./register.html">S'enregistrer</a>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import authentification from '../script/authentification'
export default {
  data () {
    return {
      username: '',
      password: ''
    }
  },
  components: {
  },
  methods: {
    authentification () {
      authentification.login(this.username, this.password)
    }
  }
}
</script>
