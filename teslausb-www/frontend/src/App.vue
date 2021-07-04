<template>
  <v-app>
    <!-- <v-navigation-drawer app permanent expand-on-hover> -->
    <v-navigation-drawer v-model="drawer" app temporary>
      <v-list-item>
        <v-list-item-content>
          <v-list-item-title class="text-h6"> Tesla USB </v-list-item-title>
          <v-list-item-subtitle>
            The smartest storage for your Tesla
          </v-list-item-subtitle>
        </v-list-item-content>
      </v-list-item>

      <v-divider></v-divider>

      <v-list flat shaped>
        <v-list-item-group v-model="selectedItem" color="primary">
          <v-list-item
            v-for="(item, i) in items"
            :key="i"
            @click="navigate(item)"
          >
            <v-list-item-icon>
              <v-icon v-text="item.icon"></v-icon>
            </v-list-item-icon>
            <v-list-item-content>
              <v-list-item-title v-text="item.title"></v-list-item-title>
            </v-list-item-content>
          </v-list-item>
        </v-list-item-group>
      </v-list>
    </v-navigation-drawer>

    <v-app-bar app color="primary" dark>
      <v-app-bar-nav-icon @click.stop="drawer = !drawer"></v-app-bar-nav-icon>
      <v-toolbar-title>{{ currentItemTitle }}</v-toolbar-title>
      <v-spacer></v-spacer>
      <github-button
        href="https://github.com/lndj/teslausb"
        data-size="large"
        aria-label="Star lndj/teslausb on GitHub"
        >Star</github-button
      >
    </v-app-bar>

    <v-main>
      <router-view />
    </v-main>

    <v-footer app>
      <v-col class="text-center" cols="12">
        <strong>TeslaUSB</strong> By
        <a href="https://github.com/lndj" target="_blank">lndj</a>
        - {{ new Date().getFullYear() }}
      </v-col>
    </v-footer>
  </v-app>
</template>

<script>
import GithubButton from "vue-github-button";

export default {
  name: 'App',
  components: {
    GithubButton,
  },
  data: () => ({
    selectedItem: null,
    items: [
      { title: "Dashboard", icon: "mdi-view-dashboard", uri: "/" },
      { title: "Setup", icon: "mdi-application-settings", uri: "/setup" },
      { title: "About", icon: "mdi-help-box", uri: "/about" },
    ],
    right: null,
    drawer: false,
    group: null,
  }),
  computed: {
    currentItemTitle: function () {
      let tempSelectedItem = this.selectedItem;
      if(this.selectedItem === null) {
        const item = this.items.find(x => x.uri === this.$route.path);
        if(item) {
          tempSelectedItem = this.items.indexOf(item);
        }
      }
      return tempSelectedItem == null
        ? ""
        : this.items[tempSelectedItem].title;
    },
  },
  watch: {
    group() {
      this.drawer = false;
    },
  },
  methods: {
    navigate: function (item) {
      if (this.$route.path !== item.uri) {
        this.$router.push(item.uri);
      }
    },
  },
};
</script>
