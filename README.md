# IPInfo



# ToDo
* Accepts an IP Address as an Input Parameter
  * Prompt for the IP if it isn't given as a commandline option
  * Enforce that the input is a Valid, internet-routable IP address and tell the user if it's not
* Output the number of hops between the computer running the script and the input IP
* Output the average latency of 10 pings to the IP
* Give information about the IP entered in a friendly manner (sentences):
  * Owner of the netblock
  * Geo-location information 
  * What ISP, who owns the AS Number, etc
  * Local time and Weather for the Geo-Loc of the IP
* An optional second commandline parameter to the script that instead outputs all the requested info as a JSON object
