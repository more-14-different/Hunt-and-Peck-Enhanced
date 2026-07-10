param(
    [switch]$Release,
    [switch]$Debug,
    [switch]$NoBuild,
    [switch]$Restore,
    [switch]$UseCake,
    [switch]$StopOnly,
    [switch]$Hint,
    [switch]$Tray,
    [string[]]$AppArgs = @()
)

$ErrorActionPreference = "Stop"

if ($Release -and $Debug) {
    throw "Use either -Release or -Debug, not both."
}

$RepoDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$SrcDir = Join-Path $RepoDir "src"
$BuildScript = Join-Path $SrcDir "build.ps1"
$SolutionPath = Join-Path $SrcDir "HuntAndPeck.sln"
$Configuration = if ($Release) { "Release" } else { "Debug" }
$ExeName = "hap"
$ExePath = Join-Path $SrcDir "HuntAndPeck\bin\$Configuration\$ExeName.exe"

if ($Hint) {
    $AppArgs += "/hint"
}

if ($Tray) {
    $AppArgs += "/tray"
}

function Stop-LauncherHosts {
    if (-not (Get-Command Get-CimInstance -ErrorAction SilentlyContinue)) {
        return
    }

    $scriptPath = $MyInvocation.MyCommand.Definition
    Get-CimInstance Win32_Process -ErrorAction SilentlyContinue |
        Where-Object {
            ($_.Name -eq "powershell.exe" -or $_.Name -eq "pwsh.exe") -and
            $_.CommandLine -like "*$scriptPath*" -and
            $_.ProcessId -ne $PID
        } |
        ForEach-Object {
            Stop-Process -Id $_.ProcessId -Force -ErrorAction SilentlyContinue
        }
}

function Get-MSBuildPath {
    $vswhere = Join-Path ${env:ProgramFiles(x86)} "Microsoft Visual Studio\Installer\vswhere.exe"
    if (Test-Path -LiteralPath $vswhere -PathType Leaf) {
        $path = & $vswhere -latest -products * -requires Microsoft.Component.MSBuild -find "MSBuild\**\Bin\MSBuild.exe" |
            Select-Object -First 1
        if ($path) {
            return $path
        }
    }

    $command = Get-Command MSBuild.exe -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    throw "MSBuild.exe not found. Install Visual Studio Build Tools with MSBuild."
}

function Get-NuGetPath {
    $toolsNuGet = Join-Path $SrcDir "tools\nuget.exe"
    if (Test-Path -LiteralPath $toolsNuGet -PathType Leaf) {
        return $toolsNuGet
    }

    $repoNuGet = Join-Path $SrcDir ".nuget\NuGet.exe"
    if (Test-Path -LiteralPath $repoNuGet -PathType Leaf) {
        return $repoNuGet
    }

    $command = Get-Command nuget.exe -ErrorAction SilentlyContinue
    if ($command) {
        return $command.Source
    }

    return $null
}

function Invoke-DebugBuild {
    if ($UseCake) {
        Push-Location $SrcDir
        try {
            & $BuildScript -Target Build -Configuration $Configuration
            if ($LASTEXITCODE -ne 0) {
                throw "Cake build failed with exit code $LASTEXITCODE."
            }
        }
        finally {
            Pop-Location
        }
        return
    }

    if ($Restore) {
        $nuget = Get-NuGetPath
        if (-not $nuget) {
            throw "NuGet.exe not found. Cannot restore packages."
        }

        & $nuget restore $SolutionPath -NonInteractive
        if ($LASTEXITCODE -ne 0) {
            throw "NuGet restore failed with exit code $LASTEXITCODE."
        }
    }

    $msbuild = Get-MSBuildPath
    & $msbuild $SolutionPath /t:Build /p:Configuration=$Configuration /p:Platform="Any CPU" /m /nr:false /v:minimal
    if ($LASTEXITCODE -ne 0) {
        throw "MSBuild failed with exit code $LASTEXITCODE. If it reports missing .NET Framework 4.5.1/4.5.2 reference assemblies, install those targeting packs or retarget the projects."
    }
}

Get-Process $ExeName -ErrorAction SilentlyContinue | Stop-Process -Force
Stop-LauncherHosts

if ($StopOnly) {
    exit 0
}

if (-not $NoBuild) {
    Invoke-DebugBuild
}

if (-not (Test-Path -LiteralPath $ExePath -PathType Leaf)) {
    throw "Executable not found: $ExePath"
}

Start-Process -FilePath $ExePath -ArgumentList $AppArgs -WorkingDirectory (Split-Path -Parent $ExePath)
