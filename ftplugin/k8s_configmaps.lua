local loop = require("kubectl.utils.loop")
local root_view = require("kubectl.views.root")
local tables = require("kubectl.utils.tables")
local api = vim.api
local configmaps_view = require("kubectl.views.configmaps")
local view = require("kubectl.views")

api.nvim_buf_set_keymap(0, "n", "g?", "", {
  noremap = true,
  silent = true,
  callback = function()
    view.Hints({ { key = "<d>", desc = "Describe selected pod" } })
  end,
})

api.nvim_buf_set_keymap(0, "n", "R", "", {
  noremap = true,
  silent = true,
  callback = function()
    configmaps_view.View()
  end,
})

api.nvim_buf_set_keymap(0, "n", "<bs>", "", {
  noremap = true,
  silent = true,
  callback = function()
    root_view.View()
  end,
})

api.nvim_buf_set_keymap(0, "n", "d", "", {
  noremap = true,
  silent = true,
  callback = function()
    local namespace, name = tables.getCurrentSelection(unpack({ 1, 2 }))
    if namespace and name then
      configmaps_view.ConfigmapsDesc(namespace, name)
    else
      api.nvim_err_writeln("Failed to describe pod name or namespace.")
    end
  end,
})

if not loop.is_running() then
  loop.start_loop(configmaps_view.View)
end
