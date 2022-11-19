### Setting up a secret store

#### Find a Secret Store for you:
https://github.com/PowerShell/SecretManagement
https://www.powershellgallery.com/packages?q=Tags%3A%22SecretManagement%22

#### install it
```powershell
Install-Module -Name Microsoft.PowerShell.SecretManagement
Install-Module -Name Microsoft.PowerShell.SecretStore
Register-SecretVault -Name LocalStore -ModuleName Microsoft.PowerShell.SecretStore -DefaultVault
```
#### generate your secret
```powershell
Register-SecretVault -Name "PoshToDon" -ModuleName Microsoft.PowerShell.SecretStore
Set-Secret -Vault PoshToDon -Name $secretName -Secret "my very secret password"
Get-Secret -Vault PoshToDon -Name $secretName # returns secure string usable as secret or passwort
```