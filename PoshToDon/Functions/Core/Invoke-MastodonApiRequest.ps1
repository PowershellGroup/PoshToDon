# basic api call handling access token, data compression, route building and so.
function Invoke-MastodonApiRequest {
    [Internal()]
    param(
        [Parameter(Mandatory)]
        [MastodonSession] $Session,

        [ValidateSet("Post", "Get")]
        [string] $Method,
        
        [string] $Route,
        
        [Parameter(ParameterSetName = "ObjectData")]
        [Alias("ObjectData")]
        [hashtable] $Data,

        [Parameter(ParameterSetName = "FormData")]
        [string[]] $FormData,
        
        [hashtable] $Headers = @{}
    )

    if ($Session.AccessToken -and (-not $Headers['Authorization'])) {
        $Headers['Authorization'] = "Bearer $($Session.AccessToken)"
    }

    if (-not $Session.Instance) {
        throw "Mastodon Instance not set"
    }

    $invokeSplat = @{
        Method  = $Method
        Headers = $Headers
        Uri     = "https://$($Session.Instance)/$route"
    }

    if ($Data) {
        $invokeSplat['Body'] = $Data | Compress
    } elseif ($FormData) {
        $boundary = "----" + [System.Guid]::NewGuid().ToString()
        $invokeSplat['ContentType'] = "multipart/form-data; boundary=$boundary"
        $lf = "`r`n";
        $sb = [System.Text.StringBuilder]::new();
        $FormData.ForEach({
            $null = $sb.Append("--" + $boundary + $lf);
            $null = $sb.Append($_ + $lf);
            $null = $sb.Append("--" + $boundary + "--" + $lf)
        })

        $invokeSplat['Body'] = $sb.ToString();
        Write-Host $invokeSplat['Body']
        #return
    }

    Invoke-RestMethod @invokeSplat
}

# https://stackoverflow.com/a/50255917
# https://stackoverflow.com/questions/4238809/example-of-multipart-form-data/23517227#23517227

# $FilePath = 'c:\temp\temp.txt';
# $URL = 'http://your.url.here';

# $fileBytes = [System.IO.File]::ReadAllBytes($FilePath);
# $fileEnc = [System.Text.Encoding]::GetEncoding('UTF-8').GetString($fileBytes);
# $boundary = [System.Guid]::NewGuid().ToString(); 
# $LF = "`r`n";

# $bodyLines = ( 
#     "--$boundary",
#     "Content-Disposition: form-data; name=`"file`"; filename=`"temp.txt`"",
#     "Content-Type: application/octet-stream$LF",
#     $fileEnc,
#     "--$boundary--$LF" 
# ) -join $LF

# Invoke-RestMethod -Uri $URL -Method Post -ContentType "multipart/form-data; boundary=`"$boundary`"" -Body $bodyLines