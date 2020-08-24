module.exports = {
  test: /\.yml$/,
  type: 'json',
  use: [{
    loader: 'yaml-loader'
  }]
}
