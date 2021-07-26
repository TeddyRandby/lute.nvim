# l u t e

lute started out as a (lu)a (te)st-running plugin,
but became a way to run files of any kind,
including some project-level commands.

The fundamental idea is to map patterns to run-commands
instead of just vim filetypes.

the matching is done with lua's built in pattern matching,
which is different from POSIX regular expressions.

Here is the relevant documentation:
https://www.lua.org/pil/20.1.html


## File configuration
```
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
```
The first argument to ```lute.new_runner()``` is an alias for the patterns.
The aliases exist to make changing runners easier.
```
-- ex: changing the js test framework
        lute.set_runner({
           lang: 'js/ts-test',
           runner: 'mocha'
        })

```

the second argument is the pattern of the file, and the third is the function
which will be run whenever ```lute.run_file()``` is called and the pattern
matches the current file. This function can either run the file
(in the case of lua) or return a string command for running it.

## Project configuration

Project configuration can be useful with tools like npm, make, and cargo.
Templates for these tools come built-in. Run ```lute.project_config()```
to open a telescope prompt and select a configuration.

This will write a .lute file in the current directory, populated with the
appropriate defaults. 

```
local lute = require("lute")

local project = {
	cmd = {
		start = function() return lute.write_command("npm run start", "") end,
		test = function() return lute.write_command("npm run test", "") end,
		dev = function() return lute.write_command("npm run dev", "") end,
	}
}

lute.project = project

```
lute runs this file once during setup, so the plugin will have to be reloaded
for changes to take effect.

Upon running ```lute.run_project()```, another telescope prompt will appear,
and the chosen command will be run.

There is an additional function ```lute.run_last()``` which just repeats whatever the previous command was.
