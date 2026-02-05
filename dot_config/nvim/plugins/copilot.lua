-- ==============================================================================
-- copilot.vim 設定
-- GitHub Copilot のNode.jsパス設定
-- ==============================================================================

local home = os.getenv('HOME')
-- 使用するNode.jsのバージョン
-- miseでインストールしたNode.jsを使用
local node_version = '24.9.0'

-- copilot.vimが使用するNode.jsのパスを指定
-- システムのNode.jsではなく、miseで管理しているNode.jsを使用することで
-- バージョンを固定し、互換性の問題を回避
vim.g.copilot_node_command = home .. '/.local/share/mise/installs/node/' .. node_version .. '/bin/node'
