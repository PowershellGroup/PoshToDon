# https://jdhitsolutions.com/blog/powershell/7937/creating-powershell-property-names/
function Convert-PropertyName {
    [Internal()]
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string] $Name,

        # the character used as a delimiter in the native property name
        [string] $Delimiter = '_'
    )

    # split on the underscore delimiter
    $name.Split($Delimiter) | ForEach-Object {
        "{0}{1}" -f $_[0].ToString().ToUpper(), $_.Substring(1)
    } | Join-String
}