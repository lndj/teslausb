<template>
  <v-dialog transition="dialog-bottom-transition" max-width="600" v-model="dialog">
    <template v-slot:default="dialog">
      <v-card>
        <v-toolbar color="primary" dark>{{ title }}</v-toolbar>
        <v-card-text>
          <div class="text-h2 pa-12">{{ content }}</div>
        </v-card-text>
        <v-card-actions class="justify-end">
          <v-btn text @click="dialog = false">Close</v-btn>
        </v-card-actions>
      </v-card>
    </template>
  </v-dialog>
</template>

<script>
export default {
  name: "Message",

  props: {
    title: String,
    content: String,
    show: Boolean
  },
  computed: {
    dialog: {
      set(newValue) {
        console.log(newValue)
      },
      get() {
        return this.show
      }
    }
  },
  data: () => ({
    
  })
};
</script>
