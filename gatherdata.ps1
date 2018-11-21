$computername = "SKWSX36090"
Get-WmiObject -query "select * from Win32_ComputerSystem" -ComputerName $computername
Get-WmiObject -query "select * from Win32_OperatingSystem"  -ComputerName $computername
Get-WmiObject -query "select * from Win32_LogicalDisk where DriveType=3" -ComputerName $computername

write-host "network setting"
$networksFile = "gather_networks.out"

"network setting" | out-file -filepath $networksFile
$adapters = Get-NetAdapter
foreach ($adapter in $adapters) {
	$adapter.Name | out-file -filepath $networksFile -append
    Get-NetAdapterAdvancedProperty -Name $adapter.Name | out-file -filepath $networksFile -append
	Get-NetIPAddress -InterfaceAlias $adapter.Name | out-file -filepath $networksFile -append
}

Sewrite-host press enter ...
read-host

# Get-WmiObject -Class Win32_Product | Select Name,Version | FOrmat-table
Get-WmiObject -Class Win32_Product | FOrmat-table > gather_software.out

write-host "user setting"
$usersFile = "gather_users.out"
$groups = Get-Localgroup
foreach ($group in $groups) {
	"group :$group" | out-file -filepath $usersFile -append
	$users = Get-LocalgroupMember -Group $group
	foreach ($user in $users) {
		"u: $user" | out-file -filepath $usersFile -append
	}
}


write-host "network status"
netstat -anonp TCP > gather_netstat.out

write-host "firewall setting"
netsh advfirewall firewall show rule name=all type=dynamic > gather_firewallRules.out
Get-NetFirewallRule |Select Profile, Direction, Action, DisplayName > gather_firewallRules_review.out

$eventsFile = "gather_events.out"
write-host "event log setting"
Get-EventLog -list > gather_eventlog.out
$eventlogs = Get-EventLog -list
# start-transcript -path gather_events.out -append
"Eventlogs:" | out-file -filepath $eventsFile 
foreach ($eventlog in $eventlogs) {
	$eventlog.log | out-file -filepath $eventsFile  -append
	Get-EventLog -log $eventlog.log | out-file -filepath $eventsFile -append
}

# stop-transcript | out-null




write-host press enter ...
read-host