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