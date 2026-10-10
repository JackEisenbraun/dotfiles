-- ~/.config/nvim/lua/projects.lua
-- A tiny project list: add/remove folders, show them on the dashboard.

local M = {}

local store = vim.fn.stdpath("data") .. "/projects.json"

local function normalize(path)
  return vim.fs.normalize(vim.fn.fnamemodify(vim.fn.expand(path), ":p"))
end

local function notify(msg, level)
  vim.notify(msg, level or vim.log.levels.INFO, { title = "Projects" })
end

---@return string[]
function M.list()
  local f = io.open(store, "r")
  if not f then
    return {}
  end
  local content = f:read("*a")
  f:close()
  local ok, data = pcall(vim.json.decode, content)
  return (ok and type(data) == "table") and data or {}
end

local function save(list)
  vim.fn.mkdir(vim.fn.fnamemodify(store, ":h"), "p")
  vim.fn.writefile({ vim.json.encode(list) }, store)
end

local function refresh_dashboard()
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks.dashboard and snacks.dashboard.update then
    pcall(snacks.dashboard.update)
  end
end

function M.add(dir)
  dir = normalize(dir or vim.fn.getcwd())
  if vim.fn.isdirectory(dir) == 0 then
    return notify("Not a directory: " .. dir, vim.log.levels.ERROR)
  end
  local list = M.list()
  if vim.tbl_contains(list, dir) then
    return notify("Already added: " .. dir, vim.log.levels.WARN)
  end
  table.insert(list, dir)
  save(list)
  refresh_dashboard()
  notify("Added " .. dir)
end

function M.remove(dir)
  local function do_remove(target)
    local list = M.list()
    local kept = vim.tbl_filter(function(p)
      return p ~= target
    end, list)
    if #kept == #list then
      return notify("Not in project list: " .. target, vim.log.levels.WARN)
    end
    save(kept)
    refresh_dashboard()
    notify("Removed " .. target)
  end

  if dir and dir ~= "" then
    return do_remove(normalize(dir))
  end

  local list = M.list()
  if #list == 0 then
    return notify("No projects to remove")
  end
  vim.ui.select(list, { prompt = "Remove project" }, function(choice)
    if choice then
      do_remove(choice)
    end
  end)
end

function M.open(dir)
  if vim.fn.isdirectory(dir) == 0 then
    return notify("Folder no longer exists: " .. dir, vim.log.levels.ERROR)
  end
  vim.cmd.cd(vim.fn.fnameescape(dir))
  local ok, snacks = pcall(require, "snacks")
  if ok and snacks.picker then
    snacks.picker.files({ cwd = dir })
  else
    vim.cmd("edit .")
  end
end

function M.pick()
  local entries = {}
  for _, dir in ipairs(M.list()) do
    table.insert(entries, { dir = dir })
  end
  table.insert(entries, { add = true })

  vim.ui.select(entries, {
    prompt = "Projects",
    format_item = function(e)
      if e.add then
        return "+ Add folders..."
      end
      return vim.fn.fnamemodify(e.dir, ":t") .. "  (" .. vim.fn.fnamemodify(e.dir, ":~") .. ")"
    end,
  }, function(choice)
    if not choice then
      return
    end
    if choice.add then
      M.browse()
    else
      M.open(choice.dir)
    end
  end)
end

-- Where :BrowseProjects looks for folders, and how deep.
M.roots = { "~" }
M.max_depth = 3

--- Fuzzy-search folders under M.roots; Tab multi-selects, Enter adds them.
function M.browse()
  local ok, snacks = pcall(require, "snacks")
  if not ok or not snacks.picker then
    return notify("snacks.nvim picker is required", vim.log.levels.ERROR)
  end
  if vim.fn.executable("fd") == 0 then
    return notify("`fd` is required for folder search", vim.log.levels.ERROR)
  end

  local roots = vim.tbl_map(normalize, M.roots)
  snacks.picker.pick({
    source = "project_dirs",
    title = "Add projects (Tab = multi-select)",
    finder = function(_, ctx)
      local args = { ".", "--type", "d", "--absolute-path", "--hidden", "--color=never" }
      vim.list_extend(args, { "--max-depth", tostring(M.max_depth) })
      for _, ex in ipairs({ ".git", "node_modules", ".cache", ".local", "Library", ".Trash", ".npm", ".cargo" }) do
        vim.list_extend(args, { "--exclude", ex })
      end
      vim.list_extend(args, roots)
      return require("snacks.picker.source.proc").proc(ctx:opts({
        cmd = "fd",
        args = args,
        transform = function(item)
          item.file = item.text
          item.dir = true
        end,
      }), ctx)
    end,
    format = "file",
    confirm = function(picker)
      local selected = picker:selected({ fallback = true })
      picker:close()
      for _, item in ipairs(selected) do
        M.add(item.file)
      end
    end,
  })
end

function M.setup()
  vim.api.nvim_create_user_command("AddProject", function(o)
    M.add(o.args ~= "" and o.args or nil)
  end, { nargs = "?", complete = "dir", desc = "Add a directory (default: cwd) to the project list" })

  vim.api.nvim_create_user_command("RemoveProject", function(o)
    M.remove(o.args ~= "" and o.args or nil)
  end, {
    nargs = "?",
    desc = "Remove a project (no argument: pick from a list)",
    complete = function(lead)
      return vim.tbl_filter(function(p)
        return p:lower():find(lead:lower(), 1, true) ~= nil
      end, M.list())
    end,
  })

  vim.api.nvim_create_user_command("Projects", M.pick, { desc = "Pick a project" })
  vim.api.nvim_create_user_command("BrowseProjects", M.browse, { desc = "Fuzzy-find folders to add as projects" })
end

return M
