# Check Dell PowerVault MD 34/38 Series Storage Arrays Overall Health
# Prerequisites: smcli on a windows machine and a Nagios compatible agent
#
# Version 0.1
#	This script uses smcli to check the overall storage health
#
# http://www.opensource.org/licenses/gpl-2.0.php
#
# Copyright (c) George Panou panou.g@gmail.com https://github.com/george-panou
#

#Script.ps1 - beginning of script


#Declare our named smcli command line arguments here...
param(
   [string] $IP,
   [string] $Commands
  
)


$IP=""

$Commands = "'show storageArray healthStatus;'"

#Write-Output "You specified: $Arguments"

$Result = invoke-expression "& 'C:\Program Files\Dell\MD Storage Software\MD Storage Manager\client\smcli'  $IP -c  $Commands -S -e "
Write-Output = $Result

$OutputNagios = ""

$flag=0
if($Result -match "optimal"){
    $flag=1
}
if($flag -eq 1){
   Write-Output "OK : $OutputNagios"
   exit(0)
}else{
   Write-Output "Critical : $OutputNagios"
   exit(2)
}

