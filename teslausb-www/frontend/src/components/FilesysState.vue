<template>
  <v-parallax
    dark
    height="360"
    src="https://cdn.vuetifyjs.com/images/parallax/material.jpg"
  >
    <v-row align="start" justify="center">
      <v-col class="text-center top-distance" cols="12">
        <h1 class="text-h4 font-weight-thin mb-4">My Tesla USB</h1>
        <h4 class="subheading">Os: {{ os }}</h4>
        <h4 class="subheading">Hardware: {{ hardware }}</h4>
      </v-col>
    </v-row>
    <v-row align="start" justify="center">
      <v-col class="text-center" cols="6">
        <v-card class="mx-auto" shaped style="padding: 10px; opacity: 0.5">
          <v-list-item two-line>
            <v-list-item-content>
              <v-list-item-title class="text-h5">
                记录仪
              </v-list-item-title>
            </v-list-item-content>
          </v-list-item>
          <v-card-text>
            <v-row align="center">
              <v-col class="text-h2" cols="12">{{ camSize }}</v-col>
            </v-row>
          </v-card-text>
        </v-card>
      </v-col>
      <v-col class="text-center" cols="6">
        <v-card class="mx-auto" shaped style="padding: 10px; opacity: 0.5">
          <v-list-item two-line>
            <v-list-item-content>
              <v-list-item-title class="text-h5">
                音乐
              </v-list-item-title>
            </v-list-item-content>
          </v-list-item>
          <v-card-text>
            <v-row align="center">
              <v-col class="text-h2" cols="12">{{ musicSize }}</v-col>
            </v-row>
          </v-card-text>
        </v-card>
      </v-col>
    </v-row>
  </v-parallax>
</template>

<script>
import request from "@/utils/request";

export default {
  name: "FilesysState",
  computed: {},
  data: () => ({
    camSize: "",
    musicSize: "",
    os: null,
    hardware: null,
  }),
  mounted() {
    this.loadState();
  },
  methods: {
    loadState() {
      request({
        url: "/cgi-bin/dashboard.sh",
        method: "get",
      })
        .then((res) => {
          if (res.code === 0) {
            this.camSize = res.data.cam_size;
            this.musicSize = res.data.music_size;
            this.hardware = res.data.hardware;
            this.os = res.data.os;
          } else {
            console.log("Ap configs load failed");
          }
        })
        .catch((err) => {
          console.log("Get ap configs error: ", err.message);
        });
    },
  },
};
</script>

<style scoped>
.top-distance {
  margin-top: 10px;
}
</style>
