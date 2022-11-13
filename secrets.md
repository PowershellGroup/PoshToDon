### Setting up a secret store

#### Find a Secret Store for you:
https://github.com/PowerShell/SecretManagement
https://www.powershellgallery.com/packages?q=Tags%3A%22SecretManagement%22

#### install it
```
Install-Module -Name Microsoft.PowerShell.SecretManagement
Install-Module -Name Microsoft.PowerShell.SecretStore
Register-SecretVault -Name LocalStore -ModuleName Microsoft.PowerShell.SecretStore -DefaultVault
```
#### generate your secret


#### store your key
```
# put the guid in your script with get-secret
$guid = [guid]::NewGuid() |% Guid
Write-Host $guid

# u will be asked for the secret and a password for the vault
Set-Secret -Name:$guid -Vault:LocalStore 
```