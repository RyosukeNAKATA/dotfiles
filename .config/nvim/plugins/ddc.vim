call ddc#custom#patch_global(
      \  'ui',
      \  'pum'
      \  )

call ddc#custom#patch_global('sources', [
      \  'nvim-lsp',      
      \  'around', 
      \  'file',      
      \  ])

call ddc#custom#patch_global('sourceOptions', {
      \ '_': {
      \   'matchers': ['matcher_head'],
      \   'sorters': ['sorter_rank'],
      \   'converters': ['converter_remove_overlap'],
      \ },
      \ 'around': {'mark': 'A'},
      \ 'nvim-lsp': {
      \   'mark': 'lsp',
      \   'forceCompletionPattern': '\.\w*|:\w*|->\w*'
      \ },
      \ 'file': {
      \   'mark': 'file',
      \   'isVolatile': v:true, 
      \   'forceCompletionPattern': '\S/\S*'
      \ },
      \ })

call ddc#custom#patch_filetype('markdown', 'sourceParams', {
      \ 'around': {'maxSize': 100},
      \ })

" <TAB>: completion.
inoremap <silent><expr> <TAB>
\ pumvisible() ? '<C-n>' :
\ (col('.') <= 1 <Bar><Bar> getline('.')[col('.') - 2] =~# '\s') ?
\ '<TAB>' : ddc#map#manual_complete('sources', {[
      \ 'pum'
      \ ]})

" <S-TAB>: completion back.
inoremap <expr><S-TAB>  pumvisible() ? '<C-p>' : '<C-h>'

call ddc#enable()
