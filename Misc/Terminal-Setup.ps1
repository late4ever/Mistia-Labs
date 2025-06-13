Write-Host "Starting Fancy Terminal Setup..." -ForegroundColor Yellow

# --- Function to check if a PowerShell module is installed ---
function Test-ModuleInstalled {
  param (
    [string]$ModuleName
  )
  return $null -ne $(Get-Module -ListAvailable -Name $ModuleName)
}

# --- 1. Install Oh My Posh (using winget for the .exe, which includes 'oh-my-posh font install') ---
Write-Host "Checking Oh My Posh installation..." -ForegroundColor Cyan
$ompPath = Join-Path -Path $env:LOCALAPPDATA -ChildPath "Programs\oh-my-posh\bin\oh-my-posh.exe"
if (-not (Test-Path $ompPath)) {
  Write-Host "Oh My Posh not found. Attempting to install via winget..."
  try {
    winget install JanDeDobbeleer.OhMyPosh -s winget --accept-package-agreements --accept-source-agreements
    # Verify installation path (winget might install to a different default path sometimes)
    # Common alternative: C:\Users\[YourUser]\AppData\Local\Programs\oh-my-posh\bin\oh-my-posh.exe
    # This script assumes the default LOCALAPPDATA path or that it's added to PATH by the installer.
    # If 'oh-my-posh' command is not found after this, manual PATH adjustment might be needed.
    Write-Host "Oh My Posh installation attempted. You might need to restart your terminal for 'oh-my-posh' command to be available." -ForegroundColor Green
  }
  catch {
    Write-Error "Failed to install Oh My Posh using winget. Please install it manually. Error: $($_.Exception.Message)"
    # Exit # Or continue if you want other steps to proceed
  }
}
else {
  Write-Host "Oh My Posh appears to be installed at $ompPath." -ForegroundColor Green
}

# --- 2. Install Nerd Font using oh-my-posh font install ---

Write-Host "Installing 'CaskaydiaCove Nerd Font Mono'" -ForegroundColor Cyan
try {
  Install-PSResource -Name NerdFonts
  Import-Module -Name NerdFonts
  Install-NerdFont -Name 'CascadiaMono'
  Write-Host "'CaskaydiaCove Nerd Font Mono' installation command executed." -ForegroundColor Green
  Write-Host "You may need to acknowledge User Account Control (UAC) prompts for font installation." -ForegroundColor Yellow
  Install-NerdFont -Name 'CascadiaCode'
  Write-Host "'CaskaydiaCove Nerd Font' installation command executed." -ForegroundColor Green
  Write-Host "You may need to acknowledge User Account Control (UAC) prompts for font installation." -ForegroundColor Yellow
}
catch {
  Write-Error "Error: $($_.Exception.Message)"
}

# --- 3. Install Terminal-Icons module ---
Write-Host "Checking Terminal-Icons module..." -ForegroundColor Cyan
if (-not (Test-ModuleInstalled -ModuleName "Terminal-Icons")) {
  Write-Host "Installing Terminal-Icons module from PSGallery..."
  try {
    Install-Module -Name Terminal-Icons -Repository PSGallery -Scope CurrentUser -Force -ErrorAction Stop
    Write-Host "Terminal-Icons module installed." -ForegroundColor Green
  }
  catch {
    Write-Error "Failed to install Terminal-Icons module. Error: $($_.Exception.Message)"
  }
}
else {
  Write-Host "Terminal-Icons module is already installed." -ForegroundColor Green
}

# --- 4. Configure PowerShell Profile ($PROFILE) ---
Write-Host "Configuring PowerShell Profile (`$PROFILE`)..." -ForegroundColor Cyan

