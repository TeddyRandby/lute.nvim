vim.cmd("augroup lute")
vim.cmd("au!")
vim.cmd("au BufRead,BufNewFile .lute set ft=lua")
vim.cmd("augroup end")

local M = {
  patterns = {}, -- table of lables -> file patterns
  runners = {}, -- table of file patterns -> commands
  did_setup = false,
  use_toggleterm = false, -- config option for running commands in toggleterm
  project = nil, -- user config will load here
  last_cmd = nil, -- track last used command
}

local function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

local function load_config()
    if file_exists(".lute") then
      vim.cmd("luafile .lute")
    end
end

-- a helper function for writing the vim cmd.
-- useful because it handles options in the module
-- like 'use_toggleterm'
function M.write_command(runner, filename)
  local prefix = ""
  local suffix = ""
  if M.use_toggleterm then
    prefix = ":TermExec cmd=\""
    suffix = "\""
  else
    prefix = "!"
  end
  return prefix..runner.." "..filename..suffix
end

function M.setup()
  if not M.did_setup then
    M.did_setup = true
    load_config()
  end
end

-- Helper function for changing runners
--  args can be: {
--      (
--      lang: The language to associate the runner with.
--           - or -
--      pattern: The pattern to associate the runner with
--      )
--          - and -
--      runner: a function which takes a filename as an argument
--          and either runs the file, or returns a string which
--          will run the file when passed to vim.cmd()
--  }
-- NOT useful for creating new runners. use new_runner() for that.
-- This is useful for changing default runners without having to touch all the patterns.
-- ex: changing the js test framework
--        M:set_runner({
--           lang: 'test-js',
--           runner: 'mocha'
--        })
function M.set_runner(args)
  if args.lang then
    local ft = M.patterns[args.lang]
    if ft then
      M.runners[ft] = args.runner
    end
 elseif args.filetype then
    M.runners[args.filetype] = args.runner
  end
end

-- Set a new name, pattern and runner
-- Pattern can be a table of multiple patterns
function M.new_runner(lang, pattern, runner)
  M.patterns[lang] = pattern

  if type(pattern) == "table" then
    for _,pat in pairs(pattern) do
      M.runners[pat] = runner
    end
  else
    M.runners[pattern] = runner
  end
end

-- Uses length of match instead of length of pattern
local function match_fname_pattern(filename, pattern, matches)
    local start, finish = string.find(filename, pattern);
    if start then
      matches[finish - start + 1] = pattern
    end
end

-- Wrapper function for running nilable commands
local function run_command(cmd)
  if (cmd) then
    vim.cmd(cmd)
    M.last_command = cmd;
  end
end

-- Match the current file against the known patterns, run the corresponding command.
function M.run_file()
  M.setup()

  local filename = vim.fn.expand("%");
  local matches = {}

  for pattern, _ in pairs(M.runners) do
     match_fname_pattern(filename, pattern, matches)
  end

  -- ascending sort the table
  table.sort(matches, function (a,b) return a > b end)


  -- take the last element in the table
  local pattern = matches[table.maxn(matches)]
  local runner = M.runners[pattern]
  local command = runner(filename)

  run_command(command)
end

function M.run_last_cmd()
  run_command(M.last_cmd)
end

-- Wrapper function for telescope picking
local function pick(args)
      local pickers = require("telescope.pickers")
      local finders = require("telescope.finders")
      local sorters = require("telescope.sorters")
      local actions = require("telescope.actions")
      local state = require("telescope.actions.state")

      pickers.new {
        layout_strategy = "center",
        layout_config = {
          height = 0.2,
          width = 0.5,
        },
        results_title = args.results_title,
        prompt_title = args.prompt_title,
        finder = finders.new_table{
          results = args.results,
          -- entry_mapper = function(entry) end,
        },
        sorter = sorters.get_generic_fuzzy_sorter(),
        previewer = false,
        attach_mappings = function(buf, map)
          map('i', '<cr>', function()
            local result = state.get_selected_entry()[1]
            args.cb(result)
            actions.close(buf)
          end)
          return true
        end
      }:find()
end

local function entry_mapper(cmd_table)
  local entries = {}
  for cmd_name, _ in pairs(cmd_table) do
    table.insert(entries, cmd_name)
  end
  return entries
end

-- Use the .lute file in the project directory to run a file
function M.run_project()
  M.setup()

  if M.project then
    if M.project.cmd then
      pick {
        results_title = "Available commands",
        prompt_title = "Run a command",
        results = entry_mapper(M.project.cmd),
        cb = function(picked)
            run_command(M.write_command(M.project.cmd[picked], ""))
        end,
      }
    else
      print("No command in project config")
    end
  else
    print("No project config found")
  end
end

-- Conveniently create config files for common projects.
-- Reload the plugin inorder to see new configs
function M.project_config()
  local config = require("lute.config")

  pick {
    results_title = 'Available templates',
    prompt_title = 'Choose a template',
    results = config.template_options(),
    cb = function(picked)
        config.write_template(picked)
    end,
  }
end

-- Open the config file in vim
function M.open_project_config()
  vim.cmd(":e .lute")
end

return M
