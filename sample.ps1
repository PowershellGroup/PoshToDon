Import-Module .\PoshToDon.psm1 -Verbose -Force

$script:clientKey = "<fillme>"
$script:clientSecret = "<fillme>"

Set-MastodonAppRegistration -ClientId:$script:clientKey -ClientSecret:$script:clientSecret -Instance:"<fillme>"
Connect-MastodonApplication -Email:"<fillme>" -Password:"<fillme>"
Get-MastodonInstance