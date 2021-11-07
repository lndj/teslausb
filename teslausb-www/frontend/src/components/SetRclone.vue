<template>
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
              <v-btn outlined class="mr-4" type="submit" :disabled="!rcloneValid">
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
  name: "SetRclone",
  data: () => ({
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
    submitRclone() {
      if (!this.$refs.rcloneForm.validate()) {
        return;
      }
      this.$emit('setLoading', true);
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
          this.$emit('setLoading', false);
          if (res.code === 0) {
            this.$snackbar({
              content: "Cloud Sync 配置保存成功，重启后生效",
              centered: true,
              color: "green",
            });
          } else {
            console.log("failed");
            this.$snackbar({
              content: "Cloud Sync 保存失败：" + res.msg,
              centered: true,
              color: "red",
            });
          }
        })
        .catch((err) => {
          this.$emit('setLoading', false);
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
        params: {
          type: "rclone",
        },
      })
        .then((res) => {
          if (res.code === 0) {
            if (res.data.provider) {
              this.provider = res.data.provider.trim();
            }
            if (res.data.bucket) {
              this.bucket = this.bucket = res.data.bucket.trim();
            }
            if (res.data.key_id) {
              this.keyId = res.data.key_id.trim();
            }
            if (res.data.access_key) {
              this.accessKey = res.data.access_key.trim();
            }
            if (res.data.endpoint) {
              this.endpoint = res.data.endpoint.trim();
            }
          } else {
            console.log("failed");
          }
        })
        .catch((err) => {
          this.$snackbar({
            content: "加载同步配置失败:" + err.message,
            centered: true,
            color: "red",
          });
          console.log("Get rclone config error: ", err.message);
        });
    },
  },
};
</script>
