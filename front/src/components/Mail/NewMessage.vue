<template>
  <div class="col-md-9">
    <div class="card">
      <div class="card-header">
        <h3 class="card-title">
          Compose new message
        </h3>
      </div>
      <div class="card-body">
        <form action="">
          <div class="form-group">
            <div class="row align-items-center">
              <label class="col-sm-2">To:</label>
              <div class="col-sm-10">
                <input
                  type="text"
                  class="form-control"
                >
              </div>
            </div>
          </div>
          <div class="form-group">
            <div class="row align-items-center">
              <label class="col-sm-2">Subject:</label>
              <div class="col-sm-10">
                <input
                  type="text"
                  class="form-control"
                >
              </div>
            </div>
          </div>
          <textarea
            rows="10"
            class="form-control"
          />
          <div class="btn-list mt-4 text-right">
            <button
              type="button"
              class="btn btn-secondary btn-space"
              @click="cancel()"
            >
              Cancel
            </button>
            <button
              type="submit"
              class="btn btn-primary btn-space"
              @click="send()"
            >
              Send message
            </button>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
import router from '../../router'
export default {
  methods: {
    cancel () {
      router.push({ path: '/mail' })
    },
    send () {
      this.$notify({
        group: 'notif',
        type: 'success',
        duration: '3000',
        title: 'Mail',
        text: 'Le mail a été envoyé'
      })
      router.push({ path: '/mail' })
    }
  }
}
</script>
