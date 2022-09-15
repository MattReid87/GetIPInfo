#Requires -Version 3
<#
.SYNOPSIS
  Gathers information about the requested IP address.
.DESCRIPTION
  Confirms valid internet routable IP address.  Checks the numbers of hops from local system as well as average response of 10 pings.  Uses multiple APIs to look up further information such as Owner, ISP, geographical and time information of the IP address.
.PARAMETER IPAddress
    IP address to get information about.
.PARAMETER json
    Outputs results in json format
.INPUTS
  None
.OUTPUTS
  None
.NOTES
  Version:        1.0
  Author:         Matt Reid
  Creation Date:  9/13/2022
  Purpose/Change: Initial script development
  
.EXAMPLE
  Get-IPInfo 151.101.1.140 -json
#>

function Get-IPInfo {
  param (
    [switch]$json
  )
  #Get IP
  if ($null -eq $args[0]) {
    $ipAddress = Read-Host 'Enter IP Address'
  }
  else {$ipAddress = $args[0]}

  $ipAddress = $ipAddress.trim()

  # Validate IP format
  try {
    if ([IPAddress] $ipAddress -as [bool]) {}
  }
  catch {
    Write-Output 'Invalid IP Address'
    exit
  }

  # Validate if IP is routable
  if ($ipAddress -Match '(^127\.)|(^192\.168\.)|(^10\.)|(^172\.1[6-9]\.)|(^172\.2[0-9]\.)|(^172\.3[0-1]\.)') {
    Write-Output 'Non-routable IP address.'
    exit
  }

  # Build IPInfo Object
  $ipInfo = [PSCustomObject]@{
  Name     = 'IP Info'
  IP       = $ipAddress
  }

  # Hide progress bar
  $Global:ProgressPreference = 'SilentlyContinue'

  # Get hops to destination and add to object
  $hops = (Test-NetConnection -TraceRoute $ipAddress).traceroute.count
  $ipInfo | Add-Member -NotePropertyName Hops -NotePropertyValue $hops

  # Get average response time and add to object
  $responseTime = (Test-Connection $ipAddress -Count 10  | measure-Object -Property ResponseTime -Average).average
  $ipInfo | Add-Member -NotePropertyName AvgResponse -NotePropertyValue $responseTime

  # Get IP inforamtion from IP APIs
  # ToDo: Better error handling/messages

  # Try to get geographical information about IP address
  try{
  $geoInfo = Invoke-RestMethod -Method Get -Uri "http://ip-api.com/json/$ipaddress"
  }
  catch{
  Write-Output "Error retrieving IP information from ip-api.com API"
  }

  # Try to get registration information about IP
  try{
  $ISPInfo= Invoke-RestMethod -Method Get -Uri "http://whois.arin.net/rest/ip/$ipaddress"
  }
  catch{
  Write-Output "Error retrieving IP information from whois.arin.net API"
  }

  # Try to get weather information about IP
  try{
  $weatherUrl = "https://api.open-meteo.com/v1/forecast?latitude={0}&longitude={1}&current_weather=true&temperature_unit=fahrenheit" -f $geoInfo.lat, $geoinfo.lon
  $weatherInfo = Invoke-RestMethod -Method Get -Uri $weatherUrl
  }
  catch{
  Write-Output "Error retrieving IP information from api.open-meteo.com API"
  }

  # Try to get time information about IP 
  try{
  $timeUrl = "http://worldtimeapi.org/api/timezone/{0}" -f $geoInfo.timezone
  $timeInfo = Invoke-RestMethod -Method Get -Uri $timeUrl
  }
  catch{
  Write-Output "Error retrieving IP information from worldtimeapi.org API"
  }

  # Unhide progress bar
  $Global:ProgressPreference  = 'Continue' 

  # Add API responsees to IP Info object
  # ToDo: Clean up object generation
  $ipInfo | Add-Member -NotePropertyName NetblockOwner -NotePropertyValue $ISPInfo.net.name
  $ipInfo | Add-Member -NotePropertyName ISP -NotePropertyValue $geoInfo.isp
  $ipInfo | Add-Member -NotePropertyName AS -NotePropertyValue $geoInfo.as
  $ipInfo | Add-Member -NotePropertyName Lat -NotePropertyValue $geoInfo.lat
  $ipInfo | Add-Member -NotePropertyName Lon -NotePropertyValue $geoInfo.lon
  $ipInfo | Add-Member -NotePropertyName City -NotePropertyValue $geoInfo.city
  $ipInfo | Add-Member -NotePropertyName State -NotePropertyValue $geoInfo.regionName
  $ipInfo | Add-Member -NotePropertyName Zip -NotePropertyValue $geoInfo.zip
  $ipInfo | Add-Member -NotePropertyName CurrentTempF -NotePropertyValue $WeatherInfo.current_weather.temperature
  $ipInfo | Add-Member -NotePropertyName CurrentTime -NotePropertyValue ([DateTimeOffset]$timeInfo.datetime).DateTime

  # Display IP information (human readable)
  if ($json -eq $false) {
    "You are {0} hops away from {1} with an average ping of {2}." -f $ipInfo.Hops, $ipInfo.IP, $ipInfo.AvgResponse
    "The owner of the netblock is {0}, their ISP is {1} and AS number is {2}." -f $ipInfo.NetblockOwner, $ipInfo.ISP, $ipInfo.AS
    "This IP originates from {0}, {1}, where the current date and time is {2} and the temperature is {3}F." -f $ipInfo.City, $ipInfo.State, $ipInfo.CurrentTime, $ipInfo.CurrentTempF
  }
  # Display IP information (json)
  if ($json -eq $true){
    $ipInfo | ConvertTo-Json
  }
}