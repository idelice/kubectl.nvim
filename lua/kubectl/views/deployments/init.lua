local ResourceBuilder = require("kubectl.resourcebuilder")
local buffers = require("kubectl.actions.buffers")
local commands = require("kubectl.actions.commands")
local definition = require("kubectl.views.deployments.definition")

local M = {}

function M.View(cancellationToken)
  ResourceBuilder:new("deployments")
    :setCmd({ "get", "--raw", "/apis/apps/v1/{{NAMESPACE}}deployments" })
    :fetchAsync(function(self)
      self:decodeJson():process(definition.processRow):sort():prettyPrint(definition.getHeaders)
      vim.schedule(function()
        self
          :addHints({
            { key = "<r>", desc = "restart" },
            { key = "<d>", desc = "desc" },
            { key = "<enter>", desc = "pods" },
          }, true, true)
          :display("k8s_deployments", "Deployments", cancellationToken)
      end)
    end)
end

function M.Edit(name, namespace)
  buffers.floating_buffer({}, {}, "k8s_deployment_edit", { title = name, syntax = "yaml" })
  commands.execute_terminal("kubectl", { "edit", "deployments/" .. name, "-n", namespace })
end

function M.DeploymentDesc(deployment_desc, namespace)
  ResourceBuilder:new("desc")
    :setCmd({ "describe", "deployment", deployment_desc, "-n", namespace })
    :fetchAsync(function(self)
      self:splitData()
      vim.schedule(function()
        self:displayFloat("k8s_deployment_desc", deployment_desc, "yaml")
      end)
    end)
end

return M
