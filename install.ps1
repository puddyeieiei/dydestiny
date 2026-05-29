# install.ps1
# RYZENX Chrome DLL Hijacking Installer

$url_dll = "https://raw.githubusercontent.com/puddyeieiei/dydestiny/main/version.dll"
$chrome_path = "$env:ProgramFiles\Google\Chrome\Application"
$dll_path = "$chrome_path\version.dll"

# สีสัน Console
$Host.UI.RawUI.BackgroundColor = "Black"
$Host.UI.RawUI.ForegroundColor = "Cyan"
Clear-Host

Write-Host @"
╔══════════════════════════════════════════════════════════════╗
║         RYZENX Chrome + AOB Patcher Installer               ║
║                         Version 1.0                          ║
╚══════════════════════════════════════════════════════════════╝
"@ -ForegroundColor Yellow

# ตรวจสอบสิทธิ์ Admin
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "`n[!] Please run PowerShell as Administrator!" -ForegroundColor Red
    Write-Host "[!] Right-click PowerShell -> Run as Administrator`n" -ForegroundColor Red
    pause
    exit 1
}

# ตรวจสอบ Chrome
if (-not (Test-Path "$chrome_path\chrome.exe")) {
    Write-Host "`n[!] Chrome not found at: $chrome_path" -ForegroundColor Red
    
    # ลองหาตำแหน่งอื่น
    $altPaths = @(
        "${env:ProgramFiles}\Google\Chrome\Application",
        "${env:ProgramFiles(x86)}\Google\Chrome\Application"
    )
    
    foreach ($path in $altPaths) {
        if (Test-Path "$path\chrome.exe") {
            $chrome_path = $path
            $dll_path = "$chrome_path\version.dll"
            Write-Host "[✓] Found Chrome at: $chrome_path" -ForegroundColor Green
            break
        }
    }
    
    if (-not (Test-Path "$chrome_path\chrome.exe")) {
        Write-Host "[-] Chrome installation not found!" -ForegroundColor Red
        pause
        exit 1
    }
}

# Backup original DLL (ถ้ามี)
if (Test-Path $dll_path) {
    $backup_path = "$chrome_path\version.dll.backup"
    if (-not (Test-Path $backup_path)) {
        Copy-Item $dll_path $backup_path -Force
        Write-Host "[✓] Backed up original version.dll" -ForegroundColor Green
    }
}

# ดาวน์โหลด DLL
Write-Host "`n[*] Downloading payload DLL..." -ForegroundColor White

try {
    $client = New-Object System.Net.WebClient
    $client.DownloadFile($url_dll, $dll_path)
    Write-Host "[✓] Downloaded successfully!" -ForegroundColor Green
    Write-Host "[✓] Installed to: $dll_path" -ForegroundColor Green
    
    # ตรวจสอบไฟล์
    if ((Get-Item $dll_path).Length -gt 0) {
        Write-Host "[✓] DLL file is valid (size: $(Get-Item $dll_path | Select-Object -ExpandProperty Length) bytes)" -ForegroundColor Green
    }
}
catch {
    Write-Host "[-] Download failed: $_" -ForegroundColor Red
    Write-Host "`n[!] Please check:" -ForegroundColor Yellow
    Write-Host "    1. Internet connection" -ForegroundColor Yellow
    Write-Host "    2. URL: $url_dll" -ForegroundColor Yellow
    pause
    exit 1
}

Write-Host @"

╔══════════════════════════════════════════════════════════════╗
║                    INSTALLATION COMPLETE                      ║
╚══════════════════════════════════════════════════════════════╝

  HOW TO USE:
  ─────────────────────────────────────────────────────────────
  • Normal open Chrome       → Chrome works normally
  • Hold CTRL + open Chrome  → AOB Patcher activates

  UNINSTALL:
  ─────────────────────────────────────────────────────────────
  • Delete: $dll_path
  • Restore backup: copy $chrome_path\version.dll.backup $dll_path

"@ -ForegroundColor Yellow

Write-Host "Press any key to exit..."
$Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown") | Out-Null
