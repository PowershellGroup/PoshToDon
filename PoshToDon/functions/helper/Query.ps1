function ConvertTo-QueryParameters {
    [Internal()]
    param(
        [Parameter(ValueFromPipeline, Mandatory)]
        [hashtable] $Data
    )

    $data.keys | ForEach-Object {
        if ($null -eq $data[$_]) {
            return # end current foreach pass
        }

        if ($data[$_] -is [array]) {
            foreach ($element in $data[$_]) {
                "$_[]=$element"
            }
        } else {
            "$_=$($data[$_])"
        }
    }
}

# https://github.com/glacasa/Mastonet/blob/main/Mastonet/ArrayOptions.cs
function ArrayQueryParameters {
    [Internal()]
    param(
        [System.Nullable[long]] $MaxId,
        [System.Nullable[long]] $SinceId,
        [System.Nullable[long]] $MinId,
        [System.Nullable[int]] $Limit
    )

    [hashtable] $PSBoundParameters
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