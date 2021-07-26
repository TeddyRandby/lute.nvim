local M = {
  template_cmd = {
    cargo = {
      build = "cargo run",
      test = "cargo test",
    },
    make = {
      build = "make",
      test = "make test",
      run = "./main" -- Your executable here
    },
    npm = {
      start = "npm run start",
      dev = "npm run dev",
      test = "npm run test",
    },
  },
}

function M.template_options()
  local opts = {}
  for opt, _ in pairs(M.template_cmd) do
    table.insert(opts, opt)
  end
  return opts
end


function M.write_template(template)
  local file = io.open('.lute', 'w')
  io.output(file)
  local base = "local lute = require(\"lute\")\n\nlocal project = {\n\tcmd = {\n"
  for name, cmd in pairs(M.template_cmd[template]) do
    base = base .. '\t\t' .. name .. ' = function() return lute.write_command(\"' .. cmd .. '\", \"\") end,\n'
  end
  base = base .. "\t}\n}\n\nlute.project = project"
  io.write(base)
end


return M
