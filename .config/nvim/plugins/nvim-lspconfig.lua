local lspconfig = require('lspconfig')

local servers = { 'jedi_language_server', 'rust_analyzer', 'sumneko_lua' }
for _, lsp in ipairs(servers) do
    lspconfig[lsp].setup{
      -- on_attach = my_custom_on_attach,
    }
end