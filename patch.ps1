# RYZENX AOB Patcher via PowerShell
# Run this script as Administrator

# Force UTF-8 Output for special characters
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

$ESC = [char]27
$cGold = "$ESC[38;5;220m"
$cGray = "$ESC[38;5;244m"
$cGreen = "$ESC[38;5;82m"
$cRed = "$ESC[38;5;196m"
$cDarkGray = "$ESC[38;5;242m"
$cOrange = "$ESC[38;5;136m"
$cPink = "$ESC[38;5;203m"
$cWhite = "$ESC[37m"
$cReset = "$ESC[0m"

# Check for Administrator privileges
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Write-Host ("{0}[-] Access Denied: Administrator privileges required.{1}" -f $cRed, $cReset)
    Write-Host ("{0}[>] Attempting to elevate script...{1}" -f $cGold, $cReset)
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    Exit
}

# Win32 API Definitions
$Signature = @"
using System;
using System.Runtime.InteropServices;

public class Win32 {
    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern IntPtr OpenProcess(uint processAccess, bool bInheritHandle, int processId);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool WriteProcessMemory(IntPtr hProcess, IntPtr lpBaseAddress, byte[] lpBuffer, int nSize, out IntPtr lpNumberOfBytesWritten);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool VirtualProtectEx(IntPtr hProcess, IntPtr lpAddress, UIntPtr dwSize, uint flNewProtect, out uint lpflOldProtect);

    [DllImport("kernel32.dll", SetLastError = true)]
    public static extern bool CloseHandle(IntPtr hObject);

    [DllImport("user32.dll")]
    public static extern short GetAsyncKeyState(int vKey);
}
"@

if (-not ([System.Management.Automation.PSTypeName]"Win32").Type) {
    Add-Type -TypeDefinition $Signature
}

# Terminal Styling
function Print-Header {
    Clear-Host
    Write-Host ("{0}== RYZENX =============================================================={1}" -f $cGold, $cReset)
    Write-Host ("  {0}[+] DESTINY SHOP POWERSHELL MODULE               STATUS: ONLINE{1}" -f $cGray, $cReset)
    Write-Host ("{0}========================================================================{1}`n" -f $cGold, $cReset)
}

function Print-Footer {
    Write-Host ("{0}========================================================================{1}" -f $cGold, $cReset)
    Write-Host ("  {0}DESTINY SHOP (c) 2026 | SECURED INTERNAL SYSTEM{1}" -f $cDarkGray, $cReset)
}

function Write-Memory {
    param (
        [IntPtr]$hProcess,
        [IntPtr]$address,
        [UInt32]$value
    )
    $buffer = [BitConverter]::GetBytes($value)
    $oldProtect = 0
    # PAGE_EXECUTE_READWRITE is 0x40
    if ([Win32]::VirtualProtectEx($hProcess, $address, [UIntPtr][uint]4, 0x40, [ref]$oldProtect)) {
        $written = [IntPtr]::Zero
        $success = [Win32]::WriteProcessMemory($hProcess, $address, $buffer, 4, [ref]$written)
        $tempProtect = 0
        [Win32]::VirtualProtectEx($hProcess, $address, [UIntPtr][uint]4, $oldProtect, [ref]$tempProtect)
        return $success
    }
    return $false
}

# Main Application Loop
Print-Header

Write-Host ("  {0}[~] Waiting for GTAProcess.exe or FiveM_GTAProcess.exe...{1}" -f $cOrange, $cReset)

$proc = $null
while ($null -eq $proc) {
    $proc = Get-Process -Name "FiveM_GTAProcess" -ErrorAction SilentlyContinue
    if ($null -eq $proc) {
        $proc = Get-Process -Name "GTAProcess" -ErrorAction SilentlyContinue
    }
    if ($null -eq $proc) {
        Start-Sleep -Milliseconds 500
    }
}

