function ToQuery {
    # in: hashset
    # out: query string
    [Internal()]
    param(
        [Parameter(ValueFromPipeline, Mandatory)]
        [hashtable] $InputObject
    )

    $InputObject | ConvertTo-QueryParameters | ConvertTo-Query
}
