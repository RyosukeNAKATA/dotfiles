call ddu#custom#patch_global({
\   'columns': ['icon_filename'],
\   'ui': 'filer',
\   'sources': [{'name': 'file', 'params': {}}],
\   'sourceOptions': {
\     '_': {
\       'columns': ['icon_filename'],
\     },
\   },
\   'kindOptions': {
\     'file': {
\       'defaultAction': 'open',
\     },
\   },
\ })
