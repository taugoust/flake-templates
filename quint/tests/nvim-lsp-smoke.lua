-- Run from the project root after loading the configured Neovim environment:
-- nix develop --command nvim --headless '+luafile tests/nvim-lsp-smoke.lua'
local ok, err = xpcall(function()
  vim.cmd.edit('hello.qnt')
  local bufnr = vim.api.nvim_get_current_buf()
  assert(vim.bo.filetype == 'quint', 'Expected .qnt to be detected as quint')
  assert(vim.bo.syntax == 'quint', 'Expected Quint syntax highlighting')
  assert(vim.fn.synIDattr(vim.fn.synID(1, 1, 1), 'name') == 'quintDecl',
    'Expected the module keyword to be highlighted')
  assert(vim.wait(20000, function()
    local clients = vim.lsp.get_clients({ bufnr = bufnr, name = 'quint' })
    return #clients == 1 and clients[1].initialized
  end), 'Quint LSP did not attach')
  local client = vim.lsp.get_clients({ bufnr = bufnr, name = 'quint' })[1]
  assert(client.config.root_dir == vim.fn.getcwd(), 'Incorrect project root')
  local original = vim.api.nvim_buf_get_lines(bufnr, 0, -1, false)
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, {
    'module hello { pure val broken = missingName }',
  })
  assert(vim.wait(20000, function()
    for _, diagnostic in ipairs(vim.diagnostic.get(bufnr)) do
      if diagnostic.severity == vim.diagnostic.severity.ERROR
        and diagnostic.message:find('missingName', 1, true) then
        return true
      end
    end
    return false
  end), 'Expected an undefined-name diagnostic')
  vim.api.nvim_buf_set_lines(bufnr, 0, -1, false, original)
  assert(vim.wait(20000, function()
    return #vim.diagnostic.get(bufnr) == 0
  end), 'Diagnostics did not clear after fixing the buffer')
  -- The source file is never written by this test.
  vim.bo.modified = false
  print('Neovim smoke test passed: filetype, highlighting, attachment, root, diagnostics, edits')
end, debug.traceback)
for _, client in ipairs(vim.lsp.get_clients()) do
  client:stop()
end
vim.wait(10000, function() return #vim.lsp.get_clients() == 0 end)
if not ok then
  vim.api.nvim_err_writeln(err)
  vim.cmd.cquit()
else
  vim.cmd.qa({ bang = true })
end
