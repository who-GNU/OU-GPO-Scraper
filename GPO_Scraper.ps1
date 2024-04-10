##Script for getting all GPO linked to OU and additional info
##

$StartOU = #xxx

(Get-GPInheritance -Target $StartOU).GpoLinks | ForEach-Object{
    $data = [PSCustomObject]@{
        OU          = $_.Path 
        DisplayName = (Get-GPO -Name ($_.DisplayName)).DisplayName
        Description = (Get-GPO -Name ($_.DisplayName)).Description
        WMIFilter   = (Get-GPO -Name ($_.DisplayName)).WMIFilter
   
    }

Write-Output $data | Export-CSV ##PATH

}

(Get-ADOrganizationalUnit -LDAPFilter '(name=*)' -SearchBase $StartOU -SearchScope Subtree).DistinguishedName | ForEach-Object{
    $data = [PSCustomObject]@{ 
        OU = $_.DistinguishedName
    }
    (Get-GPInheritance -Target $_.DistinguishedName).GpoLinks | ForEach-Object{
        $data = [PSCustomObject]@{ 
            DisplayName = (Get-GPO -Name ($_.DisplayName)).DisplayName
            Description = (Get-GPO -Name ($_.DisplayName)).Description
            WMIFilter   = (Get-GPO -Name ($_.DisplayName)).WMIFilter
   
        }

    }
}