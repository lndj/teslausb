<template>
  <v-list subheader two-line flat>
    <v-subheader>WiFi</v-subheader>
    <v-list-item>
      <v-list-item-content>
        <v-list-item-title>设置 WiFi 账号和密码</v-list-item-title>
        <v-list-item-subtitle>仅支持 2.4 GHz</v-list-item-subtitle>
        <v-row justify="start">
          <v-col cols="12" md="8">
            <v-form
              v-model="wifiValid"
              ref="wifiForm"
              @submit.prevent="submitWifi"
            >
              <v-text-field
                v-model="ssid"
                :rules="ssidRules"
                label="WiFi ssid"
              ></v-text-field>
              <v-text-field
                v-model="wifiPass"
                :rules="wifiPassRules"
                label="WiFi password"
              ></v-text-field>
              <v-btn outlined class="mr-4" type="submit" :disabled="!wifiValid">
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
  name: "SetWifi",
  data: () => ({
    loading: false,
    wifiValid: null,
    ssid: "",
    ssidRules: [(v) => !!v || "WiFi ssid is required"],
    wifiPass: "",
    wifiPassRules: [(v) => !!v || "Password is required"],
  }),
  mounted() {
    this.loadCurrentConfig();
  },
  methods: {
    submitWifi() {
      if (!this.$refs.wifiForm.validate()) {
        return;
      }
      this.$emit('setLoading', true);
      const formData = {
        ssid: this.ssid,
        wifi_pass: this.wifiPass,
      };
      request({
        url: "/cgi-bin/wifi.sh",
        method: "post",
        data: formData,
      })
        .then((res) => {
          this.$emit('setLoading', false);
          if (res.code === 0) {
            this.$snackbar({
              content: "WiFi 配置保存成功，重启后生效",
              centered: true,
              color: "green",
            });
          } else {
            console.log("failed");
            this.$snackbar({
              content: "WiFi 保存失败:" + res.msg,
              centered: true,
              color: "red",
            });
          }
        })
        .catch((err) => {
          this.$emit('setLoading', false);
          console.log("WiFi config error: ", err.message);
          this.$snackbar({
            content: "WiFi 保存失败:" + err.message,
            centered: true,
            color: "red",
          });
        });
    },
    loadCurrentConfig() {
      request({
        url: "/cgi-bin/configs.sh",
        method: "get",
        params: {
          type: "wifi",
        },
      })
        .then((res) => {
          if (res.code === 0) {
            this.ssid = res.data.ssid;
            this.wifiPass = res.data.wifi_pass;
          } else {
            console.log("Wi-Fi configs load failed");
          }
        })
        .catch((err) => {
          console.log("Get Wi-Fi configs error: ", err.message);
        });
    },
  },
};
</script>
