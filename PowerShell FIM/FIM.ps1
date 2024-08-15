Function Calculate-File-Hash($filepath) {
    $filehash = Get-FileHash -Path $filepath -Algorithm SHA512
    return $filehash
}

Function Get-Folder($initialDirectory) {
    [System.Reflection.Assembly]::LoadWithPartialName("System.windows.forms") |
    Out-Null

    $foldername = New-Object System.Windows.Forms.FolderBrowserDialog
    $foldername.Description = "Select a folder to create a Baseline of its files:"
    $foldername.rootfolder = "MyComputer"
    $foldername.SelectedPath = $initialDirectory

    if ($foldername.ShowDialog() -eq "OK") {
        $folder += $foldername.SelectedPath
    }
    return $folder
}

Function Write-Log($message, $Color1, $Color2){
    $LogTime = Get-Date -Format "MM-dd-yyyy HH:mm:ss"
    Write-Host "$LogTime - $Message" -ForegroundColor $Color1 -BackgroundColor $Color2
    Write-Output "$LogTime - $Message" | Out-File -Filepath '.\FIM Log.log'  -Append
}

Function Erase-Baseline-If-One-Already-Exists () {
    $baselineExsits = Test-Path -Path .\baseline.txt

    if ($baselineExsits) {
        # Delete it
        Remove-Item -Path .\baseline.txt
    }
}

$TimeStamp = Get-Date -Format "MM-dd-yyyy HH:mm:ss"

Write-Output "$($TimeStamp) New Session Started" | Out-File -Filepath '.\FIM Log.log'  -Append

# Initial Loop to Ensure a Folder/Directory is Selected
Do{
# Have user select a folder for FIM use
Write-Host ""
$response1 = Read-Host -Prompt "Would you like to monitor a folder or directory with the FIM? (Y/N)"
Write-Host ""

    if ($response1 -eq "Y".ToUpper()) {
        Write-Host "Select a folder to monitor." -ForegroundColor Green
        Write-Host ""
        $target = "$(Get-Folder)"
    }

    elseif ($response1 -eq "N".ToUpper()) {
        Write-Host "Goodbye :)" -ForegroundColor Cyan
        Start-Sleep -Seconds 3
        return
    }

    else {
        Write-Host "Invalid input." -ForegroundColor Red
    }
} until ($target)

Write-Output "$($target) has been selected for monitoring" | Out-File -Filepath  '.\FIM Log.log'  -Append

# Final Loop to keep FIM tool active
Do {
    Write-Host ""
    Write-Host ""
    Write-Host "What would you like to do?"
    Write-Host ""
    Write-Host "    1) Create a new Baseline?"
    Write-Host "    2) Start monitoring files with stored Baseline?"
    Write-Host ""

    $response2 = Read-Host -Prompt "Please enter option '1' or '2'"
    Write-Host ""

    $baselinechecker = Test-Path baseline.txt

    if ($response2 -eq "1") {
        # Delete baseline.txt if it already exists
        Erase-Baseline-If-One-Already-Exists
        Write-Log "Previous baseline has been erased." Yellow Black

        # Collect all files in monitored folder
        $monitoredfiles = Get-ChildItem -Path "$target" -Recurse
   
        # Calculate the hash of each file and write it to baseline.txt
        foreach ($file in $monitoredfiles){
            $hash = Calculate-File-Hash $file.Fullname
            "$($hash.Path)|$($hash.Hash)" | Out-File -FilePath .\baseline.txt -Append
        }

        # Remove lines (from baseline file) with empty path|hash pairs caused by folders, will appear as a line with just a "|" character
        $search = "\\"
        $linenumber= Get-Content -Path .\baseline.txt | select-string -NotMatch $search
    
        $Content = Get-Content -Path .\baseline.txt
        $Index = 1
        $Output = 
        foreach($Line in $Content){
            if($Index -notin $linenumber.LineNumber){
                $Line
            }
        $Index ++
        }
        Set-Content .\baseline.txt $Output

        # Notification of completion
        Write-Log "New Baseline Created!" Green Black
    }

    elseif ($response2 -eq "2") {
        # Check if a baseline exists
        $baselinechecker = Test-Path baseline.txt
        if ($baselinechecker -eq $false) {
            Write-Host "Baseline not found, please create a Baseline before monitoring." -ForegroundColor Magenta
        }
        else {
            # Empty dictionary
            $HashDictionary = @{}

            # Load file hash from baseline.txt and store them into a dictionary
            $PathsandHashes = Get-Content -Path .\baseline.txt

            foreach ($file in $PathsandHashes) {
                $HashDictionary.add($file.Split("|")[0],$file.Split("|")[1])
            }
           
            Write-Log "Monitoring files for any changes..." Green Black

            # Start continuously monitoring files using saved Baseline
            while($true) {
                Start-Sleep -Seconds 1
                # Collect all files in monitored folder
                $monitoredfiles = Get-ChildItem -Path "$target" -Recurse

                # Calculate the hash of each file and write it to baseline.txt
                foreach ($file in $monitoredfiles){
                    $hash = Calculate-File-Hash $file.Fullname

                    if (-not [string]::IsNullOrEmpty($hash.Path)) {
                        # Notify user of any created/added files.
                        if ($HashDictionary[$hash.Path] -eq $null) {
                            Write-Log "$($hash.Path) has been added/created!" Cyan Black
                            # Note: If one of the files was Renamed, then it will show the NEW name as a created file.
                        }
                        else {
                            if ($HashDictionary[$hash.Path] -eq $hash.Hash) {
                                # The file has not changed
                            }
                            # Notify user of any modified files.
                            else {
                                Write-Log "$($hash.Path) has been modified!!" Yellow Black
                            }
                        }            
                    }
                }
                foreach ($key in $HashDictionary.keys) {
                    if (-not [string]::IsNullOrEmpty($key)){
                        $FileStillExists = Test-Path -Path $key

                        # Notify user of any deleted/removed files.
                        if (-Not $FileStillExists) {
                            Write-Log "$($key) has been removed/deleted!!!" Red Black
                        # Note: If one of the files was Renamed, then it will show the OLD name as a deleted file.
                        # Note: Moving a file from a subfolder to parent folder will show the file as being deleted from original location
                        # Note: Moving a file from a parent folder to subfolder will show the file as being deleted from original location & created in new location.
                        }            
                    }
                }        
            }
        }
    }
    else {
        Write-Host "Invalid input." -ForegroundColor Red
    }
} while ($true)