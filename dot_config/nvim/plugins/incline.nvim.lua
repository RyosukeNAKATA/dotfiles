-- ==============================================================================
-- incline.nvim 設定
-- ウィンドウごとに浮遊するステータスラインを表示
-- ==============================================================================

local devicons = require('nvim-web-devicons')

local palette = {
    active = '#a093c7',
    inactive = '#6b7089',
    background = '#161821',
    error = '#e27878',
    modified = '#e2a478',
}

local diagnostics = {
    { severity = 'ERROR', icon = '󰅚 ' },
    { severity = 'WARN', icon = '󰀪 ' },
    { severity = 'HINT', icon = '󰌶 ' },
    { severity = 'INFO', icon = ' ' },
}

local function get_display_filename_and_dirname(buf)
    local path = vim.api.nvim_buf_get_name(buf)
    if path == '' then
        return '[No Name]', nil
    end

    local relative = vim.fn.fnamemodify(path, ':.')
    local filename = vim.fn.fnamemodify(relative, ':t')
    local dirname = vim.fn.fnamemodify(relative, ':h')

    if dirname == '.' then
        dirname = nil
    end

    return filename, dirname
end

local function get_diagnostic_label(props)
    local label = {}

    for _, diagnostic in ipairs(diagnostics) do
        local count = #vim.diagnostic.get(props.buf, {
            severity = vim.diagnostic.severity[diagnostic.severity],
        })

        if count > 0 then
            table.insert(label, {
                diagnostic.icon .. count .. ' ',
                group = props.focused and ('DiagnosticSign' .. diagnostic.severity:lower()) or 'NonText',
            })
        end
    end

    if #label > 0 then
        table.insert(label, { '┊ ', guifg = palette.inactive })
    end

    return label
end

require('incline').setup({
    highlight = {
        groups = {
            InclineNormal = { guibg = palette.background, guifg = palette.active },
            InclineNormalNC = { guibg = 'none', guifg = palette.inactive },
        },
    },
    window = {
        options = {
            winblend = 0,
        },
        placement = {
            horizontal = 'right',
            vertical = 'bottom',
        },
        margin = {
            horizontal = 0,
            vertical = 0,
        },
        padding = 2,
    },
    render = function(props)
        local filename, dirname = get_display_filename_and_dirname(props.buf)

        local ft_icon, ft_color = devicons.get_icon_color(filename)
        local has_error = #vim.diagnostic.get(props.buf, {
            severity = vim.diagnostic.severity.ERROR,
        }) > 0
        local is_readonly = vim.bo[props.buf].readonly

        local fg_filename_active = has_error and palette.error
            or (is_readonly and palette.inactive or palette.active)
        local fg_filename = props.focused and fg_filename_active or palette.inactive

        return {
            { get_diagnostic_label(props) },
            {
                ft_icon and (ft_icon .. ' ') or '',
                guifg = props.focused and ft_color or palette.inactive,
            },
            {
                is_readonly and ' ' or '',
                guifg = fg_filename,
            },
            {
                dirname and (dirname .. '/') or '',
                guifg = palette.inactive,
            },
            {
                filename,
                guifg = fg_filename,
                gui = props.focused and 'bold' or '',
            },
            {
                vim.bo[props.buf].modified and ' ●' or '',
                guifg = props.focused and palette.modified or palette.inactive,
            },
        }
    end,
})