$pidVal = $proc.Id
Write-Host ("  {0}[+] Found target process with PID: {1}{2}" -f $cGreen, $pidVal, $cReset)

# Open Process
# PROCESS_VM_READ (0x10) | PROCESS_VM_WRITE (0x20) | PROCESS_VM_OPERATION (0x8) | PROCESS_QUERY_INFORMATION (0x400) = 0x438
$hProcess = [Win32]::OpenProcess(0x438, $false, $pidVal)
if ($hProcess -eq [IntPtr]::Zero) {
    Write-Host ("  {0}[-] Failed to open process handle.{1}" -f $cRed, $cReset)
    Start-Sleep -Seconds 3
    Exit
}

# Resolve Module & Base Address
$moduleName = ""
$baseAddress = [IntPtr]::Zero
$offset = 0

Write-Host ("  {0}[~] Finding module base address...{1}" -f $cOrange, $cReset)
while ($baseAddress -eq [IntPtr]::Zero) {
    # Refresh process modules
    $proc.Refresh()
    try {
        foreach ($mod in $proc.Modules) {
            if ($mod.ModuleName -eq "FiveM_b2699_GTAProcess.exe") {
                $moduleName = $mod.ModuleName
                $baseAddress = $mod.BaseAddress
                $offset = 0x9B0AE9
                break
            }
            elseif ($mod.ModuleName -eq "FiveM_b3095_GTAProcess.exe") {
                $moduleName = $mod.ModuleName
                $baseAddress = $mod.BaseAddress
                $offset = 0x9BF24E
                break
            }
            elseif ($mod.ModuleName -eq "FiveM_GTAProcess.exe") {
                $moduleName = $mod.ModuleName
                $baseAddress = $mod.BaseAddress
                $offset = 0x9C2C82
                break
            }
        }
    } catch {
        # Modules might not be fully loaded yet
    }
    if ($baseAddress -eq [IntPtr]::Zero) {
        Start-Sleep -Milliseconds 500
    }
}

$targetAddress = [IntPtr]($baseAddress.ToInt64() + $offset)
Write-Host ("  {0}[+] Detected Module: {1}{2}" -f $cGreen, $moduleName, $cReset)
Write-Host ("  {0}[+] Target Address: 0x{1}{2}" -f $cGreen, $targetAddress.ToString("X"), $cReset)
Start-Sleep -Seconds 1

$dfValue = [uint32]0x604F280F
$patchValue = [uint32]0x605F280F

$alwaysActive = $false
$hotkeyBind = $null
$hotkeyChar = ""

