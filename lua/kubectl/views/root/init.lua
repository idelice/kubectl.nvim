local actions = require("kubectl.actions.actions")
local tables = require("kubectl.utils.tables")

local M = {}

function M.Root()
  local results = {
    "Deployments",
    "Events",
    "Nodes",
    "Secrets",
    "Services",
    "Configmaps",
  }
  local header, marks = tables.generateHeader({
    { key = "<enter>", desc = "Select" },
  }, true, true)
  actions.buffer(results, {}, "k8s_root", { title = "Root", header = { data = header, marks = marks } })
end

return M
