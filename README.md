# telescope-hugo.nvim
`telescope-hugo.nvim` is an extension for [telescope.nvim](https://github.com/nvim-telescope/telescope.nvim) that provides operating [hugo](https://gohugo.io/).


## Installation
Add these following plugins.

```
'nvim-telescope/telescope.nvim'
'pyonk/telescope-hugo.nvim'
```

## External Dependancies
### Required
- [hugo](https://github.com/gohugoio/hugo)

### Optional
- [bat](https://github.com/sharkdp/bat)

## Usage
### list
```
:Telescope hugo list [options]
```
#### options
- source
```
:Telescope hugo list source=YOUR_SITE_DIR
```
- preview_cmd
```
:Telescope hugo list preview_cmd=glow
```

### new
```
:Telescope hugo new [options]
```
#### options
- source
```
:Telescope hugo new source=YOUR_SITE_DIR
```
- content_dir
```
:Telescope hugo list content_dir=posts
```


## TODO
- [x] `hugo new`
- [ ] `hugo grep`

etc...
