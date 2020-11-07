Write-Host 'Hello, World!'
$drive = Read-Host -Prompt 'Enter the letter associated with the drive, followed by a colon (e.g. E:, H:)'
$drive = '.\test\'
$drive_folders = Get-ChildItem $drive\ -Directory
$runData_folders = @()
foreach ($folder in $drive_folders)
{
    if ( ($folder -match "r64140*") -or ($folder -match "r54366U*") )
    { $runData_folders += $folder }
}
foreach ($folder in $runData_folders)
{
    Write-Host "Entering " $folder " to change permissions"
}