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
                  type="password"
                  autocomplete="current-password"
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

    <v-divider></v-divider>

    <v-list subheader two-line flat>
      <v-subheader>Cloud Sync</v-subheader>
      <v-list-item>
        <v-list-item-content>
          <v-list-item-title>设置云端同步</v-list-item-title>
          <v-list-item-subtitle>请先申请您有云端同步账户</v-list-item-subtitle>
          <v-row justify="start">
            <v-col cols="12" md="8">
              <v-form
                v-model="rcloneValid"
                ref="rcloneForm"
                @submit.prevent="submitRclone"
              >
                <v-select
                  :items="rcloneProviders"
                  v-model="provider"
                  :rules="providerRules"
                  label="Provider"
                ></v-select>
                <v-text-field
                  v-model="bucket"
                  :rules="bucketRules"
                  label="Bucket"
                ></v-text-field>
                <v-text-field
                  v-model="keyId"
                  :rules="keyIdRules"
                  label="Key id"
                ></v-text-field>
                <v-text-field
                  v-model="accessKey"
                  :rules="accessKeyRules"
                  label="Access key"
                ></v-text-field>
                <v-text-field
                  v-model="endpoint"
                  :rules="endpointRules"
                  placeholder="oss-cn-shanghai.aliyuncs.com"
                  label="Endpoint"
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

    <v-divider></v-divider>

    <set-notification />

    <v-divider></v-divider>
    
    <set-ap />

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
import request from "@/utils/request";
import Reboot from '../components/Reboot.vue';
import SetNotification from '../components/SetNotification.vue';
import SetAp from '../components/SetAp.vue';

export default {
  name: "Setup",
  components: {
    Reboot,
    SetNotification,
    SetAp,
  },
  data: () => ({
    loading: false,

    wifiValid: null,
    ssid: "",
    ssidRules: [(v) => !!v || "WiFi ssid is required"],
    wifiPass: "",
    wifiPassRules: [(v) => !!v || "Password is required"],

    rcloneProviders: ['Alibaba'],
    provider: null,
    providerRules: [(v) => !!v || "Provider is required"],
    bucket: "",
    bucketRules: [(v) => !!v || "Bucket is required"],
    keyId: "",
    keyIdRules: [(v) => !!v || "Key id is required"],
    accessKey: "",
    accessKeyRules: [(v) => !!v || "Access key is required"],
    endpoint: "",
    endpointRules: [(v) => !!v || "Endpoint is required"],
    rcloneValid: null,
  }),
  mounted() {
    this.loadCurrentConfig();
  },
  methods: {
    submitWifi() {
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
          console.log("WiFi config error: ", err.message);
        });
    },
    submitRclone() {
      if (!this.$refs.rcloneForm.validate()) {
        return;
      }
      this.loading = true;
      const formData = {
        provider: this.provider,
        bucket: this.bucket,
        key_id: this.keyId,
        access_key: this.accessKey,
        endpoint: this.endpoint,
      };
      request({
        url: "/cgi-bin/rclone.sh",
        method: "post",
        data: formData,
      })
        .then((res) => {
          this.loading = false;
          if (res.code === 0) {
            this.$snackbar({
              content: "Cloud Sync 配置保存成功，重启后生效",
              centered: true,
              color: "green",
            });
          } else {
            console.log("failed");
            this.$snackbar({
              content: "Cloud Sync 保存失：" + res.msg,
              centered: true,
              color: "red",
            });
          }
        })
        .catch((err) => {
          this.loading = false;
          this.$snackbar({
            content: "保存 Cloud Sync 配置失败：" + err.message,
            centered: true,
            color: "red",
          });
          console.log("Cloud Sync error: ", err.message);
        });
    },
    loadCurrentConfig() {
      request({
        url: "/cgi-bin/configs.sh",
        method: "get",
      })
        .then((res) => {
          if (res.code === 0) {
            this.ssid = res.data.ssid;
            this.wifiPass = res.data.wifi_pass;

            this.provider = res.data.provider;
            this.bucket = res.data.bucket;
            this.keyId = res.data.key_id;
            this.accessKey = res.data.access_key;
            this.endpoint = res.data.endpoint;

            this.$snackbar({
              content: "配置加载成功",
              top: true,
              timeout: 1000,
              outlined: true,
              hideActions: true,
            });
          } else {
            console.log("failed");
          }
        })
        .catch((err) => {
          console.log("Get configs error: ", err.message);
        });
    },
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
