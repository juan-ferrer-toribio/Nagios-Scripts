# Script to check print queues of printers as they are registered on an MS print server 
# It checks for current jobs in each printer and the status is decided by the command line arguments the total jobs statuses have priority over individual printers
#
#
# http://www.opensource.org/licenses/gpl-2.0.php
#
# Copyright (c) George Panou panou.g@gmail.com https://github.com/george-panou
#

#.\check_print_server_jobs.ps1  <InfoLevel-per-printer> <Waring-per-printer> <Critical-per-printer> <TotalWarning> <TotalCritical>
#Sample call : .\check_print_server_jobs.ps1 3 5 7 10 15

#Command line arguments with default values...

param(

	[int] $InfoLevel = 2,
	[int] $Warning = 5,
	[int] $Critical = 7,
	[int] $TotalWarning = 10,
	[int] $TotalCritical = 20
  
)

#Write-Output "You specified: $Arguments"

$Result  = @(Get-WMIObject Win32_PerfFormattedData_Spooler_PrintQueue | Select Name, @{Expression={$_.jobs};Label="CurrentJobs"}, TotalJobsPrinted, JobErrors)

$InfoLevel -= 1
$Warning -= 1
$Critical -= 1
$TotalWarning -= 1
$TotalCritical -= 1
	

$OutputNagios = ""


$nl = [Environment]::NewLine
$flag=0


foreach ( $line in $Result ){
	
	$Name=$line.Name
	$Jobs=$line.CurrentJobs
	$k=0
	$l=0
    #Write-Output "$Name"
	
	#check each printer
	if($Jobs -gt $Warning -and $Name -ne "_Total"){
		 $warnOut += "$Name :  $Jobs, $nl" 
		 if($flag -lt 2){
			$flag=1
			}
	}
	elseif($Jobs -gt $Critical  -and $Name -ne "_Total"){
		 $critOut += "$Name :  $Jobs, $nl" 
		 $flag=2

	}elseif($Jobs -gt $InfoLevel -and $line.Name -ne "_Total"){
		 $tmpOut += "$Name :  $Jobs, $nl" 
	}
	
	#check total jobs of the print server
	if($Name -eq "_Total" -and $Jobs -gt $TotalWarning){
	
		$tmpOut = "Total :  $Jobs, $nl" + $tmpOut
		 if($flag -lt 2){
			$flag=1
			}
	}elseif($Name -eq "_Total" -and $Jobs -gt $TotalCritical){
	
		$tmpOut = "Total :  $Jobs, $nl" + $tmpOut
		$flag=2
	}
	
	elseif($Name -eq "_Total"){
		$tmpOut = "Total :  $Jobs, $nl" + $tmpOut
	}
	
}
	
	
if ($flag -eq 1){
	$tmpOut = "Warning : " + $tmpOut
	
}
elseif ($flag -eq 2){#
	$tmpOut = "Critical : " + $tmpOut
	
}
else{
	$tmpOut = "OK : " + $tmpOut
}
$tmpOut = $tmpOut + $critOut 
$tmpOut = $tmpOut + $warnOut

Write-Output "$tmpOut"

exit($flag)

