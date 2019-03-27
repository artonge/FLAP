<template>
  <div>
    <UserAdd />
    <Tableau />
  </div>
</template>

<script>
import UserAdd from './UsersAdd'
import Tableau from './Tableau'
export default {
  components: {
    UserAdd,
    Tableau
  },
  data () {
    return {
    }
  }
}
</script>
