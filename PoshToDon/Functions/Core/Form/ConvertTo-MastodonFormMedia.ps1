function ConvertTo-MastodonFormMedia {
    [Internal()]
    param(
        [string] $FilePath,
        [string] $Name = "file"
    )

    $baseName = Split-Path $FilePath -Leaf
    $fileBytes = [System.IO.File]::ReadAllBytes($FilePath);
    $fileEnc = [System.Text.Encoding]::GetEncoding('UTF-8').GetString($fileBytes)
    @(
        "Content-Disposition: form-data; name=`"$Name`"; filename=`"$baseName`"",
        "Content-Type: image/png",
        "",
        $fileEnc
    ) -join "`r`n"
}

