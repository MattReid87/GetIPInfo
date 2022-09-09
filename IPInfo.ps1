#Get IP Address
if ($args[0] -eq $null) {
    $ipaddress = Read-Host "Enter IP Address"
}
else {$ipaddress = $args[0]}

Write-Host $ipaddress