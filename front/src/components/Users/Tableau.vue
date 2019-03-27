<template>
  <div class="my-3 my-md-5">
    <div class="container">
      <div class="row row-cards row-deck">
        <div class="col-12">
          <div class="card">
            <div class="table-responsive">
              <table class="table table-hover table-outline table-vcenter text-nowrap card-table">
                <thead>
                  <tr>
                    <th>Identifiant</th>
                    <th>Adresse mail</th>
                    <th>Type utilisateur</th>
                    <th>Actions</th>
                  </tr>
                </thead>
                <tbody>
                  <tr>
                    <td>
                      <div>John Snow</div>
                    </td>
                    <td>
                      <div>
                        <input
                          type="text"
                          class="form-control"
                          value="test@test.test"
                        >
                      </div>
                    </td>
                    <td>
                      <select class="form-control custom-select">
                        <option value="">
                          Administrateur
                        </option>
                        <option value="">
                          Utilisateur
                        </option>
                      </select>
                    </td>
                    <td>
                      <div>
                        <i class="fa fa-remove btn" />
                        <i class="fa fa-edit btn" />
                      </div>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>
