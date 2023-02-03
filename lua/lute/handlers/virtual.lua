return function(lines, meta)
  local buf = vim.api.nvim_get_current_buf()

  local ns = vim.api.nvim_create_namespace("lute")

  vim.api.nvim_buf_clear_namespace(buf, ns, 0, -1)

  if vim.v.shell_error ~= 0 then
    vim.notify(table.concat(lines, "\n"), "error")

    return
  end

  if #lines < 1 then
    return
  end

  local pos = meta.vpos or meta.curpos

  local line, col = pos[2], pos[3]

  local text = table.concat(lines, ", ")

  vim.api.nvim_buf_set_extmark(buf, ns, line + - 1, col - 1, {
    virt_text = { { "\u{e602} ", "@text.title" }, { text, "Normal" } },
    virt_text_pos = "eol",
  })
end
