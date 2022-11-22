# filters null elements form the data
# avoids checking every input for null in every method
function Compress {
    [Internal()]
    param(
        [Parameter(ValueFromPipeline, Mandatory)]
        [hashtable]$InputObject
    )

    $compressed = [ordered]@{}
    $InputObject.Keys | ForEach-Object {
        if ($InputObject[$_]) {
            $compressed[$_] = $InputObject[$_]
        }
    }
    $compressed
}