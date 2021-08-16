<template>
  <div>
    <!-- <v-container
      class="grey lighten-5 mb-6"
    > -->
    <latest-sync-log />

    <!-- </v-container> -->
    <!-- <hello-world /> -->
    
  </div>
</template>

<script>
  // import HelloWorld from '../components/HelloWorld'
  import LatestSyncLog from '../components/LatestSyncLog'

  export default {
    name: 'Home',

    components: {
      // HelloWorld,
      LatestSyncLog,
    },
    data: () => ({
      alignments: [
        'start',
        'center',
        'end',
      ],
    }),
  }
</script>
