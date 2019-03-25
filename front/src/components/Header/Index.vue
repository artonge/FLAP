<template>
    <div>
        <div class="header py-4">
          <div class="container">
            <div class="d-flex">
              <a class="header-brand" href="#">
                <img src="static/img/logo.png" class="header-brand-img" alt="tabler logo">
              </a>
              <div class="d-flex order-lg-2 ml-auto">
                <div class="dropdown d-none d-md-flex">
                  <a class="nav-link icon" data-toggle="dropdown">
                    <i class="fe fe-bell"></i>
                    <span class="nav-unread"></span>
                  </a>
                  <div class="dropdown-menu dropdown-menu-right dropdown-menu-arrow">
                    <a href="#" class="dropdown-item d-flex">
                      <span class="avatar mr-3 align-self-center" style="background-image: url(demo/faces/male/41.jpg)"></span>
                      <div>
                        Notification qui dit que blabla
                        <div class="small text-muted">10 minutes ago</div>
                      </div>
                    </a>
                    <div class="dropdown-divider"></div>
                    <a href="#" class="dropdown-item text-center text-muted-dark">Mark all as read</a>
                  </div>
                </div>
                <div class="dropdown">
                  <a href="#" class="nav-link pr-0 leading-none" data-toggle="dropdown">
                    <span class="avatar" style="background-image: url()"></span>
                    <span class="ml-2 d-none d-lg-block">
                      <span class="text-default">John Snow</span>
                      <small class="text-muted d-block mt-1">Administrator</small>
                    </span>
                  </a>
                  <div class="dropdown-menu dropdown-menu-right dropdown-menu-arrow">
                    <router-link class="dropdown-item" to="/profile">
                      <i class="dropdown-icon fe fe-user"></i> Profil
                    </router-link>
                    <div class="dropdown-divider"></div>
                    <a class="dropdown-item" href="#">
                      <i class="dropdown-icon fe fe-help-circle"></i> Besoin d'aide ?
                    </a>
                    <a class="dropdown-item" v-on:click="logout">
                      <i class="dropdown-icon fe fe-log-out"></i> Déconnexion
                    </a>
                  </div>
                </div>
              </div>
              <a href="#" class="header-toggler d-lg-none ml-3 ml-lg-0" data-toggle="collapse" data-target="#headerMenuCollapse">
                <span class="header-toggler-icon"></span>
              </a>
            </div>
          </div>
        </div>
    </div>
</template>

<script>
import authentification from '../../script/authentification'
export default {
  methods: {
    logout () {
      authentification.logout()
    }
  }
}
</script>
