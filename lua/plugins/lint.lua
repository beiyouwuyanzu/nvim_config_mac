--return {
--  {
--    "mfussenegger/nvim-lint",
--    opts = {
--      linters = {
--        markdownlint = {
--          args = { "--disable", "MD013", "--" },
--        },
--      },
--    },
--  },
--}

return {
  "mfussenegger/nvim-lint",
  optional = true,
  opts = {
    linters = {
      ["markdownlint-cli2"] = {
        args = { "--config", "/home/pcino/.markdownlint-cli2.yaml", "--" },
      },
    },
  },
}
