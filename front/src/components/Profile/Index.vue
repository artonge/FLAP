<template>
  <div class="my-3 my-md-5">
    <div class="container">
      <div class="page-header">
        <h1 class="page-title">
          Profil
        </h1>
      </div>
      <div class="row">
        <div class="col-lg-4">
          <div class="card">
            <div class="card-header">
              <h3 class="card-title">
                Mon profile
              </h3>
            </div>
            <div class="card-body">
              <form>
                <div class="row">
                  <div class="col-auto">
                    <span
                      class="avatar avatar-xl"
                      style="background-image: url(demo/faces/female/9.jpg)"
                    />
                  </div>
                  <div class="col">
                    <div class="form-group">
                      <label class="form-label">Utilisateur</label>
                      <input
                        class="form-control"
                        placeholder="Nom d'utilisateur"
                        value="John"
                      >
                    </div>
                  </div>
                </div>

                <div class="form-group">
                  <label class="form-label">Nom</label>
                  <input
                    class="form-control"
                    placeholder="Nom"
                    value="John Snow"
                  >
                </div>

                <div class="form-group">
                  <label class="form-label">Adresse mail</label>
                  <input
                    class="form-control"
                    placeholder="Adresse mail"
                    value="test@test.test"
                  >
                </div>

                <div class="form-group">
                  <label class="form-label">Type de compte</label>
                  <input
                    class="form-control"
                    value="Administrateur"
                    disabled
                  >
                </div>

                <div class="form-footer">
                  <button class="btn btn-primary btn-block">
                    Save
                  </button>
                </div>
              </form>
            </div>
          </div>
        </div>
        <div class="col-lg-8" />
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
    }
  }
}
</script>
