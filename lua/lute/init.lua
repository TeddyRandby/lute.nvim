local M = {
  did_setup = false,
  project = nil, -- user config will load here
  history = {},
  settings = {},
}

local utils = require("lute.utils")

local defaults = {
  javascript = {
    pattern = "%.js$",
    run = {
      "node",
      handler = require("lute.handlers.virtual"),
    },
  },
  lua = {
    pattern = "%.lua$",
    run = ":luafile",
  },
  python = {
    pattern = "%.py$",
    run = {
      "python",
      handler = require("lute.handlers.float"),
    },
  },
}

function M.setup(opts)
  if not M.did_setup then
    M.did_setup = true
  end

  M.settings = vim.tbl_deep_extend("keep", opts or {}, defaults)
end

local function meta()
  return {
    curpos = vim.fn.getcurpos(),
    buf = vim.api.nvim_get_current_buf(),
    win = vim.api.nvim_get_current_win(),
  }
end

local function match(filename)
  local matches = {}

  for _, conf in pairs(M.settings) do
    utils.match_fname_conf(filename, conf, matches)
  end

  -- ascending sort the table
  table.sort(matches, function(a, b)
    return a > b
  end)

  return matches[table.maxn(matches)]
end

-- Wrapper function for running nilable commands
local function run_command(cmd, arg, opts)
  arg = arg or ""

  if type(cmd) == "string" then
    if vim.startswith(cmd, ":") then
      local final = cmd .. " " .. arg

      local fn = function()
        vim.cmd(final)
      end

      table.insert(M.history, {
        name = final,
        fn = fn,
      })

      fn()
      return
    end

    local fn = function()
      return vim.fn.systemlist(cmd, arg)
    end

    table.insert(M.history, {
      name = cmd .. " " .. arg,
      fn = fn,
    })

    return fn()
  end
end

function M.run_selection()
  M.setup()

  local filename = vim.fn.expand("%")

  local conf = match(filename)

  if not conf then
    return
  end

  local cmd = conf.run

  local text, pos = utils.get_visual_selection()

  if type(cmd) == "table" then
    if cmd.handler then
      local m = vim.tbl_extend("force", { vpos = pos }, meta())

      return cmd.handler(run_command(cmd[1], text), m)
    end

    return run_command(cmd[1], text)
  end

  return run_command(cmd[1], text)
end

function M.run_file()
  M.setup()

  local filename = vim.fn.expand("%")

  local conf = match(filename)

  if not conf then
    return
  end

  local cmd = conf.run

  if type(cmd) == "table" then
    local final = cmd[1] .. " " .. filename

    if cmd.handler then
      return cmd.handler(run_command(final), meta())
    end

    return run_command(final)
  end

  if type(cmd) == "string" then
    return run_command(cmd .. " " .. filename)
  end
end

function M.again()
  M.history[#M.history].fn()
end

return M
