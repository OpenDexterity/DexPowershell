$ErrorActionPreference = "Stop"

#Classes
. $PSScriptRoot\Classes.ps1

#region Test
. $PSScriptRoot\Test-DexDictionaryHeader.ps1
#endregion

#region Get
. $PSScriptRoot\Get-DexDictionaryBlockTable.ps1
#endregion