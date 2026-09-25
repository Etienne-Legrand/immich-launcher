[pscustomobject]@{
  ImmichUrl         = "http://localhost:2283/"
  DockerPath        = Join-Path $env:ProgramFiles "Docker\Docker\resources\bin\docker.exe"
  DockerDesktopPath = Join-Path $env:ProgramFiles "Docker\Docker\Docker Desktop.exe"
  # DockerPath        = Join-Path $env:LOCALAPPDATA "Docker\resources\bin\docker.exe"
  # DockerDesktopPath = Join-Path $env:LOCALAPPDATA "Programs\Docker Desktop\Docker Desktop.exe"
  LogoPath          = Join-Path $PSScriptRoot "immich-logo-inline-light.svg"
  DockerTimeoutSec  = 60
  ImmichTimeoutSec  = 120
}