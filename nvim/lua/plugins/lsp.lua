return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = { "rust_analyzer", "ruff" },
    })

    -- Rust
    vim.lsp.config("rust_analyzer", {
      settings = {
        ["rust-analyzer"] = {
          assist = { importGranularity = "module", importPrefix = "by_self" },
          cargo = { allFeatures = true },
          checkOnSave = { command = "clippy" },
        },
      },
    })
    vim.lsp.enable("rust_analyzer")

    -- ty
    vim.lsp.config("ty", {
      cmd = { "ty", "server" },
      filetypes = { "python" },
      root_markers = { "pyproject.toml", ".git" },
      settings = {
        ty = {
          diagnosticMode = "openFilesOnly",
          inlayHints = {
            variableTypes = true,
            callArgumentNames = true,
          },
        },
      },
    })
    vim.lsp.enable("ty")

    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        local bufnr = args.buf

        if client and client.name == "rust_analyzer" then
          local bufmap = function(mode, lhs, rhs)
            vim.api.nvim_buf_set_keymap(bufnr, mode, lhs, rhs, { noremap = true, silent = true })
          end
          bufmap("n", "<leader>ca", "<cmd>lua vim.lsp.buf.code_action()<CR>")
          bufmap("n", "<leader>rr", "<cmd>!cargo run<CR>")
        end

        if client and client.server_capabilities and client.server_capabilities.inlayHintProvider then
          pcall(vim.lsp.inlay_hint.enable, true, { bufnr = bufnr })
        end
      end,
    })

    vim.keymap.set("n", "<leader>ih", function()
      local on = vim.lsp.inlay_hint.is_enabled({ bufnr = 0 })
      vim.lsp.inlay_hint.enable(not on, { bufnr = 0 })
    end, { desc = "Toggle inlay hints" })

    vim.api.nvim_set_hl(0, "LspInlayHint", { italic = true })
  end,
}
