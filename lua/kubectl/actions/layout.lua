local config = require("kubectl.config")
local M = {}
local api = vim.api

--- Set buffer options.
--- @param win integer: The window number.
function M.set_win_options(win)
  api.nvim_set_option_value("cursorline", true, { win = win })
  api.nvim_set_option_value("wrap", false, { win = win })
end

--- Set buffer options.
--- @param buf integer: The buffer number.
--- @param filetype string: The filetype for the buffer.
--- @param syntax string: The syntax for the buffer.
--- @param bufname string: The name of the buffer.
function M.set_buf_options(buf, filetype, syntax, bufname)
  api.nvim_set_option_value("filetype", filetype, { buf = buf })
  api.nvim_set_option_value("syntax", syntax, { buf = buf })
  api.nvim_set_option_value("bufhidden", "hide", { scope = "local" })
  api.nvim_set_option_value("modified", false, { buf = buf })
  api.nvim_buf_set_var(buf, "buf_name", bufname)

  -- TODO: How do we handle long text?
  -- api.nvim_set_option_value("wrap", true, { scope = "local" })
  -- api.nvim_set_option_value("linebreak", true, { scope = "local" })

  -- TODO: Is this neaded?
  -- vim.wo[win].winhighlight = "Normal:Normal"
  -- TODO: Need to workout how to reuse single buffer with this setting, or not
  -- api.nvim_set_option_value("modifiable", false, { buf = buf })
end

--- Get the main layout window.
--- @return integer: The current window number.
function M.main_layout()
  -- TODO: Should we create a new win?
  return api.nvim_get_current_win()
end

--- Create an Aliases layout.
--- @param buf integer: The buffer number.
--- @param filetype string: The filetype for the buffer.
--- @param title string|nil: The title for the buffer (optional).
--- @return integer: The window number.
function M.aliases_layout(buf, filetype, title)
  local width = 0.8 * vim.o.columns
  local height = 13
  local row = 10
  local col = 10

  local win = api.nvim_open_win(buf, true, {
    relative = "editor",
    style = "minimal",
    width = math.floor(width),
    height = math.floor(height),
    row = row,
    border = "rounded",
    col = col,
    title = filetype .. " - " .. (title or ""),
  })
  return win
end

--- Create a filter layout.
--- @param buf integer: The buffer number.
--- @param filetype string: The filetype for the buffer.
--- @param title string|nil: The title for the buffer (optional).
--- @return integer: The window number.
function M.filter_layout(buf, filetype, title)
  local width = 0.8 * vim.o.columns
  local height = 13
  local row = 10
  local col = 10

  local win = api.nvim_open_win(buf, true, {
    relative = "editor",
    style = "minimal",
    width = math.floor(width),
    height = math.floor(height),
    row = row,
    border = "rounded",
    col = col,
    title = filetype .. " - " .. (title or ""),
  })
  return win
end

--- Create a float dynamic layout.
--- @param buf integer: The buffer number.
--- @param filetype string: The filetype for the buffer.
--- @param title string|nil: The title for the buffer (optional).
--- @param opts { relative: string|nil }|nil: The options for the float layout (optional).
--- @return integer: The window number.
function M.float_dynamic_layout(buf, filetype, title, opts)
  opts = opts or {}
  if filetype ~= "" then
    title = filetype .. " - " .. (title or "")
  end

  local win = api.nvim_open_win(buf, true, {
    relative = opts.relative or "editor",
    style = "minimal",
    width = 100,
    height = 5,
    col = (vim.api.nvim_win_get_width(0) - 100 + 2) * 0.5,
    row = (vim.api.nvim_win_get_height(0) - 20) * 0.5,
    border = "rounded",
    title = title,
  })

  vim.api.nvim_buf_attach(buf, false, {
    on_lines = function(
      _, -- use nil as first argument (since it is buffer handle)
      buf_nr, -- buffer number
      _, -- buffer changedtick
      _, -- first line number of the change (0-indexed)
      lastline, -- last line number of the change
      new_lastline -- last line number after the change
    )
      if lastline ~= new_lastline then
        M.win_size_fit_content(buf_nr, 2)
      end
    end,
  })

  return win
