# PowerShell FIM Tool

A File Integrity Monitor (FIM) is used to monitor and track any changes of files, ensuring that the files have not been added/changed/removed, meaning that they have retained their integrity. The PowerShell FIM tool has the functionality to create new baselines (and remove old ones as needed) of a directory's files using a hashing algorithm to create file path/hash pairs, and monitor the files of the selected directory for any additions, modifications, or deletions.

# Functions
## •	Log Writing:
This function combines Write-Host and Out-File functionalities. The function will display events or alerts to the user-interface and send logs to a separate log file, while including timestamps to each event/alert for logging purposes. Events and alerts on the user-interface will be displayed in different-colored text depending on the event/alert.

![image](https://github.com/mohammedshahwan/PowerShell-FIM-Tool/blob/main/assets/1.png)

Another logging feature was added separate from the Write-Log function to output only to the log file when a new session is started with the FIM tool.

![image](https://github.com/mohammedshahwan/PowerShell-FIM-Tool/blob/main/assets/2.png)

## •	Folder/Directory Selection:
Before creating a new baseline, the user must select a folder/directory to create a baseline of. This function allows a graphical display of directories and their subdirectories for the user to select from, effectively removing the need to know and type out the full directory path name manually.

![image](https://github.com/mohammedshahwan/PowerShell-FIM-Tool/blob/main/assets/3.png)

## •	Erasing Previous Baseline:
The FIM tool will also check for an existing baseline file, named "baseline.txt", before creating a new baseline. If a baseline file is found within the directory, it will be erased before a new baseline is created. To prevent this, the old baseline file can simply be moved to a different directory to archive it.

![image](https://github.com/mohammedshahwan/PowerShell-FIM-Tool/blob/main/assets/4.png)


## •	File Hashing:
The script will use a SHA-512 hashing algorithm function to create a unique hash of each file in the selected directory, and will also do so for files in any subdirectories recursively.

![image](https://github.com/mohammedshahwan/PowerShell-FIM-Tool/blob/main/assets/5.png)


# FIM Script Process
•	<b>Start:</b> Upon executing the script, the user will be asked if they would like to monitor a folder/directory with the FIM tool:</b>

  Y: A window is opened with a graphical display of the directories for the user to select from.

  N: The script will end.

•	<b>Directory Selected:</b> The user will then be prompted to choose one of two selections:

  1: Create a new baseline.

  2: Start monitoring files with a stored baseline.

•	<b>(Option 1)</b> Creating a New Baseline: The tool will first delete the old baseline.txt file (if one exists). Then, it will recursively scan all the files in the previously selected directory. The hash of each file will be calculated and the file path/hash pairs will be stored in the new baseline file.

•	<b>(Option 2)</b> Monitoring Files using Stored Baseline: The script will continuously monitor the selected directory for any changes in a loop using the file path/hash pairs stored in the baseline file, until the script is manually interrupted by the user.

•	In the event of a file being created/added, modified, or deleted/moved, a message will display on the user-interface and a log will be created in the log file.

# Change Alerts (while monitoring a directory)
## •	[New File] has been Added/Created:
While monitoring the files of a selected directory, the script is continuously calculating file hashes and comparing the calculated file path/hash pairs to the stored baseline file path/hash pairs.
If the file path is not found in the baseline file, it indicates that a new file has been created or added into the monitored directory.
A cyan-colored alert will be presented to the user with a timestamp, showing that a new file has been created or added to the directory. A timestamped log will also be recorded in the log file.

![image](https://github.com/mohammedshahwan/PowerShell-FIM-Tool/blob/main/assets/6.png)

## •	[Existing File] has been Modified:
If the file path exists, the script will then compare the file hash with the stored file hash for the matched file path.
If the file hashes are different, it indicates that the file has been modified.
A yellow-colored alert will be presented to the user with a timestamp, showing that an existing file has been modified. A timestamped log will also be recorded in the log file.

![image](https://github.com/mohammedshahwan/PowerShell-FIM-Tool/blob/main/assets/7.png)

If both the file path and hash match, then we know that nothing was changed, so no alert is generated.

## •	[Existing File] has been Deleted or Removed from the Directory:
After checking if the file was added or modified (or matches), the script uses the baseline file paths to check if any files that exist in the baseline do not exist in the current directory.
If a file that exists in the baseline doesn't exist in the current directory, it indicates that the missing file has been either deleted or moved to a different directory.
A red-colored alert will be presented to the user with a timestamp, showing that a file that exists in the baseline has been deleted or removed from the directory. A timestamped log will also be recorded in the log file.

![image](https://github.com/mohammedshahwan/PowerShell-FIM-Tool/blob/main/assets/8.png)
