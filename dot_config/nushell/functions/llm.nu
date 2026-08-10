# 変更日時の新しい順にソートして一覧表示
def llm [target?: string] {
    if ($target | is-empty) {
        ls -l | sort-by modified -r
    } else {
        ls -l $target | sort-by modified -r
    }
}
