# list to query
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