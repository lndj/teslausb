<template>
  <v-row justify="center">
    <v-col cols="10" md="6">
      <v-btn
        block
        :loading="rebooting"
        :disabled="rebooting"
        color="error"
        @click="reboot"
      >
        <template v-slot:loader>
          <span class="custom-loader">
            <v-icon light>mdi-cached</v-icon>
          </span>
          <span>正在重启...</span>
        </template>
        重启 TeslaUSB
      </v-btn>
    </v-col>
  </v-row>
</template>

<script>
import request from "@/utils/request";

export default {
  name: "Reboot",

  data: () => ({
    rebooting: false,
    intervalId: null,
  }),
  methods: {
    reboot() {
      this.rebooting = false;
      request({
        url: "/cgi-bin/rebootv2.sh",
        method: "get",
        params: {
          action: 1,
        },
      })
        .then((res) => {
          if (res.code === 0) {
            this.rebooting = true;
            this.checkByInterval();
          }
        })
        .catch((err) => {
          this.$snackbar({
            content: "重启失败：" + err.message,
            centered: true,
            color: "red",
          });
          console.log("Reboot error: ", err.message);
        });
    },
    checkByInterval() {
      const t = this;
      this.intervalId = setInterval(() => {
        t.checkRebootStatus();
      }, 3000);
    },
    checkRebootStatus() {
      request({
        url: "/cgi-bin/rebootv2.sh",
        method: "get",
        timeout: 1000,
      })
        .then((res) => {
          if (res.code === 0) {
            this.rebooting = false;
            if (this.intervalId) {
              clearInterval(this.intervalId);
            }
            this.$snackbar({
              content: "重启成功",
              centered: true,
              color: "green",
            });
          }
        })
        .catch((err) => {
          console.log("Check reboot error: ", err.message);
        });
    },
  },
};
</script>
