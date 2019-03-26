$here = Split-Path -Parent $MyInvocation.MyCommand.Path
$sut = (Split-Path -Leaf $MyInvocation.MyCommand.Path) -replace '\.Tests\.', '.'
. "$here\..\src\public\$sut"

Describe "Invoke-dotnetMethod" {
    It "Invokes parameter-less .NET instance methods" {
        ' i ' | Invoke-dotnetMethod Trim | Should -Be 'i'
    }

    It "Invokes .NET instance methods with positional parameters" {
        32 | Invoke-dotnetMethod ToString 'X2' | Should -Be '20'
    }

    It "Invokes .NET instance methods with named parameters" {
        32 | Invoke-dotnetMethod ToString -Parameters @{format = 'X2'} | Should -Be '20'
    }
}
