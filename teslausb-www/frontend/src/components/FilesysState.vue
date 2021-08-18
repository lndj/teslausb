<template>
  <v-parallax
    dark
    height="300"
    src="https://cdn.vuetifyjs.com/images/parallax/material.jpg"
  >
    <v-row align="start" justify="center">
      <v-col class="text-center top-distance" cols="12">
        <h1 class="text-h4 font-weight-thin mb-4">My Tesla USB</h1>
        <h4 class="subheading">This page is building, just a demo.</h4>
        <h4 class="subheading">Current mode: Storage / Syncing</h4>
      </v-col>
    </v-row>
    <v-row align="start" justify="center">
      <v-col class="text-center" cols="6">
        <v-card class="mx-auto" shaped style="padding: 10px; opacity: 0.5">
          <v-progress-circular
            :rotate="360"
            :size="100"
            :width="15"
            :value="value"
            color="primary"
          >
            {{ value }}
          </v-progress-circular>
          <br /><br />
          <div class="text font-weight-thin mb-1">记录仪：18/60G</div>
        </v-card>
      </v-col>
      <v-col class="text-center" cols="6">
        <v-card class="mx-auto" shaped style="padding: 10px; opacity: 0.4">
          <v-progress-circular
            :rotate="360"
            :size="100"
            :width="15"
            :value="value"
            color="pink"
          >
            {{ value }}
          </v-progress-circular>
          <br /><br />
          <div class="text font-weight-thin mb-1">音乐：18/60G</div>
        </v-card>
      </v-col>
    </v-row>
  </v-parallax>
</template>

<script>
export default {
  name: "FilesysState",
  props: {},
  computed: {},
  data: () => ({
    value: 80,
  }),
};
</script>

<style scoped>
.top-distance {
  margin-top: 10px;
}
</style>
