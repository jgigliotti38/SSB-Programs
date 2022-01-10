Get-WindowsOptionalFeature -Online -Featurename SMB1Protocol
Pause
Get-SmbServerConfiguration | Select-Object EnableSMB2Protocol
Pause
Get-SMBConnection | Select-Object ServerName, Signed, Dialect