# Script to check print queues of printers as they are registered on an MS print server.
# It checks for current jobs in each printer and the status is decided by the command 
# line arguments the total jobs statuses have priority over individual printers.
#
# http://www.opensource.org/licenses/gpl-2.0.php
#
# Copyright (c) George Panou <panou.g@gmail.com> https://github.com/george-panou
# Modified by Juan Ferrer Toribio <juan.ferrer.toribio@gmail.com>
#
# .\check_print_server_jobs.ps1  <InfoLevel-per-printer> <Waring-per-printer> <Critical-per-printer> <TotalWarning> <TotalCritical>
# Sample call : .\check_print_server_jobs.ps1 3 5 7 10 15

# Command line arguments with default values...
param(
	[int] $infoLevel = 0,
	[int] $warning = 5,
	[int] $critical = 10,
	[int] $totalWarning = 10,
	[int] $totalCritical = 20
)

# Write-Output "You specified: $Arguments"

$result = @(Get-WMIObject Win32_PerfFormattedData_Spooler_PrintQueue | Select Name, @{Expression={$_.jobs};Label="CurrentJobs"}, TotalJobsPrinted, JobErrors)

$flag = 0
$totalJobs = 0
$textOutput = ""
$nl = [Environment]::NewLine

foreach ($line in $result) {
	$printerName = $line.Name
	$jobs = $line.CurrentJobs
	$printerFlag = 0

	if ($printerName -eq "_Total") {
		$totalJobs = $jobs

		if ($jobs -ge $totalCritical) {
			$printerFlag = 2
		} elseif ($jobs -ge $totalWarning) {
			$printerFlag = 1
		}
	} else {
		if ($jobs -ge $critical) {
			$printerFlag = 2
		} elseif ($jobs -ge $warning) {
			$printerFlag = 1
		}

		if ($jobs -ge $infoLevel -or $printerFlag -gt 0) {
			$textOutput += "${printerName}: $jobs$nl" 
		}
	}

	if ($flag -lt $printerFlag) {
		$flag = $printerFlag
	}
}

switch ($flag) {
	0 { $status = "OK" }
	1 { $status = "WARNING" }
	2 { $status = "CRITICAL" }
	default { $status = "UNKNOWN" }
}

$statusOut = "SPOOLER $status - $totalJobs jobs$nl"
$textOutput = $statusOut + $textOutput

Write-Output "$textOutput"

exit($flag)
