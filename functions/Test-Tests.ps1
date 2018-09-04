function Test-Tests
{
    [CmdletBinding()]

    param
    (
        [Parameter()]
        [ValidateSet('One', 'Two')]
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
}