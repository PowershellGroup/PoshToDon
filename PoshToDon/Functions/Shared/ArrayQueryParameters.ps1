# get hashtable from array-query parameters, to convert them into a query
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
