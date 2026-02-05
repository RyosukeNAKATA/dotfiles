require("noice").setup({
    -- Disable cmdline UI to avoid conflicts with ddc.vim cmdline completion
    cmdline = {
        enabled = false,
    },
    -- Disable messages UI (optional, can be enabled if desired)
    messages = {
        enabled = true,
    },
    -- Disable popupmenu to avoid conflicts with pum.vim
    popupmenu = {
        enabled = false,
    },
    -- Keep notify for notifications
    notify = {
        enabled = true,
    },
    -- LSP settings
    lsp = {
        progress = {
            enabled = true,
        },
        hover = {
            enabled = true,
        },
        signature = {
            enabled = false, -- Using denops-signature_help instead
        },
    },
})
