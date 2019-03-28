<template>
  <div class="col-md-3">
    <h3 class="page-title mb-5">
      Mail Service
    </h3>
    <div>
      <div class="list-group list-group-transparent mb-0">
        <router-link
          to="/mail"
          class="list-group-item list-group-item-action d-flex align-items-center"
        >
          <span class="icon mr-3"><i class="fe fe-inbox" /></span>Inbox <span class="ml-auto badge badge-primary">14</span>
        </router-link>
        <router-link
          to="/mail/send"
          class="list-group-item list-group-item-action d-flex align-items-center"
        >
          <span class="icon mr-3"><i class="fe fe-send" /></span>Sent Mail
        </router-link>
        <router-link
          to="/mail/important"
          class="list-group-item list-group-item-action d-flex align-items-center"
        >
          <span class="icon mr-3"><i class="fe fe-alert-circle" /></span>Important <span class="ml-auto badge badge-secondary">3</span>
        </router-link>
        <router-link
          to="/mail/trash"
          class="list-group-item list-group-item-action d-flex align-items-center"
        >
          <span class="icon mr-3"><i class="fe fe-trash-2" /></span>Trash
        </router-link>
      </div>
      <div class="mt-6">
        <router-link
          to="/mail/new"
          class="btn btn-secondary btn-block"
        >
          Ecrire un nouveau mail
        </router-link>
      </div>
    </div>
  </div>
</template>
