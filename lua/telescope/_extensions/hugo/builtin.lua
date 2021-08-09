local utils = require'telescope.utils'
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
    local path = tostring(Path:new(vim.fn.expand(opts.cwd), fields[1]))
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

local function get_default_opts(opts)
  opts = opts or {}
  opts.cwd = opts.source or vim.env.PWD
  return opts
end



M.list = function(opts)
  opts = get_default_opts(opts)
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

M.new = function(opts)
  opts = get_default_opts(opts)
  opts.content_dir = opts.content_dir or ""
  vim.fn.inputsave()
  local new_filename = vim.fn.input("Input new filename > "..tostring(Path:new(vim.fn.expand(opts.cwd), opts.content_dir))..Path.path.sep)
  vim.cmd("redraw")
  if new_filename == "" then
    return
  end
  vim.fn.inputrestore()
  local out, ret, err = utils.get_os_command_output({"hugo", "new", tostring(Path:new(opts.content_dir, new_filename))}, opts.cwd)
  if ret == 255 then
    if err[1] then
      return echo(err[1])
    end
    return echo("Something wrong.")
  end
  echo(out[1])
  local splited = vim.split(out[1], " ", true)
  table.remove(splited)
  local created_file = table.concat(splited, " ")
  vim.cmd("edit "..created_file)
end

return M
