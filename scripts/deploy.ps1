param(
    [string]$RunId
)

$storageAccount = "testvmgroupb7e2"
$container = "artifacts"
$blobName = "CircleApp_$RunId.zip"
$destFile = "C:\temp\CircleApp.zip"
$destPath = "C:\inetpub\wwwroot\CircleApp"

Write-Output "Logging into Azure with VM's Managed Identity or SPN (assumes permissions are already granted)..."
az login --identity | Out-Null

Write-Output "Downloading blob $blobName..."
az storage blob download `
    --account-name $storageAccount `
    --container-name $container `
    --name $blobName `
    --file $destFile `
    --auth-mode login `
    --overwrite

Write-Output "Deploying to IIS path..."
if (Test-Path $destPath) { Remove-Item -Recurse -Force $destPath }
Expand-Archive -Path $destFile -DestinationPath $destPath -Force

Write-Output "Restarting IIS App Pool..."
Import-Module WebAdministration
Restart-WebAppPool "DefaultAppPool"

Write-Output "Deployment complete!"
