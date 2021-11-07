module.exports = {
  transpileDependencies: [
    'vuetify'
  ],

  assetsDir: 'static',
  publicPath: './',

  devServer: {
    proxy: {
      '/': {
        target: 'http://localhost:8090',
        changeOrigin: true,
        secure: false
      }
    }
  }
}
