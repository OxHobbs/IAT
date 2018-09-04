function Install-SCSM
{
    #change where share is however you see fit & same w/ config. 
    $servers = get-content \\server\share\servers.txt
    $config = "\\server\share\scsm.ini"

    $servers | % { 
    copy-item -path \\server\share\example.exe -destination \\$_\c$\windows\temp\example.exe 
    }

    Invoke-Command $variables { start-process -path c:\windows\temp\example.exe -argument list '/S /v/qn' -verb runAs -wait }

    $servers | % { 
    copy-item -force -path $config -destination "\\$_\c$\program files\logrhythm\logrhythm system monitor\config\" 
    }

    set-service -computername $servers -name scsm -status running -startuptype automatic
}
