$ErrorActionPreference = 'SilentlyContinue'

$swKey = 'HKCU:\Software\Macromedia\Shockwave 8\renderer3dsetting'
New-Item -Path 'HKCU:\Software\Macromedia\Shockwave 8' -Force | Out-Null
New-Item -Path $swKey -Force | Out-Null
Set-ItemProperty -Path $swKey -Name '(default)' -Value '1' -Type String

Add-Type -AssemblyName System.Windows.Forms
Add-Type @'
using System;
using System.Text;
using System.Runtime.InteropServices;

public static class SimuroWindowResize {
    public delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);
    public delegate bool EnumChildProc(IntPtr hWnd, IntPtr lParam);

    [StructLayout(LayoutKind.Sequential)]
    public struct RECT {
        public int Left, Top, Right, Bottom;
    }

    [DllImport("user32.dll")]
    public static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);

    [DllImport("user32.dll")]
    public static extern bool EnumChildWindows(IntPtr hWnd, EnumChildProc lpEnumFunc, IntPtr lParam);

    [DllImport("user32.dll")]
    public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);

    [DllImport("user32.dll", CharSet = CharSet.Unicode)]
    public static extern int GetClassName(IntPtr hWnd, StringBuilder lpClassName, int nMaxCount);

    [DllImport("user32.dll")]
    public static extern bool GetWindowRect(IntPtr hWnd, out RECT rect);

    [DllImport("user32.dll")]
    public static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);

    [DllImport("user32.dll")]
    public static extern bool SetForegroundWindow(IntPtr hWnd);

    [DllImport("user32.dll")]
    public static extern bool SetProcessDPIAware();
}
'@

[SimuroWindowResize]::SetProcessDPIAware() | Out-Null

$sim = Start-Process -FilePath 'C:\Strategy\SimuroSot5.exe' -WorkingDirectory 'C:\Strategy' -PassThru

$deadline = (Get-Date).AddSeconds(30)
$child = [IntPtr]::Zero
$parent = [IntPtr]::Zero

while ((Get-Date) -lt $deadline) {
    $wm = Get-Process WorldModel -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($wm) {
        $top = New-Object System.Collections.ArrayList
        $callback = [SimuroWindowResize+EnumWindowsProc]{
            param($h, $l)
            $pid2 = 0
            [SimuroWindowResize]::GetWindowThreadProcessId($h, [ref]$pid2) | Out-Null
            if ($pid2 -eq $wm.Id) {
                [void]$top.Add($h)
            }
            return $true
        }
        [SimuroWindowResize]::EnumWindows($callback, [IntPtr]::Zero) | Out-Null

        foreach ($topWindow in $top) {
            $rect = New-Object SimuroWindowResize+RECT
            [SimuroWindowResize]::GetWindowRect($topWindow, [ref]$rect) | Out-Null
            if (($rect.Right - $rect.Left) -gt 500) {
                $parent = $topWindow
            }

            $children = New-Object System.Collections.ArrayList
            $childCallback = [SimuroWindowResize+EnumChildProc]{
                param($h, $l)
                [void]$children.Add($h)
                return $true
            }
            [SimuroWindowResize]::EnumChildWindows($topWindow, $childCallback, [IntPtr]::Zero) | Out-Null

            foreach ($childWindow in $children) {
                $class = New-Object Text.StringBuilder 256
                [SimuroWindowResize]::GetClassName($childWindow, $class, 256) | Out-Null
                if ($class.ToString() -eq 'TRONCLASS') {
                    $child = $childWindow
                }
            }
        }
    }

    if ($child -ne [IntPtr]::Zero -and $parent -ne [IntPtr]::Zero) {
        break
    }

    Start-Sleep -Milliseconds 300
}

if ($child -eq [IntPtr]::Zero -or $parent -eq [IntPtr]::Zero) {
    exit
}

$work = [System.Windows.Forms.Screen]::PrimaryScreen.WorkingArea
$scaleX = $work.Width / 1900.0
$scaleY = $work.Height / 1450.0
$scale = [Math]::Min(1.0, [Math]::Min($scaleX, $scaleY))

$parentW = [Math]::Round(1850 * $scale)
$parentH = [Math]::Round(1424 * $scale)
$childW = [Math]::Round(1600 * $scale)
$childH = [Math]::Round(1200 * $scale)
$childX = [Math]::Round($parentW * 0.116)
$childY = [Math]::Round($parentH * 0.085)

$flagsResize = 0x0004 -bor 0x0010
[SimuroWindowResize]::SetWindowPos($child, [IntPtr]::Zero, $childX, $childY, $childW, $childH, $flagsResize) | Out-Null
[SimuroWindowResize]::SetWindowPos($parent, [IntPtr]::Zero, 0, 0, $parentW, $parentH, $flagsResize) | Out-Null
[SimuroWindowResize]::SetForegroundWindow($parent) | Out-Null
