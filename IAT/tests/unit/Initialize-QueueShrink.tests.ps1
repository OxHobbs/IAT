$here = Split-Path -Parent $MyInvocation.MyCommand.Path
. "$here\..\..\helpers\Initialize-QueueShrink.ps1"

Describe 'Initialize-QueueShrink' {
    Context 'When files do not exist' {
        Mock Get-StartItemCount { 0 }
    }
}

Describe 'Get-StartItemCount' {
    Context 'When files are in path' {
        Mock 'Get-ChildItem'  {@(
                'File1',
                'File2'
            )}

        It 'Should return 2 when two items are in the result' {
            Get-StartItemCount | Should -Be 2
        }        
    }

    Context 'When no files are in path' {
        Mock 'Get-ChildItem' { @() }

        It 'Should return 0 when no files are in path' {
            Get-StartItemCount | Should -Be 0
        }
    }

}
