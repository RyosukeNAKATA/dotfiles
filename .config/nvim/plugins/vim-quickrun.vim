if !exists("g:quickrun_config")
  let g:quickrun_config={}
endif

let g:quickrun_config = {
  \  "_" : {
  \    "outputter": "popup",
  \  }
  \}

augroup rust_quickrun
  au!
  autocmd BufNewFile,BufRead *.rs let g:quickrun_config.rust = {'exec' : 'cargo run'}
augroup END
