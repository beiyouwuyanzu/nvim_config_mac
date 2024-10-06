local lspconfig = require("lspconfig")

lspconfig.pyright.setup({
  on_attach = function(client, bufnr)
    -- 你的自定义配置
  end,
  settings = {
    python = {
      analysis = {
        typeCheckingMode = "strict",
      },
    },
  },
})
