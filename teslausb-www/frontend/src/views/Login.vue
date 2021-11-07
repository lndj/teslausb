<template>
  <v-form v-model="valid" ref="loginForm">
    <v-card class="mx-auto my-12" max-width="374">
      <v-img
        height="250"
        src="https://cdn.vuetifyjs.com/images/cards/cooking.png"
      ></v-img>

      <v-card-title>Login</v-card-title>
      <!-- <v-divider class="mx-4"></v-divider> -->
      <v-card-text>
        <v-row>
          <v-col cols="12" md="12">
            <v-text-field
              v-model="username"
              autocomplete="username"
              :rules="nameRules"
              label="User Name"
              required
            ></v-text-field>
          </v-col>
          <v-col cols="12" md="12">
            <v-text-field
              type="password"
              autocomplete="current-password"
              v-model="password"
              :rules="passwordRules"
              label="Password"
              required
            ></v-text-field>
          </v-col>
        </v-row>
      </v-card-text>

      <v-alert
        dense
        type="error"
        v-if="showErrorMsg"
        style="margin-right: 15px; margin-left: 15px; margin-top: -10px"
      >
        {{ errorMsg }}
      </v-alert>

      <v-card-actions>
        <v-btn color="deep-purple lighten-2" text @click.prevent="submit">
          Login
        </v-btn>
      </v-card-actions>
    </v-card>
  </v-form>
</template>

<script>
import request from "@/utils/request";
import Cookies from "js-cookie";

export default {
  name: "Login",

  data: () => ({
    valid: false,
    username: "",
    nameRules: [(v) => !!v || "username is required"],
    password: "",
    passwordRules: [(v) => !!v || "Password is required"],
    showErrorMsg: false,
    errorMsg: null,
  }),
  methods: {
    submit() {
      this.showErrorMsg = false;
      if (!this.$refs.loginForm.validate()) {
        return;
      }
      const formData = {
        username: this.username,
        password: this.password,
      };
      request({
        url: "/cgi-bin/login.sh",
        method: "post",
        data: formData,
      })
        .then((res) => {
          if (res.code === 0) {
            Cookies.set("X-Token", res.data.token, 1);
            this.$router.push("/");
          } else {
            console.log(res.msg)
            console.log(res)
            this.showErrorAlert(res.msg);
          }
        })
        .catch((err) => {
          this.$snackbar({content: '登陆失败：' + err.message, centered: true, color: 'red'})
          console.log("Login error: ", err.message);
        });
    },
    showErrorAlert(msg) {
      this.showErrorMsg = true;
      this.errorMsg = msg;
      const that = this;
      setTimeout(() => {
        that.showErrorMsg = false;
      }, 2000);
    },
  },
};
</script>
