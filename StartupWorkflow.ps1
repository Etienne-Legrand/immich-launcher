function New-ImmichStartupJob {
  param (
    [string]$DockerPath,
    [string]$DockerDesktopPath,
    [string]$ImmichUrl,
    [int]$DockerTimeoutSec,
    [int]$ImmichTimeoutSec
  )

  Start-Job -ArgumentList $DockerPath, $DockerDesktopPath, $ImmichUrl, $DockerTimeoutSec, $ImmichTimeoutSec -ScriptBlock {
    param (
      $dockerPath,
      $dockerDesktopPath,
      $urlImmich,
      $dockerTimeoutSec,
      $immichTimeoutSec
    )

    function Send-Message {
      param (
        [ValidateSet("Status", "Done", "Error")]
        [string]$Type,
        [string]$Message
      )

      [pscustomobject]@{
        Type    = $Type
        Message = $Message
      }
    }

    function Test-DockerReady {
      & $dockerPath info *> $null
      return ($LASTEXITCODE -eq 0)
    }

    function Test-ImmichReady {
      try {
        $response = Invoke-WebRequest `
          -Uri $urlImmich `
          -UseBasicParsing `
          -TimeoutSec 3 `
          -ErrorAction Stop

        return ($response.StatusCode -ge 200 -and $response.StatusCode -lt 500)
      }
      catch {
        return $false
      }
    }

    try {
      if (-not (Test-Path $dockerPath)) {
        throw "Docker CLI introuvable : $dockerPath"
      }

      Send-Message "Status" "Vérification de Docker..."
      if (-not (Test-DockerReady)) {
        if (-not (Test-Path $dockerDesktopPath)) {
          throw "Docker Desktop introuvable : $dockerDesktopPath"
        }

        if ($null -eq (Get-Process "Docker Desktop" -ErrorAction SilentlyContinue)) {
          Send-Message "Status" "Démarrage de Docker Desktop..."
          Start-Process -FilePath $dockerDesktopPath
        }

        Send-Message "Status" "Attente de Docker (maximum $dockerTimeoutSec secondes)..."
        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        while ($stopwatch.Elapsed.TotalSeconds -lt $dockerTimeoutSec) {
          if (Test-DockerReady) {
            break
          }
          Start-Sleep -Seconds 1
        }
        $stopwatch.Stop()

        if (-not (Test-DockerReady)) {
          throw "Docker n'est pas disponible après $dockerTimeoutSec secondes."
        }
      }

      Send-Message "Status" "Docker est prêt. Attente du démarrage d'Immich..."
      $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
      while ($stopwatch.Elapsed.TotalSeconds -lt $immichTimeoutSec) {
        if (Test-ImmichReady) {
          break
        }
        Start-Sleep -Seconds 2
      }
      $stopwatch.Stop()

      if (-not (Test-ImmichReady)) {
        throw "Immich n'est pas disponible après $immichTimeoutSec secondes."
      }

      Start-Process $urlImmich
      Send-Message "Done" "Immich est prêt !"
    }
    catch {
      Send-Message "Error" $_.Exception.Message
    }
  }
}