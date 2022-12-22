#Requires -PSEdition Core
#-Requires -Modules TUN.CredentialManager

param(
    [switch] $Init,
    [switch] $Dump,
    [switch] $Test,
    [switch] $Media,
    [switch] $Session
)

if ($Init) {
    Import-Module .\PoshToDon -Force

    $scope = "read", "write"
    $instance = "home.social"
    # $email = Get-Secret -Vault PoshToDon -Name "$instance|email"
    # $password = Get-Secret -Vault PoshToDon -Name "$instance|password"

    $clientKey = Get-Secret -Vault PoshToDon -Name "$instance|key" | ConvertFrom-SecureString -AsPlainText
    $clientSecret = Get-Secret -Vault PoshToDon -Name "$instance|secret"

    New-MastodonSession -ClientId:$clientKey -ClientSecret:$clientSecret -Instance:$instance
    Connect-MastodonApplication -Scope:$scope # -Email:$email -Password:$password
}

if ($Dump) {
    Get-MastodonInstance

    Get-MastodonNotification

    Get-MastodonCustomEmojis

    #Get-MastodonNotifications -Session:$session1 -Limit 300 -MaxId 87886 -ExcludeTypes favourite, mention | Format-Table

    355424 | Get-MastodonNotification
}

if ($Media) {
    New-MastodonMedia -ImagePath (Join-Path $PSScriptRoot "Assets" "PoshGurl.png")
}

if ($Session) {
    $scope = "read", "write"
    $instance2 = "norden.social"
    $clientKey2 = Get-Secret -Vault PoshToDon -Name "$instance2|key" | ConvertFrom-SecureString -AsPlainText
    $clientSecret2 = Get-Secret -Vault PoshToDon -Name "$instance2|secret"
    # $email = Get-Secret -Vault PoshToDon -Name "$instance2|email"
    # $password2 = Get-Secret -Vault PoshToDon -Name "$instance2|password"

    $session2 = New-MastodonSession -ClientId:$clientKey2 -ClientSecret:$clientSecret2 -Instance:$instance2 -PassThru
    Connect-MastodonApplication -Session:$session2 -Scope:$scope # -Email:$email -Password:$password2
    Get-MastodonNotification -Session:$session2 -Limit 300 -MaxId 87886 -ExcludeTypes favourite, mention | Format-Table

    $session2 | Get-MastodonInstance | ForEach-Object name
}

if ($Test) {
    $MyInvocation | ConvertTo-Json -Depth 1
    # Write-Host $fname

    # $null = New-Item -Path function: -Name "local:$fname" -Value { Write-Host "lol2" } -Force
}