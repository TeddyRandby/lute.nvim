local lute = require("lute")

local project = {
	cmd = {
		start = function() return lute.write_command("npm run start", "") end,
		test = function() return lute.write_command("npm run test", "") end,
		dev = function() return lute.write_command("npm run dev", "") end,
	}
}

lute.project = project