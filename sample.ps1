Import-Module .\PoshToDon -Verbose -Force

$script:clientKey = "<fillme>"
$script:clientSecret = "<fillme>"

Set-MastodonAppRegistration -ClientId:$script:clientKey -ClientSecret:$script:clientSecret -Instance:"<fillme>"
Connect-MastodonApplication -Email:"<fillme>" -Password:"<fillme>" -Scope "read", "write:statuses"

# Get-MastodonInstance

Get-MastodonNotifications -Limit 300 -ExcludeTypes favourite, mention | Format-Table