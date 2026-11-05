$ErrorActionPreference = 'Stop'
$appDir = Split-Path -Parent $MyInvocation.MyCommand.Path
$appFile = Join-Path $appDir 'Focus_Sprint_Study_Planner_PC.html'
if (-not (Test-Path $appFile)) {
    Write-Host 'Focus Sprint HTML file was not found. Extract all ZIP files into one folder.' -ForegroundColor Red
    Read-Host 'Press Enter to close'
    exit 1
}

# Find Python/Anaconda. The app itself is still a normal self-contained HTML file.
$pythonPath = $null
$pythonArgsPrefix = @()
$pyLauncher = Get-Command 'py.exe' -ErrorAction SilentlyContinue
$pythonCommand = Get-Command 'python.exe' -ErrorAction SilentlyContinue
if ($pyLauncher) {
    $pythonPath = $pyLauncher.Source
    $pythonArgsPrefix = @('-3')
} elseif ($pythonCommand) {
    $pythonPath = $pythonCommand.Source
} else {
    $candidates = @(
        (Join-Path $env:USERPROFILE 'anaconda3\python.exe'),
        (Join-Path $env:USERPROFILE 'miniconda3\python.exe'),
        'D:\Anaconda\python.exe',
        'C:\ProgramData\anaconda3\python.exe',
        (Join-Path $env:LOCALAPPDATA 'Programs\Python\Python313\python.exe'),
        (Join-Path $env:LOCALAPPDATA 'Programs\Python\Python312\python.exe')
    )
    foreach ($candidate in $candidates) {
        if ($candidate -and (Test-Path $candidate)) { $pythonPath = $candidate; break }
    }
}

# Without Python, try the standalone HTML in the default browser.
if (-not $pythonPath) {
    Start-Process $appFile
    Write-Host 'Opened the standalone HTML file. If local saving is unavailable, make Python/Anaconda available and run this launcher again.' -ForegroundColor Yellow
    exit 0
}

$portFile = Join-Path $appDir '.focus-sprint-port'
$port = 8765
if (Test-Path $portFile) {
    $savedPort = 0
    if ([int]::TryParse((Get-Content $portFile -Raw).Trim(), [ref]$savedPort) -and $savedPort -ge 1024 -and $savedPort -le 65535) {
        $port = $savedPort
    }
}

function Test-FocusSprintServer([int]$candidatePort) {
    try {
        $url = "http://127.0.0.1:$candidatePort/Focus_Sprint_Study_Planner_PC.html"
        $response = Invoke-WebRequest -Uri $url -UseBasicParsing -TimeoutSec 2
        return ($response.StatusCode -eq 200 -and $response.Content.Contains('FOCUS SPRINT'))
    } catch {
        return $false
    }
}

# Reuse the same local address on later launches so browser progress stays on
# the same origin and does not look like a brand-new planner.
if (Test-FocusSprintServer $port) {
    Start-Process "http://127.0.0.1:$port/Focus_Sprint_Study_Planner_PC.html"
    exit 0
}

# Check whether the remembered port is free. If another app owns it, select a
# free local port and save it for future launches.
$listener = $null
try {
    $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, $port)
    $listener.Start()
    $listener.Stop()
    $listener = $null
} catch {
    if ($listener) { try { $listener.Stop() } catch {} }
    $listener = [System.Net.Sockets.TcpListener]::new([System.Net.IPAddress]::Loopback, 0)
    $listener.Start()
    $port = ([System.Net.IPEndPoint]$listener.LocalEndpoint).Port
    $listener.Stop()
}

$pythonArgs = @($pythonArgsPrefix) + @('-m', 'http.server', "$port", '--bind', '127.0.0.1')
try {
    Start-Process -FilePath $pythonPath -ArgumentList $pythonArgs -WorkingDirectory $appDir -WindowStyle Hidden
    Start-Sleep -Milliseconds 1200
    if (-not (Test-FocusSprintServer $port)) { throw 'The local server did not start.' }
    Set-Content -Path $portFile -Value $port -Encoding ASCII
    Start-Process "http://127.0.0.1:$port/Focus_Sprint_Study_Planner_PC.html"
} catch {
    Write-Host 'Could not start the local server. Opening the HTML file directly instead.' -ForegroundColor Yellow
    Start-Process $appFile
}
