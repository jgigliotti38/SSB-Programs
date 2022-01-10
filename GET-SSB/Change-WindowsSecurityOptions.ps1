<##>


# disable netbios
$credential = Get-Credential

$ReportPath = "C:\Users\jagadm\Desktop\WORK\SSBCOMPUTERINFO\Get-SSB\REPORTS"

Get-Content -Path "$ReportPath\NETBIOS\DEFAULT.txt"

(Get-Content -Path $ReportPath\NETBIOS\DEFAULT.txt) |
    ForEach-Object {$_ -Replace '====DEFAULT====', ''} |
        Set-Content -Path $ReportPath\NETBIOS\DEFAULT.txt
Get-Content -Path $ReportPath\NETBIOS\DEFAULT.txt


$s = Get-Content "$ReportPath\NETBIOS\DEFAULT.txt" |  New-PSSession -ThrottleLimit 50 -Credential $credential 
Invoke-Command -Session $s -ScriptBlock {
    $key = "HKLM:SYSTEM\CurrentControlSet\services\NetBT\Parameters\Interfaces"
    Get-ChildItem $key |
    ForEach-Object { Set-ItemProperty -Path "$key\$($_.pschildname)" -Name NetbiosOptions -Value 2 -Verbose}
}
Get-PSSession | Remove-PSSession

# disable wpad


# Change SMB1
Set-SMBServerConfiguration -EnableSMB1Protocol $True -Force
Pause


# Tests if IPv6 is Enabled
Get-NetAdapterBinding -ComponentID ms_tcpip6

# Disables IPv6 by Network Adapter Name
Disable-NetAdapterBinding -InterfaceAlias "*" -ComponentID ms_tcpip6


# Get ODBC Configuration
<#
$credential = Get-Credential
$s = Get-Content $MainPath |  New-PSSession -Credential $credential 
Invoke-Command -Session $s -ScriptBlock {
    Get-OdbcDsn -DriverName "SQL Server"
}
Get-PSSession | Remove-PSSession
Pause
#>

# Status Bar
<#
for ($i = 1; $i -le 100; $i++ )
{
    Write-Progress -Activity "Search in Progress" -Status "$i% Complete:" -PercentComplete $i
    Start-Sleep -Milliseconds 250
}#>