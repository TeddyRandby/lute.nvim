local M = {
  match_fname_conf = function(filename, conf, matches)
    if type(conf.pattern) == "table" then
      for _, pattern in pairs(conf.pattern) do
        M.match_fname_conf(filename, pattern, matches)
      end

      return
    end

    if type(conf.pattern) == "string" then
      local start, finish = string.find(filename, conf.pattern)

      if start and finish then
        matches[finish - start + 1] = conf
      end

      return
    end
  end,
  get_visual_selection = function()
    -- Yank current visual selection into the 'v' register
    --
    -- Note that this makes no effort to preserve this register
    vim.cmd('noau normal! "vy"')

    return vim.fn.getreg("v"), vim.fn.getpos("v")
  end,
  pick = function(options, opts)
    local pickers = require("telescope.pickers")
    local finders = require("telescope.finders")
    local sorters = require("telescope.sorters")
    local actions = require("telescope.actions")
    local state = require("telescope.actions.state")

    pickers
        .new({}, {
          layout_strategy = "center",
          layout_config = {
            height = 0.2,
            width = 0.5,
          },
          results_title = opts.results_title,
          prompt_title = opts.prompt_title,
          finder = finders.new_table({
            results = options,
          }),
          sorter = sorters.get_generic_fuzzy_sorter(),
          previewer = false,
          attach_mappings = function(buf, map)
            map("i", "<cr>", function()
              local result = state.get_selected_entry()[1]
              actions.close(buf)
              opts.cb(result)
            end)
            return true
          end,
        })
        :find()
  end,
}

return M