end

--- Create a float layout.
--- @param buf integer: The buffer number.
--- @param filetype string: The filetype for the buffer.
--- @param title string|nil: The title for the buffer (optional).
--- @param opts { relative: string|nil, size: { width: number|nil, height: number|nil, row: number|nil,col: number|nil }}|nil: The options for the float layout (optional).
--- @return integer: The window number.
function M.float_layout(buf, filetype, title, opts)
  opts = opts or {}
  local size = opts.size or {}
  if filetype ~= "" then
    title = filetype .. " - " .. (title or "")
  end

  local win = api.nvim_open_win(buf, true, {
    relative = opts.relative or "editor",
    style = "minimal",
    width = size.width or math.floor(config.options.float_size.width * vim.o.columns),
    height = size.height or math.floor(config.options.float_size.height * vim.o.lines),
    row = size.row or config.options.float_size.row,
    col = size.col or config.options.float_size.col,
    border = "rounded",
    title = title,
  })
  return win
end

--- Create a notification layout.
--- @param buf integer: The buffer number.
--- @param title string: The title for the buffer.
--- @param opts { width: number, height: number }: The options for the notification layout.
--- @return integer: The window number.
function M.notification_layout(buf, title, opts)
  local editor_width, editor_height = M.get_editor_dimensions()
  local height = math.min(opts.height, editor_height)
  local width = math.min(opts.width, editor_width - 4) -- guess width of signcolumn etc.
  local row_max = vim.api.nvim_win_get_height(0)

  local col = vim.api.nvim_win_get_width(0)
  local win = api.nvim_open_win(buf, false, {
    relative = "win",
    style = "minimal",
    width = width,
    height = height,
    row = row_max - 2,
    col = col,
    focusable = false,
    border = "none",
    anchor = "SE",
    title = title,
    noautocmd = true,
    zindex = 45, -- Intentionally below standard float index
  })
  return win
end

--- Copied from: https://github.com/j-hui/fidget.nvim/blob/main/lua/fidget/notification/window.lua#L189
--- Get the current width and height of the editor window.
---
---@return number width
---@return number height
function M.get_editor_dimensions()
  local statusline_height = 0
  local laststatus = vim.opt.laststatus:get()
  if laststatus == 2 or laststatus == 3 or (laststatus == 1 and #vim.api.nvim_tabpage_list_wins(0) > 1) then
    statusline_height = 1
  end

  local height = vim.opt.lines:get() - (statusline_height + vim.opt.cmdheight:get())

  -- Does not account for &signcolumn or &foldcolumn, but there is no amazing way to get the
  -- actual "viewable" width of the editor
  --
  -- However, I cannot imagine that many people will render fidgets on the left side of their
  -- editor as it will more often overlay text
  local width = vim.opt.columns:get()

  return width, height
end

function M.win_size_fit_content(buf_nr, offset)
  local win_id = vim.api.nvim_get_current_win()
  local win_config = vim.api.nvim_win_get_config(win_id)

  local rows = vim.api.nvim_buf_line_count(buf_nr)
  -- Calculate the maximum width (number of columns of the widest line)
  local max_columns = 100
  local lines = vim.api.nvim_buf_get_lines(buf_nr, 0, rows, false)

  for _, line in ipairs(lines) do
    local line_width = vim.api.nvim_strwidth(line)
    if line_width > max_columns then
      max_columns = line_width
    end
  end

  win_config.height = rows + offset
  win_config.width = max_columns

  api.nvim_set_option_value("scrolloff", rows + offset, { win = win_id })
  vim.api.nvim_win_set_config(win_id, win_config)
  return win_config
end

return M
