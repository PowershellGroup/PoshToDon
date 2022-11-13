# PoshToDon

Hey there. The thing you are looking at is a Mastodon Client written in PowerShell.  
Or it will be at some point in the future.

Everything here is currently **work in progress**.

Feel free to make pullrequests.

## Setting it up

You will need an Application Key and and Application Secret, which you can generate by adding an app in the developer section of your profile preferences.

Copy the `sample.ps1` and name it `script.ps1`.  
`script.ps1` is excluded from git, so it may contain some or your secrets, if you are not willing to put them in a secret store right away.

Check [secrets.md](secrets.md) to get hints on how to set up a secrets vault on your system.

Email and Password are your actual user credentials, you are using to log into mastodon.  
**NOTE: No MFA support yet™**

## Known Issues

- We use password authentication within the `Connect-MastodonApplication` function. This authentication type seems to be somewhat undocumented.
It was implemented after this example: https://github.com/glacasa/Mastonet/blob/111f2da9dde11d3406416252230e0b1544af356b/Mastonet/AuthenticationClient.cs#L74

  **This kind of authentication does not work with MFA!**