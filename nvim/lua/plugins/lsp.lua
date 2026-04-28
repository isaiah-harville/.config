return {
  "neovim/nvim-lspconfig",
  dependencies = {
    "williamboman/mason.nvim",
    "williamboman/mason-lspconfig.nvim",
  },
  config = function()
    require("mason").setup()
    require("mason-lspconfig").setup({
      ensure_installed = { "rust_analyzer", "ruff", "ts_ls", "svelte", "eslint" },
    })

    vim.diagnostic.config({
      virtual_text = { prefix = "●" },
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = { border = "rounded", source = true },
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

    -- ruff
    vim.lsp.config("ruff", {
      init_options = {
        settings = { lineLength = 100 },
      },
    })
    vim.lsp.enable("ruff")

    -- TypeScript / JavaScript / React
    vim.lsp.config("ts_ls", {
      filetypes = { "typescript", "javascript", "typescriptreact", "javascriptreact" },
      settings = {
        typescript = {
          inlayHints = {
            includeInlayParameterNameHints = "all",
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
          },
        },
        javascript = {
          inlayHints = {
            includeInlayParameterNameHints = "all",
            includeInlayPropertyDeclarationTypeHints = true,
            includeInlayFunctionLikeReturnTypeHints = true,
          },
        },
      },
    })
    vim.lsp.enable("ts_ls")

    -- Svelte / SvelteKit
    vim.lsp.config("svelte", {
      filetypes = { "svelte" },
    })
    vim.lsp.enable("svelte")

    -- ESLint
    vim.lsp.config("eslint", {
      filetypes = { "javascript", "javascriptreact", "typescript", "typescriptreact", "svelte" },
    })
    vim.lsp.enable("eslint")

    -- Swift
    vim.lsp.config("sourcekit", {
      cmd = { "sourcekit-lsp" },
      filetypes = { "swift", "objc", "objcpp" },
      root_markers = { "Package.swift", ".git" },
    })
    vim.lsp.enable("sourcekit")

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
        local bufmap = function(mode, lhs, rhs, desc)
          vim.keymap.set(mode, lhs, rhs, { noremap = true, silent = true, buffer = bufnr, desc = desc })
        end

        bufmap("n", "gd", vim.lsp.buf.definition, "Go to definition")
        bufmap("n", "gD", vim.lsp.buf.declaration, "Go to declaration")
        bufmap("n", "gi", vim.lsp.buf.implementation, "Go to implementation")
        bufmap("n", "gr", vim.lsp.buf.references, "References")
        bufmap("n", "K", vim.lsp.buf.hover, "Hover docs")
        bufmap("n", "<leader>ca", vim.lsp.buf.code_action, "Code action")
        bufmap("n", "<leader>rn", vim.lsp.buf.rename, "Rename")
        bufmap("n", "<leader>d", vim.diagnostic.open_float, "Diagnostics float")
        bufmap("n", "[d", vim.diagnostic.goto_prev, "Prev diagnostic")
        bufmap("n", "]d", vim.diagnostic.goto_next, "Next diagnostic")

        if client and client.name == "rust_analyzer" then
          bufmap("n", "<leader>rr", "<cmd>!cargo run<CR>", "Cargo run")
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
