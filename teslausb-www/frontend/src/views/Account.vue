<template>
  <v-container>
    <v-row dense>
      <v-col cols="12">
        <v-card elevation="4" outlined>
          <v-card-title class="text-h6"> 修改密码 </v-card-title>
          <v-form
            ref="form"
            v-model="valid"
            lazy-validation
            style="margin: 20px"
          >
            <v-text-field
              v-model="form.prePass"
              :rules="form.requiredRules"
              label="旧密码"
              type="password"
              required
            ></v-text-field>

            <v-text-field
              v-model="form.newPass"
              :rules="form.requiredRules"
              label="新密码"
              type="password"
              required
            ></v-text-field>

            <v-text-field
              v-model="form.confirmPassword"
              :rules="form.requiredRules.concat(passwordConfirmationRule)"
              label="新密码确认"
              type="password"
              required
            ></v-text-field>
            <v-btn
              :disabled="!valid"
              color="success"
              class="mr-4"
              @click="submit"
            >
              修改密码
            </v-btn>
          </v-form>
        </v-card>
      </v-col>
    </v-row>
  </v-container>
</template>

<script>
import request from "@/utils/request";

export default {
  name: "Account",

  components: {},
  computed: {
    passwordConfirmationRule() {
      return () =>
        this.form.newPass === this.form.confirmPassword ||
        "Password must match";
    },
  },
  data: () => ({
    valid: null,
    form: {
      requiredRules: [
        (v) => !!v || "Field is required",
        (v) =>
          (v && v.length >= 6) || "Password must be more than 6 characters",
      ],
      prePass: null,
      newPass: null,
      confirmPassword: null,
    },
  }),
  methods: {
    submit() {
      request({
        url: "/cgi-bin/password.sh",
        method: "post",
        data: {
          pre_pass: this.form.prePass,
          new_pass: this.form.newPass,
        },
      })
        .then((res) => {
          if (res.code === 0) {
            this.$snackbar({
              content: "修改密码成功",
              centered: true,
              color: "green",
            });
          }
        })
        .catch((err) => {
          this.$emit("setLoading", false);
          this.$snackbar({
            content: "修改失败：" + err.message,
            centered: true,
            color: "red",
          });
          console.log("Change passowrd error: ", err.message);
        });
    },
  },
};
</script>