while ($true) {
    Print-Header
    
    # Render Option 1
    Write-Host ("  {0}+----------------------------------------------------------------+{1}" -f $cGold, $cReset)
    Write-Host ("  {0}| {1}[1] ALWAYS ACTIVE                                              {0}|{2}" -f $cGold, $cWhite, $cReset)
    if ($alwaysActive) {
        Write-Host ("  {0}| {1}    Status: {2}ENABLED                                            {0}|{3}" -f $cGold, $cWhite, $cGreen, $cReset)
    } else {
        Write-Host ("  {0}| {1}    Status: {2}DISABLED                                           {0}|{3}" -f $cGold, $cWhite, $cPink, $cReset)
    }
    Write-Host ("  {0}+----------------------------------------------------------------+{1}`n" -f $cGold, $cReset)

    # Render Option 2
    Write-Host ("  {0}+----------------------------------------------------------------+{1}" -f $cGold, $cReset)
    Write-Host ("  {0}| {1}[2] HOLD (HOTKEY)                                              {0}|{2}" -f $cGold, $cWhite, $cReset)
    $hkDisp = if ($null -ne $hotkeyBind) { $hotkeyChar } else { "-" }
    Write-Host ("  {0}| {1}    Hotkey Bind: {0}[{3}]                                           {0}|{2}" -f $cGold, $cWhite, $cReset, $hkDisp)
    Write-Host ("  {0}+----------------------------------------------------------------+{1}`n" -f $cGold, $cReset)

    # Render Option 3
    Write-Host ("  {0}+----------------------------------------------------------------+{1}" -f $cGold, $cReset)
    Write-Host ("  {0}| {1}[3] RESET                                                      {0}|{2}" -f $cGold, $cWhite, $cReset)
    Write-Host ("  {0}| {1}    Action: {0}FLUSH ALL VARIABLES                                {0}|{2}" -f $cGold, $cWhite, $cReset)
    Write-Host ("  {0}+----------------------------------------------------------------+{1}`n" -f $cGold, $cReset)

    Print-Footer
    
    if ($null -ne $hotkeyBind) {
        Write-Host ("`n  {0}[~] Monitoring Hotkey [{1}]. Press [Enter] key in this window to menu.{2}" -f $cGold, $hotkeyChar, $cReset)
        
        $active = $false
        while ($true) {
            # Check if Enter key was pressed in console to break out
            if ([Console]::KeyAvailable) {
                $key = [Console]::ReadKey($true)
                if ($key.Key -eq 'Enter') {
                    $hotkeyBind = $null
                    $hotkeyChar = ""
                    # Restore default memory state on breaking out
                    Write-Memory $hProcess $targetAddress $dfValue
                    break
                }
            }

            # Check Hotkey state (async)
            $state = [Win32]::GetAsyncKeyState($hotkeyBind)
            $isPressed = ($state -band 0x8000) -ne 0

            if ($isPressed -ne $active) {
                $active = $isPressed
                if ($active) {
                    [Console]::Beep(600, 150)
                    Write-Memory $hProcess $targetAddress $patchValue
                } else {
                    [Console]::Beep(400, 150)
                    Write-Memory $hProcess $targetAddress $dfValue
                }
            }
            Start-Sleep -Milliseconds 10
        }
        continue
    }

    $choice = Read-Host "  Select option"
    
    if ($choice -eq "1") {
        $alwaysActive = $true
        $hotkeyBind = $null
        $hotkeyChar = ""
        $success = Write-Memory $hProcess $targetAddress $patchValue
        if ($success) {
            [Console]::Beep(600, 150)
        } else {
            Write-Host ("  {0}[-] Memory write failed.{1}" -f $cRed, $cReset)
            Start-Sleep -Seconds 2
        }
    }
    elseif ($choice -eq "3") {
        $alwaysActive = $false
        $hotkeyBind = $null
        $hotkeyChar = ""
        $success = Write-Memory $hProcess $targetAddress $dfValue
        if ($success) {
            [Console]::Beep(400, 150)
        } else {
            Write-Host ("  {0}[-] Memory write failed.{1}" -f $cRed, $cReset)
            Start-Sleep -Seconds 2
        }
    }
    elseif ($choice -eq "2") {
        $alwaysActive = $false
        Print-Header
        Write-Host ("  {0}+----------------------------------------------------------------+{1}" -f $cGold, $cReset)
        Write-Host ("  {0}| {1}[2] HOLD (HOTKEY)                                              {0}|{2}" -f $cGold, $cWhite, $cReset)
        Write-Host ("  {0}| {1}    Enter Hotkey Bind (A-Z):                                   {0}|{2}" -f $cGold, $cWhite, $cReset)
        Write-Host ("  {0}+----------------------------------------------------------------+{1}`n" -f $cGold, $cReset)
        Print-Footer
        
        $hk = Read-Host "  Select option (A-Z)"
        if ($hk -match '^[a-zA-Z]$') {
            $hotkeyChar = $hk.ToUpper()
            $hotkeyBind = [int][char]$hotkeyChar
            [Console]::Beep(600, 150)
        } else {
            Write-Host ("  {0}[-]-Invalid Hotkey. Must be a single letter A-Z.{1}" -f $cRed, $cReset)
            Start-Sleep -Seconds 2
        }
    }
}

# Clean Up
[Win32]::CloseHandle($hProcess)
