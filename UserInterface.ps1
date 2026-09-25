function New-ImmichForm {
  param (
    [pscustomobject]$Configuration
  )

  $form = New-Object System.Windows.Forms.Form
  $form.Text = "Démarrage d'Immich"
  $form.Size = New-Object System.Drawing.Size(500, 400)
  $form.StartPosition = "CenterScreen"
  $form.FormBorderStyle = "FixedDialog"
  $form.MaximizeBox = $false
  $form.MinimizeBox = $false
  $form.BackColor = [System.Drawing.Color]::White

  $layoutPanel = New-Object System.Windows.Forms.TableLayoutPanel
  $layoutPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
  $layoutPanel.Padding = New-Object System.Windows.Forms.Padding(25, 18, 25, 11)
  $layoutPanel.ColumnCount = 1
  $layoutPanel.RowCount = 3
  [void]$layoutPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle(
        [System.Windows.Forms.SizeType]::Percent,
        100
      )))
  [void]$layoutPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle(
        [System.Windows.Forms.SizeType]::Absolute,
        145
      )))
  [void]$layoutPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle(
        [System.Windows.Forms.SizeType]::Absolute,
        60
      )))
  [void]$layoutPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle(
        [System.Windows.Forms.SizeType]::Percent,
        100
      )))
  $form.Controls.Add($layoutPanel)

  $logoBrowser = New-Object System.Windows.Forms.WebBrowser
  $logoBrowser.Dock = [System.Windows.Forms.DockStyle]::Fill
  $logoBrowser.Margin = New-Object System.Windows.Forms.Padding(0, 0, 0, 20)
  $logoBrowser.AllowNavigation = $false
  $logoBrowser.AllowWebBrowserDrop = $false
  $logoBrowser.ScrollBarsEnabled = $false
  $logoBrowser.ScriptErrorsSuppressed = $true
  $logoBrowser.Navigate(([System.Uri]::new($Configuration.LogoPath)).AbsoluteUri)
  $layoutPanel.Controls.Add($logoBrowser, 0, 0)

  $messageLabel = New-Object System.Windows.Forms.Label
  $messageLabel.Dock = [System.Windows.Forms.DockStyle]::Fill
  $messageLabel.Font = New-Object System.Drawing.Font("Segoe UI", 11)
  $messageLabel.Text = "Initialisation..."
  $messageLabel.TextAlign = [System.Drawing.ContentAlignment]::MiddleCenter
  $messageLabel.AutoEllipsis = $true
  $layoutPanel.Controls.Add($messageLabel, 0, 1)

  $actionPanel = New-Object System.Windows.Forms.TableLayoutPanel
  $actionPanel.Dock = [System.Windows.Forms.DockStyle]::Fill
  $actionPanel.Margin = New-Object System.Windows.Forms.Padding(0)
  $actionPanel.ColumnCount = 1
  $actionPanel.RowCount = 1
  [void]$actionPanel.ColumnStyles.Add((New-Object System.Windows.Forms.ColumnStyle(
        [System.Windows.Forms.SizeType]::Percent,
        100
      )))
  [void]$actionPanel.RowStyles.Add((New-Object System.Windows.Forms.RowStyle(
        [System.Windows.Forms.SizeType]::Percent,
        100
      )))
  $layoutPanel.Controls.Add($actionPanel, 0, 2)

  $spinnerPanel = New-Object System.Windows.Forms.Panel
  $spinnerPanel.Size = New-Object System.Drawing.Size(50, 50)
  $spinnerPanel.Margin = New-Object System.Windows.Forms.Padding(0)
  $spinnerPanel.Anchor = [System.Windows.Forms.AnchorStyles]::None
  $spinnerPanel.BackColor = [System.Drawing.Color]::White
  $actionPanel.Controls.Add($spinnerPanel, 0, 0)

  $closeButton = New-Object System.Windows.Forms.Button
  $closeButton.Size = New-Object System.Drawing.Size(140, 42)
  $closeButton.Margin = New-Object System.Windows.Forms.Padding(0)
  $closeButton.Anchor = [System.Windows.Forms.AnchorStyles]::None
  $closeButton.Text = "Fermer"
  $closeButton.Font = New-Object System.Drawing.Font("Segoe UI Semibold", 10)
  $closeButton.BackColor = [System.Drawing.Color]::FromArgb(66, 81, 176)
  $closeButton.ForeColor = [System.Drawing.Color]::White
  $closeButton.FlatStyle = [System.Windows.Forms.FlatStyle]::Flat
  $closeButton.FlatAppearance.BorderSize = 0
  $closeButton.Cursor = [System.Windows.Forms.Cursors]::Hand
  $closeButton.Visible = $false
  $actionPanel.Controls.Add($closeButton, 0, 0)

  $closeButton.Add_HandleCreated({
      $buttonPath = New-Object System.Drawing.Drawing2D.GraphicsPath
      $buttonPath.AddArc(0, 0, 18, 18, 180, 90)
      $buttonPath.AddArc($closeButton.Width - 18, 0, 18, 18, 270, 90)
      $buttonPath.AddArc($closeButton.Width - 18, $closeButton.Height - 18, 18, 18, 0, 90)
      $buttonPath.AddArc(0, $closeButton.Height - 18, 18, 18, 90, 90)
      $buttonPath.CloseFigure()
      $closeButton.Region = New-Object System.Drawing.Region($buttonPath)
      $buttonPath.Dispose()
    }.GetNewClosure())
  $closeButton.Add_MouseEnter({
      $closeButton.BackColor = [System.Drawing.Color]::FromArgb(52, 65, 150)
    }.GetNewClosure())
  $closeButton.Add_MouseLeave({
      $closeButton.BackColor = [System.Drawing.Color]::FromArgb(66, 81, 176)
    }.GetNewClosure())

  $state = @{
    SpinnerAngle = 0
    SpinnerMode  = "Loading"
    Job          = $null
  }
  $timer = New-Object System.Windows.Forms.Timer
  $timer.Interval = 150

  $spinnerPaintHandler = {
    param ($paintSource, $paintEventArgs)

    $graphics = $paintEventArgs.Graphics
    $graphics.SmoothingMode = [System.Drawing.Drawing2D.SmoothingMode]::AntiAlias
    $pen = New-Object System.Drawing.Pen([System.Drawing.Color]::FromArgb(66, 81, 176), 5)
    $pen.StartCap = [System.Drawing.Drawing2D.LineCap]::Round
    $pen.EndCap = [System.Drawing.Drawing2D.LineCap]::Round

    if ($state.SpinnerMode -eq "Loading") {
      $graphics.DrawArc($pen, 7, 7, 36, 36, $state.SpinnerAngle, 270)
    }
    elseif ($state.SpinnerMode -eq "Done") {
      $pen.Color = [System.Drawing.Color]::FromArgb(24, 194, 73)
      $graphics.DrawArc($pen, 7, 7, 36, 36, 0, 360)
    }
    else {
      $pen.Color = [System.Drawing.Color]::FromArgb(250, 41, 33)
      $graphics.DrawArc($pen, 7, 7, 36, 36, 0, 360)
    }

    $pen.Dispose()
  }.GetNewClosure()
  $spinnerPanel.Add_Paint($spinnerPaintHandler)

  $timerTickHandler = {
    $state.SpinnerAngle = ($state.SpinnerAngle + 35) % 360
    $spinnerPanel.Invalidate()

    if ($null -eq $state.Job) {
      return
    }

    $messages = @(Receive-Job -Job $state.Job -ErrorAction SilentlyContinue)
    foreach ($message in $messages) {
      if ($message.Type -eq "Status") {
        $messageLabel.Text = $message.Message
      }
      elseif ($message.Type -eq "Done") {
        $timer.Stop()
        $spinnerPanel.Visible = $false
        $form.Close()
      }
      elseif ($message.Type -eq "Error") {
        $messageLabel.Text = "Erreur : " + $message.Message
        $messageLabel.ForeColor = [System.Drawing.Color]::Red
        $messageLabel.Font = New-Object System.Drawing.Font(
          "Segoe UI",
          11,
          [System.Drawing.FontStyle]::Bold
        )
        $spinnerPanel.Visible = $false
        $timer.Stop()
        $closeButton.Visible = $true
      }
    }

    if ($state.Job.State -in @("Completed", "Failed", "Stopped")) {
      Remove-Job -Job $state.Job -Force -ErrorAction SilentlyContinue
      $state.Job = $null
    }
  }.GetNewClosure()
  $timer.Add_Tick($timerTickHandler)

  $closeButton.Add_Click({ $form.Close() }.GetNewClosure())
  $form.Add_Shown({
      $state.Job = New-ImmichStartupJob `
        -DockerPath $Configuration.DockerPath `
        -DockerDesktopPath $Configuration.DockerDesktopPath `
        -ImmichUrl $Configuration.ImmichUrl `
        -DockerTimeoutSec $Configuration.DockerTimeoutSec `
        -ImmichTimeoutSec $Configuration.ImmichTimeoutSec
      $timer.Start()
    }.GetNewClosure())
  $form.Add_FormClosing({
      $timer.Stop()
      if ($null -ne $state.Job) {
        Stop-Job -Job $state.Job -ErrorAction SilentlyContinue
        Remove-Job -Job $state.Job -Force -ErrorAction SilentlyContinue
      }
    }.GetNewClosure())
  $form.Add_FormClosed({
      [System.Windows.Forms.Application]::ExitThread()
    }.GetNewClosure())

  return $form
}