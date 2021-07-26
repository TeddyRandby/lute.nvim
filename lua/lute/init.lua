local lute = require("lute.lute")

-- Some default/example runners

--lua
-- Doesn't use write_command bc lua code can just be ran w/in nvim
-- If a lua runtime is intalled on your system,
-- There's no reason that lua can't be run using write_command
lute.new_runner(
  "lua",
  "%.lua$",
  function (filename)
    return "luafile " .. filename
  end)

--python
lute.new_runner(
  "python",
  "%.py$",
  function (filename)
    return lute.write_command("python3", filename)
  end)

--js
lute.new_runner(
  "javascript",
  "%.js$",
  function (filename)
    return lute.write_command("node", filename)
  end)

--ts
lute.new_runner(
  "typecript",
  "%.ts$",
  function (filename)
    return lute.write_command("ts-node", filename)
  end)

--jest js testing framework
lute.new_runner(
  "js/ts-test",
  {"%.test%.js$", "%.spec%.js$", "%.test%.ts$", "%.spec%.ts$"},
  function (filename)
    return lute.write_command("jest", filename)
  end)

--This will just compile the current file.
--For languages like rust, a project configuration is more useful.
lute.new_runner(
  "rust",
  "%.rs$",
  function (filename)
    return lute.write_command("rustc", filename)
  end)

return lute
