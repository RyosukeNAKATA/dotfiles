require("fidget").setup({
    -- Options for LSP progress notifications
    progress = {
        display = {
            done_ttl = 3, -- How long a message should persist after completion
        },
    },
    -- Options for notification subsystem
    notification = {
        window = {
            winblend = 0, -- Background transparency (0 = opaque)
        },
    },
})
