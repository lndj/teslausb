<template>
  <div>
    <!-- <v-container
      class="grey lighten-5 mb-6"
    > -->
    <filesys-state />

    <!-- </v-container> -->

  </div>
</template>

<script>
import FilesysState from "../components/FilesysState.vue";

export default {
  name: "Home",

  components: {
    FilesysState,
  },
  data: () => ({
    alignments: ["start", "center", "end"],
  }),
};
</script>
