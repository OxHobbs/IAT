$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\..\..\functions\Test-Tests.ps1"

Describe 'Test-Tests' {
    Context 'Valid Params' {
        It 'should output the correct branch1' {
            Test-Tests -Branch 'One' | Should -Be 'Branch1'
        }
        
        It 'should output 3' {
            Test-Tests -Branch 'Three' | Should -Be 'Branch3'
        }
        
        It 'should output branch2 corrently' {
            Test-Tests -Branch 'Two' | Should -Be 'Branch2'
        }
    }

    Context 'Invalid params' {
        It 'should throw if not in set of One, Two' {
            { Test-Tests -Branch 'Four' } | Should -Throw 
        }
    }





}