#Feature Flags
$audit = $false
$DeleteStaleRecords =  $true

#get content
$filepath = "C:\temp\storagetesting"
$filecontent = Get-ChildItem -Path $filepath -Recurse -file
#evaluate and cleanup content
write-host "evaluating files" -ForegroundColor Yellow
$90days = ((Get-Date).Adddays(-(90)))
$exportdata = @()
$a = 1
$b = $filecontent.count  
#Begin loop
foreach($item in $filecontent){
    $filename = @()
    $filename = $item.Name

    Write-host "Working on item $a of $b - $filename"
    #Regex to cleanup filename and just get date
    $datestring = @()
    $datestring = (($filename.split("_","3"))[2]).split("-","2")[0]

    #convert string from file into valid date time formate
    $dateconverted = @()
    $dateconverted = [datetime]::ParseExact($datestring,'yyyy_MM_dd',$null)

    #Evaluate if file should be deleted
    $DeleteFile = @()
    if($dateconverted -lt $90days){
        $DeleteFile = $true
        write-host "$filename is older than 90 days." -ForegroundColor DarkCyan
    }
    else{
        $DeleteFile = $false
        write-host "$filename is younger than 90 days." -ForegroundColor DarkGreen
    }

    

    #Generate Audit Report if feature is enabled
    if($audit -eq $true){
        Write-host "Adding Data to Audit Report" -ForegroundColor Yellow
        #Add Data to row
        $Row = [PSCustomObject]@{
            Filename                = $filename
            DeleteFile				= $DeleteFile
        }
        #Add row to Export Data
        $exportdata += $row
    }

    #Delete file if feature is enabled    
    if($DeleteStaleRecords -eq $true -and $deletefile -eq $true){
        Write-host "Deleting $filename" -ForegroundColor Yellow
        try{
            Get-Item -path $item.FullName | Remove-Item -Recurse -ErrorAction Stop
            write-host "Deleted $filename" -ForegroundColor Magenta
        }
        catch{
            $error[0].exception
        }
        
    }

    #Write to host if audit and delete is not enabled
    if($audit -eq $false -and $DeleteStaleRecords -eq $false){
        Write-Host "$filename | $dateConverted | deletefile:$deletefile " -ForegroundColor DarkCyan
    }
    $a++
}

#Export Data
if($audit -eq $true){
    Write-host "Exporting Data" -ForegroundColor Yellow
    $exportdata | Export-Csv -NoTypeInformation "C:\temp\deletecontent.csv "
}