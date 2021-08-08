local finders = require'telescope.finders'
local pickers = require'telescope.pickers'
local previewers = require'telescope.previewers'
local conf = require'telescope.config'.values
local entry_display = require'telescope.pickers.entry_display'
local Path = require'plenary.path'

local M = {}

local function echo(msg)
  vim.api.nvim_echo({{"[telescope-hugo] "}, {msg}}, true, {})
end

local function gen_from_hugo(opts)
  local sep = ","
  local displayer = entry_display.create{
    separator = sep,
    items = {
      -- path,slug,title,date,expiryDate,publishDate,draft,permalink
      {}, -- path
      {}, -- slug
      {}, -- title
      {}, -- date
      {}, -- expiryDate
      {}, -- publishDate
      {}, -- draft
      {}, -- permalink
    },
  }

  local function make_display(entry)
    return displayer{
      {entry.title.." ("..entry.date..")", 'TelescopeResultsIdentifier'},
    }
  end

  return function(line)
    local fields = vim.split(line, sep, true)
    local path = vim.fn.expand(opts.cwd..Path.path.sep..fields[1])
    if vim.fn.filereadable(path) == 0 then
      return nil
    end
    return {
      display = make_display,
      ordinal = fields[1],
      path = path,
      title = fields[3],
      date = fields[4],
    }
  end
end

M.list = function(opts)
  opts = opts or {}
  opts.cwd = opts.source or vim.env.PWD
  opts.entry_maker = gen_from_hugo(opts)
  pickers.new(opts, {
      prompt_title = 'Hugo contents',
      finder = finders.new_oneshot_job({'hugo', 'list', 'all'}, opts),
      sorter = conf.file_sorter(opts),
      previewer = previewers.new_termopen_previewer{
        get_command = function(entry, _)
            if vim.fn.executable(opts.preview_cmd) == 1 then
              return {opts.preview_cmd, entry.path}
            elseif vim.fn.executable'bat' == 1 then
              return {'bat', '--style', 'header,grid', entry.path}
            end
            return {'cat', entry.path}
        end,
      },
  }):find()
end

return M
