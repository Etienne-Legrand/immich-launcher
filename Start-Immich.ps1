# ============================================================
# Immich Launcher - version modulaire
# ============================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$immichConfiguration = . (Join-Path $PSScriptRoot "Configuration.ps1")
. (Join-Path $PSScriptRoot "StartupWorkflow.ps1")
. (Join-Path $PSScriptRoot "UserInterface.ps1")

try {
  $form = New-ImmichForm -Configuration $immichConfiguration
  $form.Show()
  [System.Windows.Forms.Application]::Run()
}
catch {
  [System.Windows.Forms.MessageBox]::Show(
    $_.Exception.Message,
    "Erreur de démarrage d'Immich",
    [System.Windows.Forms.MessageBoxButtons]::OK,
    [System.Windows.Forms.MessageBoxIcon]::Error
  )
}