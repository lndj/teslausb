<template>
  <v-container>
    <v-row class="text-center">
      <v-col cols="12">
        <v-img
          :src="require('../assets/tesla-logo.jpg')"
          class="my-3"
          contain
          height="200"
        />
      </v-col>

      <v-col class="mb-4">
        <h1 class="display-2 font-weight-bold mb-3">感谢使用 TeslaUSB</h1>

        <p class="subheading font-weight-regular">
          本项目基于开源项目二次开发，感谢社区的力量。
          <br />项目的起源可以参考此处
          <a
            href="https://www.reddit.com/r/teslamotors/comments/9m9gyk/build_a_smart_usb_drive_for_your_tesla_dash_cam/"
            target="_blank"
            >Reddit Community</a
          >
        </p>
      </v-col>

      <v-col class="mb-4" cols="12" style="margin-top: 40px">
        <p class="text-h6 font-weight-regular">
          当前版本：
          <strong v-if="currentVersion">
            {{ currentVersion }}
          </strong>
          <span class="text-caption" v-if="currentVersionLoading">
            获取中...
          </span>
          <span class="text-caption" style="color: red" v-if="!currentVersion && !currentVersionLoading">
            获取出错
          </span>
          <v-tooltip bottom>
            <template v-slot:activator="{ on, attrs }">
              <v-btn
                v-bind="attrs"
                v-on="on"
                @click="checkNewVersion"
                :disabled="checking"
                icon
                color="green"
              >
                <v-icon>mdi-cached</v-icon>
              </v-btn>
            </template>
            <span>点击检查新版本</span>
          </v-tooltip>
        </p>
        <p class="subheading font-weight-regular" v-if="checking">
          <v-progress-circular
            indeterminate
            :size="22"
            :width="3"
            color="primary"
          ></v-progress-circular>
          正在检查新版本...
        </p>
        <p
          class="subheading font-weight-regular"
          v-if="!checking && currentVersion && newVersion === currentVersion"
        >
          当前已是最新版本
        </p>
        <p
          class="subheading font-weight-regular"
          v-if="!checking && newVersion && newVersion !== currentVersion && !upgradeStarted"
        >
          您有新版本可升级，新版本：{{ newVersion }}
          <v-btn text color="primary" @click="confirmUpgradeDialog=true"> 点我升级 </v-btn>
        </p>
        <p
          class="subheading font-weight-regular"
          v-if="upgradeStarted"
        >
          当前已开始在后台进行升级，升级过程中，请保持电源和网络连接，待设备重启后，即为升级成功。
        </p>
      </v-col>

      <v-col class="mb-5" cols="12" style="margin-top: 50px">
        <h2 class="headline font-weight-bold mb-3">Ecosystem</h2>
        <v-row justify="center">
          <a
            v-for="(eco, i) in ecosystem"
            :key="i"
            :href="eco.href"
            class="subheading mx-3"
            target="_blank"
          >
            {{ eco.text }}
          </a>
        </v-row>
      </v-col>
    </v-row>

    <v-dialog
      v-model="confirmUpgradeDialog"
      persistent
      max-width="290"
    >
      <v-card>
        <v-card-title class="text-h5">
          确认开始升级？
        </v-card-title>
        <v-card-text>
          升级需要较长时间，具体取决于您的网络情况，请耐心等待。升级期间无法使用，请确认在安全环境下升级。
        </v-card-text>
        <v-card-actions>
          <v-spacer></v-spacer>
          <v-btn
            color="green darken-1"
            text
            @click="confirmUpgradeDialog = false"
          >
            取消
          </v-btn>
          <v-btn
            color="green darken-1"
            text
            @click="upgrade"
          >
            确认升级
          </v-btn>
        </v-card-actions>
      </v-card>
    </v-dialog>

    <v-overlay :value="upgradeProcess">
      <v-progress-circular
        indeterminate
        color="primary"
        size="64"
        :opacity="0.8"
      ></v-progress-circular>
      <div
        class="text-caption text-center"
        style="margin-top: 10px; margin-left: -10px"
      >
        升级中，请等待...
      </div>
    </v-overlay>
  </v-container>
</template>

<script>
import request from "@/utils/request";

export default {

  name: "About",

  data: () => ({
    currentVersionLoading: false,
    currentVersion: null,
    checking: false,
    upgradeProcess: false,
    upgradeStarted: false,
    newVersion: null,
    ecosystem: [
      {
        text: "Github",
        href: "https://github.com/lndj/teslausb",
      },
      {
        text: "Github forked",
        href: "https://github.com/marcone/teslausb",
      },
    ],
    confirmUpgradeDialog: false,
  }),
  mounted() {
    this.getCurrentVersion();
  },
  methods: {
    getCurrentVersion() {
      this.currentVersionLoading = true;
      request({
        url: "/cgi-bin/upgrade.sh",
        method: "get",
        params: {
          type: 1,
        },
      })
        .then((res) => {
          this.currentVersionLoading = false;
          if (res.code === 0) {
            this.currentVersion = res.data.cur_version;
          } else {
            this.$snackbar({
              content: "获取当前版本失败：" + res.msg,
              centered: true,
              color: "red",
            });
          }
        })
        .catch((err) => {
          this.currentVersionLoading = false;
          this.$snackbar({
            content: "获取当前版本出错：" + err.message,
            top: true,
            color: "red",
          });
          console.log("Current version error: ", err.message);
        });
    },
    checkNewVersion() {
      this.checking = true;
      request({
        url: "/cgi-bin/upgrade.sh",
        method: "get",
        params: {
          type: 2,
        },
      })
        .then((res) => {
          this.checking = false;
          if (res.code === 0) {
            this.newVersion = res.data.new_version;
          } else {
            this.$snackbar({
              content: "获取新版本失败：" + res.msg,
              centered: true,
              color: "red",
            });
          }
        })
        .catch((err) => {
          this.checking = false;
          this.$snackbar({
            content: "获取新版本出错：" + err.message,
            top: true,
            color: "red",
          });
          console.log("New version error: ", err.message);
        });
    },
    upgrade() {
      this.confirmUpgradeDialog = false;
      this.upgradeProcess = true;
      request({
        url: "/cgi-bin/upgrade.sh",
        method: "get",
        params: {
          type: 3,
        },
      })
        .then((res) => {
          this.upgradeProcess = false;
          if (res.code === 0) {
            this.upgradeStarted = true;
            this.$snackbar({
              content: '已在后台开始升级，请耐心等待',
              centered: true,
              color: "green",
            });
          } else {
            this.$snackbar({
              content: "升级失败：" + res.msg,
              centered: true,
              color: "red",
            });
          }
        })
        .catch((err) => {
          this.upgradeProcess = false;
          this.$snackbar({
            content: "升级出错：" + err.message,
            top: true,
            color: "red",
          });
          console.log("Upgrade error: ", err.message);
        });
    },
  },
};
</script>
