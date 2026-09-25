function Find-FirstExistingFile {
  param (
    [string[]]$Paths
  )

  return $Paths |
  Where-Object {
    -not [string]::IsNullOrWhiteSpace($_) -and
    (Test-Path -LiteralPath $_ -PathType Leaf)
  } |
  Select-Object -First 1
}

$dockerCommand = Get-Command "docker.exe" -CommandType Application -ErrorAction SilentlyContinue |
Select-Object -First 1

$dockerPath = if ($null -ne $dockerCommand) {
  $dockerCommand.Source
}
else {
  Find-FirstExistingFile @(
    (Join-Path $env:ProgramFiles "Docker\Docker\resources\bin\docker.exe"),
    (Join-Path $env:LOCALAPPDATA "Docker\resources\bin\docker.exe"),
    (Join-Path $env:LOCALAPPDATA "Programs\Docker\Docker\resources\bin\docker.exe")
  )
}

$dockerDesktopPath = Find-FirstExistingFile @(
  (Join-Path $env:ProgramFiles "Docker\Docker\Docker Desktop.exe"),
  (Join-Path $env:LOCALAPPDATA "Programs\Docker Desktop\Docker Desktop.exe"),
  (Join-Path $env:LOCALAPPDATA "Programs\Docker\Docker Desktop.exe"),
  (Join-Path $env:LOCALAPPDATA "Docker\Docker Desktop.exe")
)

[pscustomobject]@{
  ImmichUrl         = "http://localhost:2283/"
  DockerPath        = if ($null -ne $dockerPath) { [string]$dockerPath } else { "" }
  DockerDesktopPath = if ($null -ne $dockerDesktopPath) { [string]$dockerDesktopPath } else { "" }
  LogoPath          = Join-Path $PSScriptRoot "immich-logo-inline-light.svg"
  DockerTimeoutSec  = 60
  ImmichTimeoutSec  = 120
}