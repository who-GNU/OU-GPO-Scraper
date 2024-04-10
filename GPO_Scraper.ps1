##Script for getting all GPO linked to OU and additional info
##

$startOU = #OU to start with
$filePath = #File path to save CSV to 

$fullList = $null #clears the variable in case you've used it previously (i.e: ran the script this session)
$fullList += ((Get-GPInheritance -Target $startOU).GpoLinks | Select-Object DisplayName, Target, Description, WMIFilter) #Adds the GPO name + linked OU to the $fullList variable array

Write-Host "Links from starting OU found..."#write to give status update

(Get-ADOrganizationalUnit -LDAPFilter '(name=*)' -SearchBase $startOU -SearchScope Subtree).DistinguishedName | ForEach-Object{
    $fullList += ((Get-GPInheritance -Target $_).GpoLinks | Select-Object DisplayName, Target, Description, WMIFilter)
    Write-Host "Links for" $_ " found..." #write to give status update
}

Write-Host "List of links completed. Beginning additional GPO info gathering!" #write to give status update

for($i=0; $i -lt $fullList.length; $i++){
    if(((Get-GPO -Name (fullList[$i].DisplayName)).Description) -ne $null){
        $fullList[$i].Description = (Get-GPO -Name ($fullList[$i].displayName)).Description
    }

    if(((Get-GPO -Name (fullList[$i].DisplayName)).WMIFilter) -ne $null){
        $fullList[$i].WMIFilter = (Get-GPO -Name ($fullList[$i].displayName)).WMIFilter
    }

    Write-Host "Description and WMI Filter grabbed for" $fullList[$i].Displayname #write to give status update
}

Write-Host "Writing to" $filePath #write to give status update
Write-Output $fullList | Export-Csv $filePath
Write-Host "Script Completed!" #write to give status update