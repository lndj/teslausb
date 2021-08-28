<template>
  <v-card class="mx-auto">
    <v-spacer></v-spacer>
    
    <set-wifi @setLoading="setLoading"></set-wifi>

    <v-divider></v-divider>

    <set-rclone></set-rclone>

    <v-divider></v-divider>

    <set-notification />

    <v-divider></v-divider>
    
    <!-- <set-ap /> -->

    <v-overlay :value="loading">
      <v-progress-circular
        indeterminate
        color="primary"
        size="64"
      ></v-progress-circular>
      <div class="text-caption">正在保存中...</div>
    </v-overlay>

    <reboot></reboot>
    <br><br><br><br>
  </v-card>
</template>

<script>
// import request from "@/utils/request";
import Reboot from '../components/Reboot.vue';
import SetNotification from '../components/SetNotification.vue';
import SetWifi from '../components/SetWifi.vue';
import SetRclone from '../components/SetRclone.vue';
// import SetAp from '../components/SetAp.vue';

export default {
  name: "Setup",
  components: {
    Reboot,
    SetNotification,
    SetWifi,
    SetRclone,
    // SetAp,
  },
  data: () => ({
    loading: false,
  }),
  mounted() {
    
  },
  methods: {
    setLoading(status) {
      this.loading = status;
    }
  },
};
</script>
<style>
.custom-loader {
  animation: loader 1s infinite;
  display: flex;
}
@-moz-keyframes loader {
  from {
    transform: rotate(0);
  }
  to {
    transform: rotate(360deg);
  }
}
@-webkit-keyframes loader {
  from {
    transform: rotate(0);
  }
  to {
    transform: rotate(360deg);
  }
}
@-o-keyframes loader {
  from {
    transform: rotate(0);
  }
  to {
    transform: rotate(360deg);
  }
}
@keyframes loader {
  from {
    transform: rotate(0);
  }
  to {
    transform: rotate(360deg);
  }
}
</style>
