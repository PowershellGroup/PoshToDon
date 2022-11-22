# adding data into an existing hashtable 
# so it can be passed on to generate a query from it
function AddData {
    [Internal()]
    param(
        [hashtable] $Data,

        [Parameter(ValueFromPipeline, Mandatory)]
        [hashtable] $InputObject,

        [switch] $PassThru
    )

    $data.keys | ForEach-Object {
        $InputObject[$_] = $data[$_]
    }

    $InputObject
}