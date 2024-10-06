-- bootstrap lazy.nvim, LazyVim and your plugins
require("config.lazy")
require("project_nvim").setup({
  detection_methods = { "pattern" }, -- 使用模式检测项目根目录
  patterns = { ".git", "_darcs", ".hg", ".bzr", ".svn", "Makefile", "package.json" }, -- 检测的标志文件
})
-- require("lspconfig").pyright.setup({})

local lspconfig = require("lspconfig")

lspconfig.pyright.setup({
  on_new_config = function(new_config, root_dir)
    -- 检查工程目录是否包含 "llm-biz-server"
    if root_dir:match("llm%-biz%-server") then
      new_config.settings = {
        python = {
          pythonPath = "/Users/wangyaqi49/miniconda3/envs/biz/bin/python",
        },
      }
    elseif root_dir:match("triage") then
      new_config.settings = {
        python = {
          pythonPath = "/Users/wangyaqi49/miniconda3/envs/triage/bin/python",
        },
      }
    else
      -- 可以在这里设置默认的 Python 路径，或者不设置使用系统默认
      new_config.settings = {
        python = {
          pythonPath = "/Users/wangyaqi49/miniconda3/bin/python", -- 或者其他默认路径
        },
      }
    end
  end,
  --  on_attach = on_attach,
})

--require("lint").linters_by_ft = {
--  markdown = {}, -- 不为 Markdown 文件指定任何 linter
--}
--require("lspconfig").marksman.setup({
--  autostart = false,
--})

-- 禁用markdownlint
--vim.g.ale_linters_ignore = { markdown = { "markdownlint" } }

vim.opt.tabstop = 4 -- 设置 Tab 显示为 4 个空格宽
vim.opt.shiftwidth = 4 -- 设置自动缩进使用 4 个空格
vim.opt.expandtab = true -- 将 Tab 转换为空格

-- 配置最近项目快捷键
vim.api.nvim_create_user_command("Re", "Telescope projects", {})
vim.api.nvim_set_keymap("n", "<C-m>", "<cmd>MarkdownPreviewToggle<CR>", { noremap = true, silent = true })

-- 配置自动保存项目
vim.api.nvim_create_user_command("Sa", function()
  local project_path = vim.fn.getcwd() -- 获取当前工作目录
  print("Saving current project: " .. project_path)
  require("project_nvim").setup({}) -- 重新加载 project.nvim 配置以确保保存
end, {})

-- 不要拼写检查
vim.opt.spell = false

-- 确保在每个缓冲区加载时禁用拼写检查
vim.api.nvim_create_autocmd({ "BufEnter", "BufWinEnter", "FileType" }, {
  pattern = "*.md",
  callback = function()
    vim.opt_local.spell = false
  end,
})

vim.api.nvim_create_autocmd("BufWinLeave", {
  pattern = "*.md",
  callback = function()
    vim.opt_local.spell = false
  end,
})

-- ss禁用拼写检查
vim.api.nvim_create_user_command("Ss", function()
  vim.opt_local.spell = false
end, { desc = "Disable spelling checks in the current buffer" })

-- 文件树复制文件路径
vim.api.nvim_create_autocmd("FileType", {
  pattern = "neo-tree",
  callback = function()
    vim.api.nvim_buf_set_keymap(0, "n", "<leader>cp", "", {
      callback = function()
        local node = require("neo-tree.sources.manager").get_state("filesystem").tree:get_node()
        if node.type == "directory" or node.type == "file" then
          vim.fn.setreg("+", node.path)
          print("Path copied to clipboard: " .. node.path)
        end
      end,
      noremap = true,
      silent = true,
      desc = "Copy current file path to clipboard", -- Optional: description for which-key plugin or similar
    })
  end,
})

--auto save
vim.api.nvim_create_autocmd({ "InsertLeave", "TextChanged" }, {
  pattern = { "*" },
  command = "silent! wall",
  nested = true,
})

-- snippets
-- require("luasnip").setup({})
require("luasnip.loaders.from_snipmate").lazy_load()

local ls = require("luasnip")

vim.keymap.set({ "i" }, "<C-G>", function()
  ls.expand()
end, { silent = true })
vim.keymap.set({ "i", "s" }, "<C-L>", function()
  ls.jump(1)
end, { silent = true })
vim.keymap.set({ "i", "s" }, "<C-J>", function()
  ls.jump(-1)
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<C-E>", function()
  if ls.choice_active() then
    ls.change_choice(1)
  end
end, { silent = true })

-- avante setip
--require("avante").setup({
--  -- Your config here!
--})
--codeium setup
require("codeium").setup({})

local cmp = require("cmp")
local luasnip = require("luasnip")

cmp.setup({
  mapping = {
    ["<Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end, { "i", "s" }),

    ["<S-Tab>"] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  },
  --opts = function(_, opts)
  --  table.insert(opts.sources, 0, {
  --    name = "codeium",
  --    group_index = 0,
  --    priority = 100,
  --  })
  --end,
})

-- 动态添加 codeium 作为自动完成源
local function add_codeium_source()
  -- 获取当前的源配置
  local current_sources = cmp.get_config().sources

  -- 添加新的源到现有配置
  table.insert(current_sources, 1, { name = "codeium", group_index = 1, priority = 100 })

  -- 更新 cmp 的源配置
  cmp.setup({
    sources = current_sources,
  })
end

-- 在适当的时机调用这个函数，例如 Neovim 完全加载后
add_codeium_source()
