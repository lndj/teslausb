module.exports = {
  transpileDependencies: [
    'vuetify'
  ],

  assetsDir: 'static',
  publicPath: './',

  devServer: {
    proxy: {
      '/cgi-bin': {
        target: 'http://localhost:8090',
        ws: true,
        changeOrigin: true,
        secure: false
      }
    }
  }
}
