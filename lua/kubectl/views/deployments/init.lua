local definition = require("kubectl.views.deployments.definition")
local ResourceBuilder = require("kubectl.resourcebuilder")

local M = {}

function M.Deployments()
  ResourceBuilder:new("deployments", { "get", "deployments", "-A", "-o=json" })
    :fetch()
    :decodeJson()
    :process(definition.processRow)
    :sort(SORTBY)
    :prettyPrint(definition.getHeaders)
    :addHints({
      { key = "<d>", desc = "desc" },
      { key = "<enter>", desc = "pods" },
    }, true, true)
    :setFilter(FILTER)
    :display("k8s_deployments")
end

function M.DeploymentDesc(deployment_desc, namespace)
  ResourceBuilder:new("desc", { "describe", "deployment", deployment_desc, "-n", namespace })
    :fetch()
    :splitData()
    :displayFloat("k8s_deployment_desc", deployment_desc, "yaml")
end

return M
