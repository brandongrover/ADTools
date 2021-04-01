#############################################################################
#################################  Header  ##################################
#############################################################################
$item = "*"
$item2 = "-"
Write-Host $item.padright(99,'*')
Write-Host $item.padright(36,"*")" Active Directory Toolkit "$item.padright(35,"*")
Write-Host $item.padright(99,'*')
$run = "y"
$date = Get-Date -Format yyyyMMdd
$date2 = date

#options
while($run -eq "y") {
    Write-Host "1) GPOs modified today"
    Write-Host "2) Search GPO by GUID"
    Write-Host "3) Search GPO by Name"
    Write-Host "4) SamAccountName Lookup"
    Write-Host "5) Group Lookup"
    Write-Host "6) Device Lookup"
    Write-Host "7) To do List"
    Write-Host ""

    #selector
    $selector = Read-Host -Prompt "Select an option"
    Write-Host $item2.padright(99,'-')
    #1
    if($selector -eq "1") {
        $gpoResult = Get-GPO -All | Where-Object {$_.ModificationTime.Day -like $date2.Day -and $_.ModificationTime.Month -like $date2.Month -and $_.ModificationTime.Year -like $date2.Year}
        echo $gpoResult

        #Output Option
        $outputSelector = Read-Host -Prompt "Would you like to export results? [y/n]"
        if($outputSelector -eq "y") {
            $gpoResult | Select-Object -Property * | Export-Csv -Delimiter ',' -Path .\Exports\GPO\Recently_Modified_GPOs-$date.csv -NoTypeInformation
        }
    }

    #2
    if($selector -eq "2") {
        $guid = Read-Host -Prompt "Enter the GUID"
        Write-Host ""
        $gpoResult = Get-GPO -Guid $guid
        echo $gpoResult

        #Output Option
        $outputSelector = Read-Host -Prompt "Would you like to export results? [y/n]"
        if($outputSelector -eq "y") {
            $nameExport = ($gpoResult).DisplayName
            $nameExport = $nameExport.replace(" ","_")
            $gpoResult | Select-Object -Property * | Export-Csv -Delimiter ',' -Path .\Exports\GPO\$nameExport-$date.csv -NoTypeInformation
        }
    }


    #3
    if($selector -eq "3") {
        Write-Host "1) Wildcard search"
        Write-Host "2) Exact Search"
        Write-Host ""
        $selector2 = Read-Host -Prompt "Select an option"
        $gpoName = Read-Host -Prompt "Enter the Name"

        if($selector2 -eq "1") {
            $gpoResult = Get-GPO -All | Where-Object {$_.displayname -like "*$gpoName*"}
        } else {
            $gpoResult = Get-GPO -Name $gpoName
        }
        echo $gpoResult

        #Output Option
        $outputSelector = Read-Host -Prompt "Would you like to export results? [y/n]"
        if($outputSelector -eq "y") {
            $gpoResult | Select-Object -Property * | Export-Csv -Delimiter ',' -Path .\Exports\GPO\$gpoName-$date.csv -NoTypeInformation
        }
    }

    #4
    if($selector -eq "4") {
        $samName = Read-Host -Prompt "Enter the SameAccountName"
        $user = Get-ADUser -Filter 'SamAccountName -like $samName'
        echo $user
        Write-Host $item2.padright(99,'-')     
        $userOption1 = Read-Host -Prompt "Would you like to view users groups? [y/n]"
        
        if($userOption1 -eq "y") {
            Write-Host $item2.padright(99,'-')
            $groups = Get-ADUser -Filter 'SamAccountName -like $samName' -Properties MemberOf | select MemberOf
            $groupsSplit = (($groups.memberof).split(",") | where-object {$_.contains("CN=")}).replace("CN=","")
            echo $GroupsSplit
            Write-Host $item2.padright(99,'-')
        }
        #Output Option
        $outputSelector = Read-Host -Prompt "Would you like to export results? [y/n]"
        if($outputSelector -eq "y") {
           $user | Select -Property DistinguishedName, Enabled, GivenName, Name, ObjectClass, ObjectGUID, SamAccountName, SID, UserPrincipalName | Export-Csv -Delimiter ',' -Path .\Exports\'Users&Groups'\$MID-$date.csv -NoTypeInformation
           if($userOption1 -eq "y") {
               $groupsSplit | Select-Object @{Name='Group Name';Expression={$_}} | Export-Csv -Delimiter ',' -Path .\Exports\'Users&Groups'\$MID-Groups-$date.csv -NoTypeInformation
           }

        }
    }
    
    if($selector -eq "5") {
        $groupName = Read-Host -Prompt "Enter the Group name"
        Write-Host ""
        Write-Host "Members"
        Write-Host "-------"
        $groupResults = (Get-ADGroupMember -Identity $groupName).name
        echo $groupResults

        Write-Host $item2.padright(99,'-')
        
        #Output Option
        $outputSelector = Read-Host -Prompt "Would you like to export results? [y/n]"
        if($outputSelector -eq "y") {
            $groupResults | Select-Object @{Name='Name';Expression={$_}} | Export-Csv -Delimiter ',' -Path .\Exports\'Users&Groups'\$groupName-Members-$date.csv -NoTypeInformation
        }

    }
    
    #6
    if($selector -eq "6") {
        Write-Host "1) Asset lookup"
        Write-Host "2) Owner lookup"
        Write-Host ""
        $selector2 = Read-Host -Prompt "Select an option"
        
        if($selector2 -eq "1") {
            $assetLookup = Read-Host -Prompt "Enter the Asset Name"
            $assetResult = Get-ADComputer -Identity "$assetLookup" -Properties *
        } else {
            $assetLookup = Read-Host -Prompt "Enter the Owner Name"
            $ownerString = "*" + $assetLookup
            $assetResult = Get-ADComputer -Filter {Description -like $ownerString} -Properties *
        }
        echo $assetResult

        #Output Option
        $outputSelector = Read-Host -Prompt "Would you like to export results? [y/n]"
        if($outputSelector -eq "y") {
            if($selector2 -eq "1") {
                $assetName = $assetResult.CN
                $assetResult | Select-Object -Property * | Export-Csv -Delimiter ',' -Path .\Exports\Assets\$assetName-$date.csv -NoTypeInformation
            } else {
                $assetResult | Select-Object -Property * | Export-Csv -Delimiter ',' -Path .\Exports\Assets\$assetLookup"_Devices"-$date.csv -NoTypeInformation
            }
        }
    
    }

    #7
    if($selector -eq "7") {
        Write-Host "1) End of Employment verification"
        Write-Host "2) Open to suggestions.."
        Write-Host ""
        Write-Host $item2.padright(99,'-')
    }

    $run = Read-Host -Prompt "Would you like to search again? [y/n]"
    Write-Host $item2.padright(99,'-')
}
