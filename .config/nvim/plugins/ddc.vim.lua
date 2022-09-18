vim.cmd([[
" Customize global settings
" Use around source.
" https://github.com/Shougo/ddc-around

call ddc#custom#patch_global('completionMenu', 'pum.vim')
call ddc#custom#patch_global('sources', ['around', 'mocword', 'file', 'nvim-lsp', 'vsnip'])

call ddc#custom#patch_global('sourceOptions', {
      \ '_': {
      \   'matchers': ['matcher_head'],
      \   'sorters': ['sorter_rank'],
      \   'converters': ['converter_remove_overlap'],
      \ },
      \ 'around': {'mark': 'A'},
      \ 'mocword': {
      \   'mark': 'mocword',
      \   'minAutoCompleteLength': 3,
      \   'isVolatile': v:true,
      \   },
      \ 'nvim-lsp': {
      \   'mark': 'lsp',
      \   'forceCompletionPattern': 
      \   '\.\w*|:\w*|->\w*'
      \   },
      \ 'file': {
      \   'mark': 'file',
      \   'isVolatile': v:true, 
      \   'forceCompletionPattern': '\S/\S*'
      \ },
      \ })

" Change source options
call ddc#custom#patch_global('sourceParams', {
      \ 'around': {'maxSize': 500},
      \ })

" Customize settings on a filetype
call ddc#custom#patch_filetype('markdown', 'sourceParams', {
      \ 'around': {'maxSize': 100},
      \ })

autocmd User PumCompleteDone call vsnip_integ#on_complete_done(g:pum#completed_item)

" Mappings
" <TAB>: completion.
inoremap <silent><expr> <TAB>
\ ddc#map#pum_visible() ? '<C-n>' :
\ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
\ '<TAB>' : ddc#map#manual_complete()

" <S-TAB>: completion back.
inoremap <expr><S-TAB>  ddc#map#pum_visible() ? '<C-p>' : '<C-h>'

" Use ddc.
call ddc#enable()
]])
