<template>
  <div class="col-md-9">
    <div class="card">
      <div class="card-alert alert alert-success mb-0">
        Send
      </div>
      <div class="table-responsive">
        <table class="table card-table table-vcenter text-nowrap">
          <thead>
            <tr>
              <th class="w-1">
                Adresse mail
              </th>
              <th>Objet</th>
              <th>Date</th>
              <th>Snippet</th>
              <th>Action</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <td>toto@gmail.com</td>
              <td>Tr: Information importante</td>
              <td>10/02/2019</td>
              <td>Voici les permières informations ....</td>
              <td>
                <i
                  class="fe fe-delete"
                  @click="deleteMail()"
                />
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  methods: {
    deleteMail () {
      this.$notify({
        group: 'notif',
        type: 'error',
        duration: '3000',
        title: 'Mail',
        text: 'Suppression du mail'
      })
    }
  }
}
</script>
