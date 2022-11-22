# hashtable to list
function ConvertTo-QueryParameters {
    [Internal()]
    param(
        [Parameter(ValueFromPipeline, Mandatory)]
        [hashtable] $Data
    )

    # sorting required for deterministic testing. 
    # hashtable yields random key order.
    $data.keys | Sort-Object | ForEach-Object {
        # ignore 'not a value'
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