$drive = Read-Host -Prompt 'Enter the letter associated with the drive, followed by a colon (e.g. E:, H:)'
$drive_folders = Get-ChildItem $drive\
$runData_folders = @()
$icacls_messages = @()

Write-Host "Found the following folders of run data:"
foreach ($folder in $drive_folders)
{
    if ( $folder -match "r64140*" -or $folder -match "r54336*" -or $folder -match "r54120*"  )
    {
        $runData_folders += $folder
        Write-Host $folder
    }
}

$file_traversal = @()

foreach ($folder in $runData_folders)
{
    $message_and_location = icacls $drive\$folder /grant Everyone:RX /q
    $message_and_location += ( "`t( folder " + $folder + ' )' )
    $icacls_messages += $message_and_location
    $num_icacls_messages += 1
    $subfolders = Get-ChildItem $drive\$folder\
    $file_traversal += ( "Attempted to fix permissions within " + $folder )
    foreach ($subfolder in $subfolders)
    {
        $file_traversal += ( "..................................." + " > " + $subfolder )
        $message_and_location = icacls $drive\$folder\$subfolder /grant Everyone:RX /q
        $message_and_location += ( "`t( folder " + $folder + '\' + $subfolder + ' )' )
        $icacls_messages += $message_and_location
        $num_icacls_messages += 1
        $message_and_location = icacls $drive\$folder\$subfolder\* /grant Everyone:RX /q
        $message_and_location += ( "`t( files within " + $folder + '\' + $subfolder + " )" )
        $icacls_messages += $message_and_location
        $num_icacls_messages += 1
    }
}

foreach ($line in $file_traversal)
{
    Write-Host $line
}

$failure_messages = @()
$num_failure_messages = 0
$success_messages = @()
$num_success_messages = 0
$mixed_messages = @()
$num_mixed_messages = 0
# $icacls_messages += "Successfully processed 2 files; Failed processing 1 file"

foreach($message in $icacls_messages) # CHECK FOR FAILURES
{
    if ( ($message -match "Failed processing [^0]") -and ($message -match "Successfully processed 0") ) # complete failure
    {
        $failure_messages += $message
        $num_failure_messages += 1
    }
    elseif ( ($message -match "Successfully processed [^0]") -and ($message -match "Failed processing 0") )  # complete success
    {
        $success_messages += $message
        $num_success_messages += 1
    }
    else # mixed report 
    {
        $mixed_messages += $message
        $num_mixed_messages += 1
    }
}

if ( -not $num_success_messages) # REPORT COMPLETION
{
    if ($num_mixed_messages)
    {
        Write-Host "`n`t###### Partial Failure! ######"
        Write-Host "`nThese attempts to change permissions were partially successful:"
        foreach ($m in $mixed_messages) { Write-Host $m }
        Write-Host "`nAll other attempts to change permissions failed."
    }
    else 
    {
        Write-Host "`n`t###### Complete Failure! ######"
        Write-Host "`nAll attempts to change permissions failed."
    }
}
elseif ( -not $num_failure_messages )
{
    if ($num_mixed_messages)
    {
        Write-Host "`n`t###### Partial Success! ######"
        Write-Host "`nThese attempts to change permissions were only partially successful:"
        foreach ($m in $mixed_messages) { Write-Host $m }
        Write-Host "`nAll other permissions were successfully changed to read and execute for all users."
    }
    else 
    {
        Write-Host "`n`t###### Complete Success! ######" 
        Write-Host "`nAll file permissions were successfully changed to read and execute for all users."
    }
}
else # there must be some success and some failure messages
{
    Write-Host "`n`t###### Partial Success! ######"
    Write-Host "`nThese attempts to change permissions failed:"
    foreach($m in $failure_messages) { Write-Host $m }
    if ($num_mixed_messages) # if there are also some mixed messages
    {
        Write-Host "`nThese attempts to change permissions were only partially successful:"
        foreach($m in $mixed_messages)
        {
            Write-Host $m
        }
    }
    Write-Host "`nAll other permissions were successfully changed to read and execute for all users."    
}

$input = Read-Host -Prompt "`nEnter 'y' to see a list of files whose permissions were successful changed, otherwise enter any other letter"

if ($input -eq "y")
{
    foreach ($m in $success_messages) { Write-Host $m }
}






















