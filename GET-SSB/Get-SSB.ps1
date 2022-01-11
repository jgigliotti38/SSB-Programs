#Get-WindowsSecurityOptions.ps1
#
# NetBios
# WPAD
# LLMNR
# SMB1,SMB2,SMB3
# ODBC Settings
#

# Universal Variables
$DeviceTextPath = "C:\Users\jagadm\Desktop\WORK\TXT\SSBDevices.txt" 
$ReportPath = "C:\Users\jagadm\Desktop\WORK\REPORTS"
$TOTAL = (Get-Content -Path $DeviceTextPath).Count

# Functions
function Get-Netbios {
    # ********** NETBIOS **********
    # *** 0 = Default
    # *** 1 = Enabled
    # *** 2 = Disabled

    $ENABLED = 0
    $DISABLED = 0
    $DEFAULT = 0
    $ERR = 0
    $FINISHED = 0

    ## initialize report folders
    Remove-Item -Path $ReportPath\NETBIOS -Recurse
    New-Item -Path $ReportPath -Name "NETBIOS\ENABLED" -ItemType "directory"
    New-Item -Path $ReportPath -Name "NETBIOS\DISABLED" -ItemType "directory"
    New-Item -Path $ReportPath -Name "NETBIOS\DEFAULT" -ItemType "directory"
    New-Item -Path $ReportPath -Name "NETBIOS\ERROR" -ItemType "directory"

    ## initialize reports
    out-file -FilePath $ReportPath\NETBIOS\ENABLED.txt
    Add-Content -Path $ReportPath\NETBIOS\ENABLED.txt -Value "`nENABLED`n============"
    out-file -FilePath $ReportPath\NETBIOS\DISABLED.txt
    Add-Content -Path $ReportPath\NETBIOS\DISABLED.txt -Value "`nDISABLED`n============"
    out-file -FilePath $ReportPath\NETBIOS\DEFAULT.txt
    Add-Content -Path $ReportPath\NETBIOS\DEFAULT.txt -Value "====DEFAULT===="
    out-file -FilePath $ReportPath\NETBIOS\ERROR.txt
    Add-Content -Path $ReportPath\NETBIOS\ERROR.txt -Value "`nERROR`n============"

    ## read .txt files
    Get-Content -Path $DeviceTextPath | ForEach-Object {
        [string]$Setting = Get-WMIObject win32_networkadapterconfiguration -ComputerName $_ -filter 'IPEnabled=true' -ErrorAction SilentlyContinue | Select-Object TcpipNetbiosOptions
        
        if ($Setting -eq "@{TcpipNetbiosOptions=2}") {
            #Write-Host "$_ Setting DISABLED"
            Add-Content -Path $ReportPath\NETBIOS\DISABLED.txt -Value "$_"
            $DISABLED += 1
        }elseif ($Setting -eq "@{TcpipNetbiosOptions=1}") {
            #Write-Host "$_ Setting ENABLED"
            Add-Content -Path $ReportPath\NETBIOS\ENABLED.txt -Value "$_"
            $ENABLED += 1
        }elseif ($Setting -eq "@{TcpipNetbiosOptions=0}") {
            #Write-Host "$_ Setting DEFAULT"
            Add-Content -Path $ReportPath\NETBIOS\DEFAULT.txt -Value "$_"
            $DEFAULT += 1
        }else {
            #Write-Host "ERROR"
            Add-Content -Path $ReportPath\NETBIOS\ERROR.txt -Value "$_"
            $ERR += 1
        }

        Clear-Host
        Write-Host "NETBIOS SETTINGS"
        Write-Host "Please Wait..."
        $FINISHED += 1
        $PERCENTAGE = ($FINISHED/$TOTAL)*100
        $PERCENTAGE = [math]::Round($PERCENTAGE)
        Write-Host "$PERCENTAGE % COMPLETE"
    }
    
    ## combine reports
    $Report = Get-Content -Path $ReportPath\NETBIOS\*.txt
    Out-File -FilePath $ReportPath\NETBIOS\REPORT.txt
    Add-Content -Path $ReportPath\NETBIOS\REPORT.txt -Value "NETBIOS REPORT`n********************"
    Add-Content -Path $ReportPath\NETBIOS\REPORT.txt -Value $Report

    Add-Content -Path $ReportPath\NETBIOS\REPORT.txt -Value "`nDISABLED: $DISABLED"
    Add-Content -Path $ReportPath\NETBIOS\REPORT.txt -Value "ENABLED: $ENABLED"
    Add-Content -Path $ReportPath\NETBIOS\REPORT.txt -Value "DEFAULT: $DEFAULT"
    Add-Content -Path $ReportPath\NETBIOS\REPORT.txt -Value "ERROR: $ERR" 
    
    ## get final report
    #Start-Process notepad++ "$ReportPath\NETBIOS\REPORT.txt"
    #Get-Content -Path "$ReportPath\NETBIOS\REPORT.txt" | Out-Printer
    Write-Host "DISABLED: $DISABLED"
    Write-Host "ENABLED: $ENABLED"
    Write-Host "DEFAULT: $DEFAULT"
    Write-Host "ERROR: $ERR" 
    $print = Read-Host "`nType 'Print' to Print Report"
    if ($print -eq "Print") { Get-Content -Path "$ReportPath\NETBIOS\REPORT.txt" | Out-Printer }

}
function Get-WPAD {
    # ********** WPAD **********
    #Get-ItemProperty 'Registry::HKCU\Software\Microsoft\Windows\CurrentVersion\Internet Settings' | Select-Object *Proxy*
    #Get-ItemProperty 'Registry::HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Services\WinHttpAutoProxySvc' | Select-Object Start
    #Get-Service -ComputerName "MJ08T5B0" "*WinHTTP*" | Select-Object Status
    
    $ENABLED = 0
    $DISABLED = 0
    #$DEFAULT = 0
    $ERR = 0
    $FINISHED = 0

    ## initialize report folders
    Remove-Item -Path $ReportPath\WPAD -Recurse
    New-Item -Path $ReportPath -Name "WPAD\ENABLED" -ItemType "directory"
    New-Item -Path $ReportPath -Name "WPAD\DISABLED" -ItemType "directory"
    New-Item -Path $ReportPath -Name "WPAD\DEFAULT" -ItemType "directory"
    New-Item -Path $ReportPath -Name "WPAD\ERROR" -ItemType "directory"

    ## initialize reports
    out-file -FilePath $ReportPath\WPAD\ENABLED.txt
    Add-Content -Path $ReportPath\WPAD\ENABLED.txt -Value "`nENABLED`n============"
    out-file -FilePath $ReportPath\WPAD\DISABLED.txt
    Add-Content -Path $ReportPath\WPAD\DISABLED.txt -Value "`nDISABLED`n============"
    out-file -FilePath $ReportPath\WPAD\ERROR.txt
    Add-Content -Path $ReportPath\WPAD\ERROR.txt -Value "`nERROR`n============"
    
    ## read .txt files
    Get-Content -Path $DeviceTextPath | ForEach-Object {
        [string]$Setting = Get-Service -ComputerName $_ "*WinHTTP*" | Select-Object Status -ErrorAction SilentlyContinue
        if ($Setting -eq "@{Status=Stopped}") {
            #Write-Host "$_ WPAD Setting DISABLED"
            Add-Content -Path $ReportPath\WPAD\DISABLED.txt -Value $_
            $DISABLED += 1
        } elseif ($Setting -eq "@{Status=Running}") {
            #Write-Host "$_ WPAD Setting ENABLED"
            Add-Content -Path $ReportPath\WPAD\ENABLED.txt -Value $_
            $ENABLED += 1
        } else {
            #Write-Host "$_ ERROR"
            Add-Content -Path $ReportPath\WPAD\ERROR.txt -Value $_
            $ERR += 1
        }

        Clear-Host
        Write-Host "WPAD SETTINGS"
        Write-Host "Please Wait..."
        $FINISHED += 1
        $PERCENTAGE = ($FINISHED/$TOTAL)*100
        $PERCENTAGE = [math]::Round($PERCENTAGE)
        Write-Host "$PERCENTAGE % COMPLETE"
    }

    ## combine reports
    $Report = Get-Content -Path $ReportPath\WPAD\*.txt
    Out-File -FilePath $ReportPath\WPAD\REPORT.txt
    Add-Content -Path $ReportPath\WPAD\REPORT.txt -Value "WPAD REPORT`n********************"
    Add-Content -Path $ReportPath\WPAD\REPORT.txt -Value $Report

    Add-Content -Path $ReportPath\WPAD\REPORT.txt -Value "`nDISABLED: $DISABLED"
    Add-Content -Path $ReportPath\WPAD\REPORT.txt -Value "ENABLED: $ENABLED"
    Add-Content -Path $ReportPath\WPAD\REPORT.txt -Value "ERROR: $ERR" 

    ## get final report
    #Start-Process notepad++ "$ReportPath\WPAD\REPORT.txt"
    Write-Host "DISABLED: $DISABLED"
    Write-Host "ENABLED: $ENABLED"
    Write-Host "ERROR: $ERR"
    $print = Read-Host "`nType 'Print' to Print Report"
    if ($print -eq "Print") { Get-Content -Path "$ReportPath\WPAD\REPORT.txt" | Out-Printer }
}
function Get-SophosAutoUpdate {

    Get-Content -Path $DeviceTextPath | ForEach-Object {
        $Status = Get-Service -ComputerName $_ "Sophos AutoUpdate Service" | Select-Object Status -ErrorAction SilentlyContinue
        Write-Host $_
        Write-Host $Status
        Write-Host "========="
    }
}
function Get-SophosFileScannerService {
    Write-HOst "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
    Get-Content -Path $DeviceTextPath | ForEach-Object {
        [string]$Status = Get-Service -ComputerName $_ "Sophos File Scanner Service" | Select-Object Status -ErrorAction SilentlyContinue
      
        if ($Status -eq "@{Status=Stopped}") {
            Write-Host $_
            Write-Host $Status
            Write-Host "========="
        }
    }
}
function Start-SophosFileScannerService {
    Write-HOst "%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%"
    Get-Content -Path $DeviceTextPath | ForEach-Object {
        Write-Host "===="
        Write-Host $_
        Get-Service -ComputerName "$_" -Name "Sophos File Scanner Service" | Start-Service -Verbose
    }        
}
function Get-IPv6 {
    #Get-NetAdapterBinding
    #Get-NetAdapterBinding -DisplayName 'Internet Protocol Version 4 (TCP/IPv4)'
    #Get-NetAdapterBinding -DisplayName 'Internet Protocol Version 6 (TCP/IPv6)' 
    Get-NetAdapterBinding -DisplayName "Internet*"

    #get encrypted credentials
    $user = "Sewickley\Administrator"
    $password = ConvertTo-SecureString (Unprotect-CmsMessage -Path C:\Users\jagadm\Desktop\_Encryption\pwd.txt) -AsPlainText -Force
    $credential = New-Object System.Management.Automation.PSCredential ($user,$password)

    #basic session opened to remote device
    #$computer = Read-Host -Prompt 'COMPUTER:'
    #$session = New-PSSession -ComputerName $computer -Credential $credential -Verbose
    #New-PSSession -ComputerName $computer -Credential $credential -Verbose
    
    Get-Content -Path $DeviceTextPath | ForEach-Object {
        Write-Host "===$_==="
        $Session = New-PSSession -ComputerName $_ -Credential $credential -Verbose
        Invoke-Command -Session $session -ScriptBlock {Get-NetAdapterBinding -DisplayName 'Internet Protocol Version 6 (TCP/IPv6)'}
    }
    Write-Host "COMPLETE!!!"
    Pause
    Remove-PSSession -Session (Get-PSSession)
}
function showHome {
    Write-Host "CHOOSE OPTION BELOW"
    Write-Host "==================="
    Write-Host "1.) Get-NetBios"
    Write-Host "2.) Get-WPAD"
    Write-Host "3.) Get-SophosFileScannerService"
    Write-Host "4.) Start-SophosFileScannerService"
    Write-Host "5.) Get-IPv6"
    Write-Host "0.) EXIT"
}
# **************************************************************
$choice = -1
Write-Host $choice
while ($choice -ne "0") {
    Clear-Host
    showHome
    $choice = Read-Host

    if ($choice -eq "1") {
        Get-NetBios
        #Write-Host "Choice 1 Selected"
        Pause
    } if ($choice -eq "2") {
        Get-WPAD
        #Write-Host "Choice 2 Selected"
        Pause
    } if ($choice -eq "3") {
        Get-SophosFileScannerService
        #Write-Host "Choice 4 Selected"
        Pause
    } if ($choice -eq "4") {
        Start-SophosFileScannerService
        #Write-Host "Choice 5 Selected"
        Pause
    } if ($choice -eq "5") {
        Get-IPv6
        #Write-Host "Choice 6 Selected"
        Pause
    }
}
Clear-Host

# ********** ODBC *********
#Get-OdbcDsn
#Get-OdbcDsn -DriverName "SQL Server"
