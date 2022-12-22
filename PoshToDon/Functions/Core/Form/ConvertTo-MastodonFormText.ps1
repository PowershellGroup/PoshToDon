function ConvertTo-MastodonFormText {
    [Internal()]
    param([string] $Content, [string] $Name)
    @(
        "Content-Disposition: form-data; name=`"$Name`"",
        "",
        $Content
    ) -join "`r`n"
}

