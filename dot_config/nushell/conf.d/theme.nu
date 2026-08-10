# Nushell 用 Iceberg Dark カラーテーマ
let iceberg_theme = {
    # カラーパレットの定義
    # 背景色: #161821
    # 前景色: #c6c8d1
    # 黒: #161821, 赤: #e27878, 緑: #b4be82, 黄: #e2a478
    # 青: #84a0c6, マゼンタ: #a093c7, シアン: #89b8c2, 白: #c6c8d1
    # 明るい黒: #6b7089, 明るい赤: #e98989, 明るい緑: #c0ca8e
    # 明るい黄: #e9b189, 明るい青: #91acd1, 明るいマゼンタ: #ada0d6
    # 明るいシアン: #95c4ce, 明るい白: #d2d4de

    separator: "#6b7089"
    leading_trailing_space_bg: { attr: "n" }
    header: { fg: "#84a0c6", attr: "b" }
    empty: "#89b8c2"
    bool: "#e2a478"
    int: "#a093c7"
    filesize: "#89b8c2"
    duration: "#e2a478"
    date: "#a093c7"
    range: "#e2a478"
    float: "#a093c7"
    string: "#b4be82"
    nothing: "#6b7089"
    binary: "#a093c7"
    cell-path: "#c6c8d1"
    row_index: { fg: "#84a0c6", attr: "b" }
    record: "#c6c8d1"
    list: "#c6c8d1"
    block: "#c6c8d1"
    hints: "#6b7089"
    search_terms: { fg: "#161821", bg: "#e2a478" }

    shape_and: "#a093c7"
    shape_binary: "#a093c7"
    shape_block: "#c6c8d1"
    shape_bool: "#e2a478"
    shape_closure: "#89b8c2"
    shape_custom: "#b4be82"
    shape_datetime: "#a093c7"
    shape_directory: "#84a0c6"
    shape_external: "#84a0c6"
    shape_externalarg: "#c6c8d1"
    shape_filepath: "#84a0c6"
    shape_flag: "#89b8c2"
    shape_float: "#a093c7"
    shape_garbage: { fg: "#e27878", attr: "b" }
    shape_unknown: { fg: "#e27878", attr: "b" }
    shape_globpattern: "#89b8c2"
    shape_int: "#a093c7"
    shape_internalcall: "#89b8c2"
    shape_keyword: "#a093c7"
    shape_list: "#c6c8d1"
    shape_literal: "#84a0c6"
    shape_match_pattern: "#b4be82"
    shape_nothing: "#6b7089"
    shape_operator: "#e2a478"
    shape_or: "#a093c7"
    shape_pipe: "#a093c7"
    shape_range: "#e2a478"
    shape_record: "#c6c8d1"
    shape_redirection: "#a093c7"
    shape_signature: "#b4be82"
    shape_string: "#b4be82"
    shape_string_interpolation: "#89b8c2"
    shape_table: "#84a0c6"
    shape_variable: "#a093c7"
    shape_vardecl: "#a093c7"
}