# Define the desired content for the profile
$ohMyPoshConfigPath = "hhttps://gist.githubusercontent.com/late4ever/48c7b7bcd5124a42fa3cb78310627d78/raw/9168f0ac7b9dd9c94deb147ef6237a7883541125/mike-ohmyposh.json"
$profileContent = @"
Invoke-Expression (oh-my-posh --init --shell pwsh --config "$ohMyPoshConfigPath")
Import-Module Terminal-Icons
Import-Module PSReadLine # Usually bundled with PowerShell 7+
Set-PSReadLineOption -PredictionSource History
Set-PSReadLineOption -PredictionViewStyle ListView
Set-PSReadLineOption -EditMode Windows
"@

# Get the path to the current user's PowerShell profile for the current host
$profilePath = $PROFILE

# Create the profile file if it doesn't exist
if (-not (Test-Path $profilePath)) {
  Write-Host "Profile file does not exist. Creating: $profilePath"
  try {
    New-Item -Path $profilePath -ItemType File -Force -ErrorAction Stop | Out-Null
    Write-Host "Profile file created." -ForegroundColor Green
  }
  catch {
    Write-Error "Failed to create profile file at $profilePath. Error: $($_.Exception.Message)"
    # Exit # Or continue
  }
}

# Add content to profile if it's not already there to avoid duplicates
$currentProfileContent = Get-Content $profilePath -ErrorAction SilentlyContinue -Raw

# Split desired content into lines for individual checking
$desiredLines = $profileContent.Split([Environment]::NewLine)

foreach ($line in $desiredLines) {
  $trimmedLine = $line.Trim()
  if ($trimmedLine -ne "" -and $currentProfileContent -notmatch [regex]::Escape($trimmedLine)) {
    Write-Host "Adding to profile: $trimmedLine"
    try {
      Add-Content -Path $profilePath -Value $line -ErrorAction Stop
    }
    catch {
      Write-Error "Failed to add line '$trimmedLine' to profile. Error: $($_.Exception.Message)"
    }
  }
  else {
    if ($trimmedLine -ne "") {
      Write-Host "Profile already contains: $trimmedLine" -ForegroundColor Gray
    }
  }
}
Write-Host "PowerShell Profile configuration step completed." -ForegroundColor Green

# --- 5. Manual Step: Configure Windows Terminal Font ---
Write-Host ""
Write-Host "--------------------------------------------------------------------" -ForegroundColor Yellow
Write-Host "MANUAL STEP REQUIRED: Set Font in Windows Terminal" -ForegroundColor Yellow
Write-Host "--------------------------------------------------------------------" -ForegroundColor Yellow
Write-Host "The script cannot automatically change your Windows Terminal font settings."
Write-Host "Please do this manually:"
Write-Host "  1. Open Windows Terminal."
Write-Host "  2. Click the downward arrow (ˇ) in the tab bar and select 'Settings' (or press Ctrl + ,)."
Write-Host "  3. Under 'Profiles', select your default profile (e.g., 'PowerShell')."
Write-Host "  4. Go to the 'Appearance' tab."
Write-Host "  5. Under 'Font face', select 'CaskaydiaCove Nerd Font Mono' (or the specific Nerd Font you installed)."
Write-Host "  6. Click 'Save'."
Write-Host ""
Write-Host "Alternatively, you can edit your settings.json file for the profile:"
Write-Host "(You can open settings.json from Windows Terminal settings UI via 'Open JSON file' button)"
Write-Host "Ensure your PowerShell profile (or defaults) has a font object like this:"
Write-Host ""
Write-Host """
  font: {
      face: "CaskaydiaCove Nerd Font Mono"
  }
""" -ForegroundColor Magenta
Write-Host "(You might also need to set `size` and other font properties if desired)"
Write-Host "--------------------------------------------------------------------" -ForegroundColor Yellow

# --- Final Instructions ---
Write-Host ""
Write-Host "Setup script finished!" -ForegroundColor Green
Write-Host "IMPORTANT: You MUST restart your PowerShell and Windows Terminal sessions for all changes to take full effect." -ForegroundColor Yellow
Write-Host "If you encounter any issues with 'oh-my-posh' command not being found after installation,"
Write-Host "ensure its installation directory (e.g., '$env:LOCALAPPDATA\Programs\oh-my-posh\bin') is in your system's PATH environment variable."