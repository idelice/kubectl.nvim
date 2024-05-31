local M = {}

function M.continuous_shell_command(cmd, args)
  local loaded, Job = pcall(require, "plenary.job")
  if not loaded then
    vim.notify("plenary.nvim is not installed. Please install it to use this feature.", vim.log.levels.ERROR)
    return
  end

  local buf = vim.api.nvim_get_current_buf()
  vim.api.nvim_win_set_cursor(0, { vim.api.nvim_buf_line_count(buf), 0 })

  local function handle_output(data)
    vim.schedule(function()
      local line_count = vim.api.nvim_buf_line_count(buf)
      vim.api.nvim_buf_set_lines(buf, line_count, line_count, false, { data })
      vim.api.nvim_set_option_value("modified", false, { buf = buf })
      vim.api.nvim_win_set_cursor(0, { line_count + 1, 0 })
    end)
  end

  Job:new({
    command = cmd,
    args = args,
    on_stdout = function(_, data)
      handle_output(data)
    end,
    on_stderr = function(_, data)
      handle_output(data)
    end,
  }):start()
end

-- Function to execute a shell command and return the output as a table of strings
function M.execute_shell_command(cmd, args)
  local full_command = cmd .. " " .. table.concat(args, " ")
  local handle = io.popen(full_command, "r")
  if handle == nil then
    return { "Failed to execute command: " .. cmd }
  end
  local result = handle:read("*a")
  handle:close()

  return result
end

function M.execute_terminal(cmd, args)
  local full_command = cmd .. " " .. table.concat(args, " ")
  vim.fn.termopen(full_command, {
    on_exit = function(_, code, _)
      if code == 0 then
        print("Command executed successfully")
      else
        print("Command failed with exit code " .. code)
      end
    end,
  })
end

return M
