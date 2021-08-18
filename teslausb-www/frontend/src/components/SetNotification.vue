<template>
  <v-list subheader two-line flat>
    <v-subheader>Notification</v-subheader>
    <v-list-item>
      <v-list-item-content>
        <v-list-item-title>设置通知</v-list-item-title>
        <v-list-item-subtitle>可选择其中一种通知方式</v-list-item-subtitle>
        <v-row justify="start">
          <v-col cols="12" md="4">
            <v-form
              v-model="notifyValid"
              ref="notifyForm"
              @submit.prevent="submitNotification"
            >
              <v-select
                :items="notifyTypes"
                v-model="notifyType"
                :rules="requiredRules"
                label="通知方式"
              ></v-select>
              <v-text-field
                v-if="notifyType == 'bark'"
                v-model="barkToken"
                :rules="requiredRules"
                label="Bark Token"
              ></v-text-field>
              <v-text-field
                v-if="notifyType == 'slack'"
                v-model="slackWebhookUrl"
                :rules="requiredRules"
                label="Slack Webhook Url"
              ></v-text-field>
              <v-text-field
                v-if="notifyType == 'pushover'"
                v-model="pushoverAppKey"
                :rules="requiredRules"
                label="Pushover App key"
              ></v-text-field>
              <v-text-field
                v-if="notifyType == 'pushover'"
                v-model="pushoverUserKey"
                :rules="requiredRules"
                label="Pushover User key"
              ></v-text-field>
              <v-text-field
                v-if="notifyType == 'webhook'"
                v-model="webhookUrl"
                :rules="requiredRules"
                label="Webhook url"
              ></v-text-field>

              <v-btn outlined class="mr-4" type="submit" :disabled="!notifyValid">
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
  name: "SetNotification",
  data: () => ({
    notifyValid: false,
    notifyType: null,
    notifyTypes: ["bark", "pushover", "slack", "webhook"],

    // bark
    barkToken: null,

    // Slack
    slackWebhookUrl: null,

    // Pushover
    pushoverUserKey: null,
    pushoverAppKey: null,

    // Webhook
    webhookUrl: null,
    requiredRules: [(v) => !!v || "This field is required"],
  }),
  mounted() {
    this.loadCurrentConfig();
  },
  methods: {
    submitNotification() {
      request({
        url: "/cgi-bin/notification.sh",
        method: "post",
        data: {
          type: this.notifyType,
          bark_token: this.barkToken,
          slack_webhook_url: this.slackWebhookUrl,
          pushover_user_key: this.pushoverUserKey,
          pushover_app_key: this.pushoverAppKey,
          webhook_url: this.webhookUrl,
          disable_other: true,
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
          console.log("Set notification error: ", err.message);
        });
    },
    loadCurrentConfig() {
      request({
        url: "/cgi-bin/configs.sh",
        method: "get",
        params: {
          type: "notification",
        },
      })
        .then((res) => {
          if (res.code === 0) {
            const notifyType = res.data.notification_types;
            if (!notifyType) {
              return;
            }
            this.notifyType = notifyType;
            this.barkToken = res.data.bark_token;
            this.slackWebhookUrl = res.data.slack_webhook_url;
            this.pushoverUserKey = res.data.pushover_user_key;
            this.pushoverAppKey = res.data.pushover_app_key;
            this.webhookUrl = res.data.webhook_url;
          } else {
            console.log("Notification configs load failed");
          }
        })
        .catch((err) => {
          console.log("Get notification configs error: ", err.message);
        });
    },
  },
};
</script>
