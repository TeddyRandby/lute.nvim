return function(result)
        local buf = vim.api.nvim_create_buf(false, true)

        local lines = {}

        for s in result:gmatch("[^\r\n]+") do
          table.insert(lines, s)
        end

        vim.api.nvim_buf_set_lines(buf, 0, -1, false, lines)

        local ui = vim.api.nvim_list_uis()[1]

        local height = ui.height * 0.2

        vim.api.nvim_open_win(buf, false, {
          relative = "win",
          width = ui.width,
          height = height,
          anchor = "NW",
          col = 0,
          row = ui.height - height;
          zindex = 50,
          focusable = true,
        })
      end
