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
              action=""
              method="post"
            >
              <div class="card-body p-6">
                <div class="card-title">
                  Connecte toi au compte
                </div>
                <div class="form-group">
                  <label class="form-label">Adresse email</label>
                  <input
                    id="exampleInputEmail1"
                    type="email"
                    class="form-control"
                    aria-describedby="emailHelp"
                    placeholder="Enter email"
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
                    type="submit"
                    class="btn btn-primary btn-block"
                    @click="autentification()"
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
  components: {
  },
  methods: {
    authentification () {
      authentification.login()
    }
  }
}
</script>
