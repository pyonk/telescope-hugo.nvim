local hugo_builtin = require'telescope._extensions.hugo.builtin'

return require'telescope'.register_extension{
  exports = {
    new = hugo_builtin.new,
    list = hugo_builtin.list,
  },
}
