Write-Host 'Hello, World!'
$drive = Read-Host -Prompt 'Enter the letter associated with the drive, followed by a colon (e.g. E:, H:)'
$drive_folders = Get-ChildItem $drive\ -Directory
$runData_folders = @()
$icacls_messages = @()

Write-Host "Found the following run data folders:"
foreach ($folder in $drive_folders)
{
    if ( $folder -match "r64140*" -or $folder -match "r54336U*" )
    {
        $runData_folders += $folder
        Write-Host $folder
    }
}

foreach ($folder in $runData_folders)
{
    $message_and_location = icacls $drive\$folder /grant Everyone:RX /q
    $message_and_location += ( '   ( folder ' + $folder + ' )' )
    $icacls_messages += $message_and_location
    $subfolders = Get-ChildItem $drive\$folder\ -Directory
    Write-Host "Fixing permissions within" $folder 
    foreach ($subfolder in $subfolders)
    {
        Write-Host "........................." ">" $subfolder
        $message_and_location = icacls $drive\$folder\$subfolder /grant Everyone:RX /q
        $message_and_location += ( '   ( folder ' + $folder + '\' + $subfolder + ' )' )
        $icacls_messages += $message_and_location
        $message_and_location = icacls $drive\$folder\$subfolder\* /grant Everyone:RX /q
        $message_and_location += ( '   ( files within ' + $folder + '\' + $subfolder + " )" )
        $icacls_messages += $message_and_location
    }
}
[bool] $failure_occurred = $false
$failure_messages = @()
# $icacls_messages += "Successfully processed 2 files; Failed processing 1 file"

foreach($message in $icacls_messages) # CHECK FOR FAILURES
{
    if ( $message -match "Failed processing [^0]" )
    {
        $failure_occurred = $true
        $failure_messages += $message
    }
}

if ($failure_occurred)
{
    Write-Host "These attempts to change a file's permission failed:"
    foreach($message in $failure_messages)
    {
        Write-Host $message
    }
    Write-Host "All other file permissions were successfully changed to read and execute for all users."
}

else { Write-Host "All file permissions were successfully changed to read and execute for all users." }
