<template>
  <div
    id="headerMenuCollapse"
    class="header collapse d-lg-flex p-0"
  >
    <div class="container">
      <div class="row align-items-center">
        <div class="col-lg order-lg-first">
          <ul class="nav nav-tabs border-0 flex-column flex-lg-row">
            <li class="nav-item">
              <router-link
                to="/"
                class="nav-link"
              >
                <i class="fe fe-home" /> Accueil
              </router-link>
            </li>
            <li class="nav-item">
              <router-link
                to="/users"
                class="nav-link"
              >
                <i class="fe fe-user" /> Utilisateurs
              </router-link>
            </li>
          </ul>
        </div>
      </div>
    </div>
  </div>
</template>
