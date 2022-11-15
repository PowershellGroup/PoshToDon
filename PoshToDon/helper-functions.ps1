# https://github.com/glacasa/Mastonet/blob/main/Mastonet/ArrayOptions.cs
function Get-MastodonArrayQueryParameters {
    [Internal()]
    param(
        [System.Nullable[long]] $MaxId,
        [System.Nullable[long]] $SinceId,
        [System.Nullable[long]] $MinId,
        [System.Nullable[int]] $Limit
    )
    
    @{
        max_id   = $MaxId
        since_id = $SinceId
        min_id   = $MinId
        limit    = $Limit
    } | ConvertTo-QueryParameters
}

# filters null elements form the data
# avoids checking every input for null in every method
function Compress-MastodonPostData {
    [Internal()]
    param(
        [Parameter(ValueFromPipeline)]
        [hashtable]$InputObject
    )

    $compressed = @{}
    $InputObject.Keys | ForEach-Object {
        if ($InputObject[$_]) {
            $compressed[$_] = $InputObject[$_]
        }
    }
    $compressed
}

function ConvertTo-QueryParameters {
    [Internal()]
    param(
        [Parameter(ValueFromPipeline)]
        [hashtable] $Data,

        [System.Collections.Generic.List[string]] $QueryParameters = [System.Collections.Generic.List[string]]::new()
    )

    $QueryParameters = [System.Collections.Generic.List[string]]::new()
    $data.keys | ForEach-Object {
        if ($null -eq $data[$_]) {
            return # end current foreach pass
        }

        if ($data[$_] -is [System.Collections.IEnumerable]) {
            foreach ($element in $data[$_]) {
                "$_[]=$element"
            }
        } else {
            "$_=$($data[$_])"
        }
    }
}

function ConvertTo-Query {
    [Internal()]
    param()

    begin {
        $argumentList = [System.Collections.Generic.List[string]]::new()
    }
    process {
        if ($_) {
            $argumentList.Add($_)
        } 
    }
    end {
        if ($argumentList.Length) {
            "?" + ( $argumentList | Join-String -Separator '&' )
        } 
    }
}
