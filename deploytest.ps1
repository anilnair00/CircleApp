param (
    [string]$ZipPath = "C:\Temp\CircleApp.zip",
    [string]$SitePath = "C:\inetpub\wwwroot\CircleApp",
    [string]$AppPool = "DefaultAppPool"
)

Write-Host "Deploying $ZipPath to $SitePath"

# Ensure site directory exists
if (-not (Test-Path $SitePath)) {
    New-Item -ItemType Directory -Path $SitePath | Out-Null
}

# Stop App Pool
Write-Host "Stopping App Pool $AppPool..."
Stop-WebAppPool -Name $AppPool -ErrorAction SilentlyContinue

# Extract artifact
Write-Host "Extracting $ZipPath into $SitePath..."
Expand-Archive -Path $ZipPath -DestinationPath $SitePath -Force

# Restart App Pool
$state = (Get-WebAppPoolState -Name $AppPool).Value
if ($state -eq "Stopped") {
    Write-Host "App Pool was stopped. Starting..."
    Start-WebAppPool -Name $AppPool
} else {
    Write-Host "Restarting App Pool..."
    Restart-WebAppPool -Name $AppPool
}

Write-Host "✅ Deployment complete!"
