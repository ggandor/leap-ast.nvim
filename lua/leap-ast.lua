local api = vim.api
-- Note: The functions used here will be upstreamed eventually.
local ts_utils = require('nvim-treesitter.ts_utils')

local module = 'leap-ast'

local function get_ast_nodes()
  local wininfo = vim.fn.getwininfo(api.nvim_get_current_win())[1]
  -- Get current TS node.
  local cur_node = ts_utils.get_node_at_cursor(0)
  if not cur_node then return end
  -- Get parent nodes recursively.
  local nodes = { cur_node }
  local parent = cur_node:parent()
  while parent do
    table.insert(nodes, parent)
    parent = parent:parent()
  end
  -- Create Leap targets from TS nodes.
  local targets = {}
  local startline, startcol, endline, endcol
  for _, node in ipairs(nodes) do
    startline, startcol, endline, endcol = node:range()
    if startline + 1 >= wininfo.topline then
      local target = { node = node, pos = { startline + 1, startcol + 1, endline + 1, endcol + 1 } }
      table.insert(targets, target)
    end
  end
  if #targets >= 1 then return targets end
end

local function select_range(target)
  local mode = api.nvim_get_mode().mode
  if not mode:match('n?o') then
    -- Force going back to Normal (implies mode = v | V | ).
    vim.cmd('normal! ' .. mode)
  end
  ts_utils.update_selection(0, target.node,
    mode:match('V') and 'linewise' or
    mode:match('') and 'blockwise' or
    'charwise'
  )
end

local function create_augroup()
  return vim.api.nvim_create_augroup("leap-ast", {})
end

--- On select_range, create autocommands to label forward in addition to backward.
local function label_forward()
  local group_id = create_augroup()
  local ns = vim.api.nvim_create_namespace("leap-ast")

  vim.api.nvim_create_autocmd("User", {
    pattern = "LeapEnter",
    group = group_id,
    once = true,
    callback = function()
      local state = require('leap').state

      -- abort if this event does not come from leap-ast
      if state.args.module ~= module then
        return
      end

      -- label forward
      local opts = state.args.opts or {}
      local labels = opts.labels or require('leap').opts.labels
      for i, v in pairs(state.args.targets) do
        vim.api.nvim_buf_set_extmark(0, ns, v.pos[3] - 1, v.pos[4] - 1, {
          virt_text = { { labels[i], "LeapLabelPrimary" } },
          virt_text_pos = "overlay",
          hl_mode = "combine",
          priority = require('leap.highlight').priority.label
        })
      end
    end
  })

  vim.api.nvim_create_autocmd("User", {
    pattern = "LeapLeave",
    group = group_id,
    once = true,
    callback = function()
      local state = require('leap').state
      -- continue iff this event comes from leap-ast
      if state.args.module == module then
        vim.api.nvim_buf_clear_namespace(0, ns, 0, -1)
      end
    end
  })
end

local function leap()
  local opts = {
    targets = get_ast_nodes(),
    backward = true,
    module = "leap-ast",
  }
  if api.nvim_get_mode().mode ~= 'n' then
    opts.action = select_range
    opts.target_windows = { vim.api.nvim_get_current_win() }
    label_forward()
  end
  require('leap').leap(opts)
end

return { leap = leap }
