<template>
  <v-snackbar v-model="showSnackbar" :timeout="timeout">
    {{ text }}

    <template v-slot:action="{ attrs }">
      <v-btn color="blue" text v-bind="attrs" @click="showSnackbar = false">
        Close
      </v-btn>
    </template>
  </v-snackbar>
</template>

<script>
export default {
  name: "Message",

  props: {
    text: String,
    timeout: Number,
    show: Boolean
  },
  data: () => ({
    showSnackbar: this.show
  })
};
</script>
