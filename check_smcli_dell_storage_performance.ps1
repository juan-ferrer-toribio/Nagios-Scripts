# Check Dell PowerVault MD 34/38 Series Storage Arrays Performance overview
# Prerequisites: smcli on a windows machine and a Nagios compatible agent
#
# Version 0.1
#	This script uses smcli to check the overall storage performance
#	Currently there are no status codes returned so its mainly for information alerting
#	It filters the objects and retains info only regarding the virtual disks
#	
#	Metrics:
#		Current MB s/sec   Current IOs/sec	Current IO Latency
#	
#	If you use a high availlability cluster of controllers then the output will be only the relevant virtual disks assigned to each controller at each given time
#	So you will be able to see which virtual disk is assigned to each node and its performance data
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

#Write-Output "You specified: $Arguments"

#optional arguments that can be handy if you'd like to extend/fork the script:
#$Commands = "'show allControllers summary; show allPhysicalDisks summary; show allVirtualDisks summary;'"


$Commands = "'show allVirtualDisks performanceStats;'"

#$Commands = "'show storageArray healthStatus;'"
#Write-Output  "& 'C:\Program Files\Dell\MD Storage Software\MD Storage Manager\client\smcli'  $IP -c  $Commands -S -e  "

$Result = invoke-expression "& 'C:\Program Files\Dell\MD Storage Software\MD Storage Manager\client\smcli'  $IP -c  $Commands -S -e "

$OutputNagios = ""


$Lines=$Result.Split([Environment]::NewLine)
$nl = [Environment]::NewLine

$mapPerf=0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


foreach ( $line in $Lines ){
  # Write-Output  $line
   $k=0
   $l=0
    if ( $line -match 'Virtual'){
    $splittedLine=$line.Split('","')
    $name=$splittedLine[1]
    $flag=0;
    $tmpOut
      foreach ( $element in $splittedLine){

        
        
        if($mapPerf[0]-eq $l ){
             $tmpOut += "$name : Current MB s/sec :  $element, $nl"

            if($element -ne "0.0" ){
                $flag=1
            }
            
            
        }elseif ($mapPerf[1] -eq $l ){
             $tmpOut += "$name : Current IOs/sec :  $element, $nl"
            if($element -ne "0.0" ){
                $flag=1
            }
           
           
        }elseif ($mapPerf[2] -eq $l ){
             $tmpOut  += "$name : Current IO Latency :  $element, $nl"
            if($element -ne "0.0"){
                $flag=1
            }
          
                    
        }
       
       
        $l++
    }
        if ($flag -eq 1){
            $OutputNagios += "$tmpOut"
            
        }
        $tmpOut = ""
     
   
    }
      
    elseif ( $line -match 'Objects'){
    $splittedLine=$line.Split('","')
    $i=0
    $j=0
        foreach ( $element in $splittedLine){
     
            if ($element -eq "Current MBs/sec"){
            
                $mapPerf[$j]=$i
                $j++
            }elseif ($element -eq "Current IOs/sec"){
             
                $mapPerf[$j]=$i
                $j++
            }elseif ($element -eq "Current IO Latency"){
                
                $mapPerf[$j]=$i
                $j++
            }
            $i++
        }
    }

    }

   Write-Output "Performance Metrics: $nl $OutputNagios"

