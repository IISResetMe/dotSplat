$PublicFunctions = Get-ChildItem $PSScriptRoot\public\*.ps1
foreach($Function in $PublicFunctions)
{
    . $Function.FullName
}

Export-ModuleMember $PublicFunctions.BaseName