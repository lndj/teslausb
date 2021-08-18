<template>
  <v-list subheader two-line flat>
    <v-subheader>Wireless Access Point</v-subheader>
    <v-list-item>
      <v-list-item-content>
        <v-list-item-title>设置无线热点</v-list-item-title>
        <v-list-item-subtitle>注意：该热点无法接入互联网，仅用于管理</v-list-item-subtitle>
        <v-row justify="start">
          <v-col cols="12" md="8">
            <v-form
              v-model="apValid"
              ref="apForm"
              @submit.prevent="submitAp"
            >
              <v-text-field
                v-model="apSsid"
                :rules="requiredRules"
                label="Ap ssid"
              ></v-text-field>
              <v-text-field
                v-model="apPass"
                :rules="requiredRules"
                label="Ap password"
              ></v-text-field>
              <v-btn outlined class="mr-4" type="submit" :disabled="!apValid">
                保存
              </v-btn>
            </v-form>
          </v-col>
        </v-row>
      </v-list-item-content>
    </v-list-item>
  </v-list>
</template>

<script>
import request from "@/utils/request";

export default {
  name: "SetAp",
  data: () => ({
    apValid: false,
    apSsid: null,
    apPass: null,
    requiredRules: [(v) => !!v || "This field is required"],
  }),
  mounted() {
    this.loadCurrentConfig();
  },
  methods: {
    submitAp() {
      request({
        url: "/cgi-bin/ap.sh",
        method: "post",
        data: {
          ap_ssid: this.apSsid,
          ap_pass: this.apPass,
        },
      })
        .then((res) => {
          if (res.code === 0) {
            this.$snackbar({
              content: "保存成功，重启后生效",
              centered: true,
              color: "green",
            });
          }
        })
        .catch((err) => {
          this.$snackbar({
            content: "保存失败：" + err.message,
            centered: true,
            color: "red",
          });
          console.log("Set Ap error: ", err.message);
        });
    },
    loadCurrentConfig() {
      request({
        url: "/cgi-bin/configs.sh",
        method: "get",
        params: {
          type: "ap",
        },
      })
        .then((res) => {
          if (res.code === 0) {
            this.apSsid = res.data.ap_ssid;
            this.apPass = res.data.ap_pass;
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
