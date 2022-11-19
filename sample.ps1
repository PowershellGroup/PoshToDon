param(
    [ValidateSet(1,2)]
    $Sample = 1
)
Import-Module .\PoshToDon -Verbose -Force

switch ($Sample) {
    1 {
        $clientKey = "<fillme>"
        $clientSecret = "<fillme>"
        $instance = "<fillme>"
        $email = "<fillme>"
        $password = "<fillme>"
        $scope = "read", "write:statuses"

        # create a session (data is not validated yet)
        $session = New-MastodonSession -ClientId:$clientKey -ClientSecret:$clientSecret -Instance:$instance -PassThru

        # connect to user-api
        # app data is used in combination with user data to authenticate and get an access-token
        Connect-MastodonApplication -Session:$Session -Email:$email -Password:$password -Scope:$scope

        # sample how to fetch notifications
        Get-MastodonNotifications -Session:$Session -Limit 300 -ExcludeTypes favourite, mention | Format-Table

        # session can be passed in and will be used then, but a new session is always stored internally as well.
        # this way you can authenticate with multiple servers at the same time

        # this works as well:
        # New-MastodonSession -ClientId:$clientKey -ClientSecret:$clientSecret -Instance:"home.social" -PassThru
        # Connect-MastodonApplication -Email:"<fillme>" -Password:"<fillme>" -Scope "read", "write"
        # Get-MastodonNotifications -Limit 300 -MaxId 87886 -ExcludeTypes favourite, mention | Format-Table
    }
    2 {
        $clientKey = "<fillme>"
        $clientSecret = "<fillme>"
        $instance = "<fillme>"
        $scope = "read", "write:statuses"

        # using the default-session stored in module-memory
        New-MastodonSession -ClientId:$clientKey -ClientSecret:$clientSecret -Instance:$instance

        # connect to user-api
        # a browser window will be opened, showing a code you can enter via console, in order to authenticate
        Connect-MastodonApplication -Scope:$scope

        # sample how to fetch notifications
        Get-MastodonNotifications -Limit 300 -ExcludeTypes favourite, mention | Format-Table

        Get-MastodonInstance

        Get-MastodonCustomEmojis
    }
}


