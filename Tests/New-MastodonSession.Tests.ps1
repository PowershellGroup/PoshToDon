BeforeAll {
    Import-Module .\PoshToDon -Force
}

Describe 'New-MastodonSession' {
    It 'should create a session object' {
        $secret = "TestClientSecret" | ConvertTo-SecureString -AsPlainText
        $session = New-MastodonSession -ClientId "TestClientId" -ClientSecret $secret -Instance "test.instance" -PassThru
        $session.AppRegistration.client_id | Should -Be "TestClientId"
        $session.AppRegistration.client_secret | ConvertFrom-SecureString -AsPlainText | Should -Be "TestClientSecret"
        $session.Instance | Should -Be "test.instance"
    }
}