<template>
  <v-card class="mx-auto">
    <v-spacer></v-spacer>
    <v-list two-line subheader>
      <v-subheader>WiFi</v-subheader>
      <v-list-item>
        <v-list-item-content>
          <v-list-item-title>设置 WiFi 账号和密码</v-list-item-title>
          <v-list-item-subtitle>仅支持 2.4 GHz</v-list-item-subtitle>
          <v-row justify="start">
            <v-col cols="12" md="4">
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
                  type="password"
                  autocomplete="current-password"
                  label="WiFi password"
                ></v-text-field>
                <v-btn class="mr-4" type="submit" :disabled="!wifiValid">
                  保存
                </v-btn>
              </v-form>
            </v-col>
          </v-row>
        </v-list-item-content>
      </v-list-item>
    </v-list>

    <v-divider></v-divider>

    <v-list subheader two-line flat>
      <v-subheader>Cloud Sync</v-subheader>

      <v-list-item-group v-model="settings" multiple>
        <v-list-item>
          <template v-slot:default="{ active }">
            <v-list-item-action>
              <v-checkbox :input-value="active" color="primary"></v-checkbox>
            </v-list-item-action>

            <v-list-item-content>
              <v-list-item-title>Notifications</v-list-item-title>
              <v-list-item-subtitle>Allow notifications</v-list-item-subtitle>
            </v-list-item-content>
          </template>
        </v-list-item>
      </v-list-item-group>
    </v-list>
  </v-card>
</template>

<script>
import request from "@/utils/request";

export default {
  name: "Setup",
  data: () => ({
    showErrorMsg: false,
    wifiValid: null,
    ssid: "",
    ssidRules: [(v) => !!v || "WiFi ssid is required"],
    wifiPass: "",
    wifiPassRules: [(v) => !!v || "Password is required"],
    settings:{}
  }),
  created() {
    this.loadCurrentConfig();
  },
  methods: {
    submitWifi() {
      this.showErrorMsg = false;
      if (!this.$refs.wifiForm.validate()) {
        return;
      }
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
          if (res.code === 0) {
            this.$snackbar({content: 'WiFi 配置保存成功，重启后生效', centered: true, color: 'green'})
          } else {
            console.log("failed");
            this.$snackbar({content: 'WiFi 保存失败:' + res.msg, centered: true, color: "red"})
          }
        })
        .catch((err) => {
          console.log("Login error: ", err.message);
        });
    },
    loadCurrentConfig() {
      // const t = this;
      // setTimeout(() => {
      //   t.wifiPass = '1111';
      //   t.ssid = 'spaceX';
      // }, 1000)
    }
  },
};
</script>
