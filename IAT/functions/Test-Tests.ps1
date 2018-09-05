function Test-Tests
{
    [CmdletBinding()]

    param
    (
        [Parameter()]
        [ValidateSet('One', 'Two', 'Three')]
        [String]
        $Branch
    )

    if ($Branch -eq 'One')
    {
        Write-Output "Branch1"
    }
    elseif ($Branch -eq 'Two')
    {
        Write-Output "Branch2"
    }
    elseif ($Branch -eq 'Three')
    {
        Write-Output 'Branch3'
    }
}