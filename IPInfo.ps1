#Get IP
if ($args[0] -eq $null) {
    $ipAddress = Read-Host 'Enter IP Address'
}
else {$ipAddress = $args[0]}

# Validate IP format
try {
    if ([IPAddress] $ipAddress -as [bool]) {}
}
catch {
    Write-Host 'Invalid IP Address'
    exit
}

# Validate if IP is routable
if ($ipAddress -Match '(^127\.)|(^192\.168\.)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)') {
    Write-Output 'Non-routable IP address.'
    exit
}

# Create IP info object


# Get hops to destination
$hops = (Test-NetConnection -TraceRoute $ipAddress).traceroute.count

# Get average response time (rounded)
$responseTime = (Test-Connection $ipAddress -Count 10  | measure-Object -Property ResponseTime -Average).average

# Build IPInfo Object
$ipInfo = [PSCustomObject]@{
    Name     = 'IP Info'
    Hops     = $hops
    AvgPing  = $responseTime
}


Write-Output Get-Member $ipInfo