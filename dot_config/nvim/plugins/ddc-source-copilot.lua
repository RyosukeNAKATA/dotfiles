-- Disable copilot.vim's default mappings (ddc handles completion)
vim.g.copilot_no_maps = true

-- Add copilot source options to ddc
-- Note: The 'copilot' source is already included in ddc.vim's sources list
vim.fn["ddc#custom#patch_global"]("sourceOptions", {
    copilot = {
        mark = "[copilot]",
        matchers = {},
        minAutoCompleteLength = 0,
        isVolatile = true,
    },
})
