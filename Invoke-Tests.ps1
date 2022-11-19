#Requires -Modules Pester -PSEdition Core

param(
    [ValidateSet('Detailed', 'Diagnostic', 'Minimal', 'None', 'Normal')]
    $Output = 'Detailed'
)

Invoke-Pester -Output:$Output $PSScriptRoot

# Writing Tests for and with Modules
# https://pester.dev/docs/usage/modules
