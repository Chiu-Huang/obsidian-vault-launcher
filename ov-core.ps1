# Open a Windows folder as an Obsidian vault.
# Registered vaults use the official obsidian:// URI.
# Unknown vaults require the Obsidian 1.12+ CLI and use an unofficial IPC call.
[CmdletBinding()]
param(
    [Parameter(Position = 0)]
    [string] $Folder = '.',
    [switch] $CheckOnly
)

$ErrorActionPreference = 'Stop'

try {
    $resolved = Resolve-Path -LiteralPath $Folder -ErrorAction Stop
    $path = [IO.Path]::GetFullPath($resolved.ProviderPath)
    if (-not (Test-Path -LiteralPath $path -PathType Container)) {
        throw "Not a directory: $path"
    }

    $configFile = Join-Path $env:APPDATA 'obsidian\obsidian.json'
    $vaultId = $null
    if (Test-Path -LiteralPath $configFile) {
        $config = Get-Content -LiteralPath $configFile -Raw -Encoding UTF8 | ConvertFrom-Json
        if ($config.vaults) {
            foreach ($entry in $config.vaults.PSObject.Properties) {
                $registeredPath = [string] $entry.Value.path
                if (-not $registeredPath) { continue }
                $a = [IO.Path]::GetFullPath($registeredPath).TrimEnd('\', '/')
                $b = $path.TrimEnd('\', '/')
                if ([string]::Equals($a, $b, [StringComparison]::OrdinalIgnoreCase)) {
                    $vaultId = $entry.Name
                    break
                }
            }
        }
    }

    if ($vaultId) {
        Write-Host "Vault already registered: $path"
        if (-not $CheckOnly) {
            $uri = 'obsidian://open?vault=' + [uri]::EscapeDataString($vaultId)
            Start-Process -FilePath $uri
            Write-Host 'Opened via official Obsidian URI.'
        }
        exit 0
    }

    $candidates = @()
    $installed = Get-Command 'Obsidian.com' -CommandType Application -ErrorAction SilentlyContinue
    if ($installed) { $candidates += $installed.Source }
    $candidates += @(
        (Join-Path $env:LOCALAPPDATA 'Obsidian\Obsidian.com'),
        (Join-Path $env:LOCALAPPDATA 'Programs\Obsidian\Obsidian.com'),
        'C:\Program Files\Obsidian\Obsidian.com'
    )
    $cli = $candidates | Where-Object { $_ -and (Test-Path -LiteralPath $_ -PathType Leaf) } |
        Select-Object -First 1

    if ($cli) {
        Write-Host "New or unregistered vault: $path"
        Write-Host "Using Obsidian CLI: $cli"
        if (-not $CheckOnly) {
            if (-not (Get-Process 'Obsidian' -ErrorAction SilentlyContinue)) {
                throw 'Start the Obsidian app first, then retry.'
            }
            # Base64 avoids Windows PowerShell stripping embedded double quotes.
            $encodedPath = [Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($path))
            $js = "window.electron.ipcRenderer.sendSync('vault-open', Buffer.from('$encodedPath','base64').toString('utf8'), false)"
            $cliOutput = @(& $cli 'eval' ("code=" + $js) 2>&1)
            $cliExitCode = $LASTEXITCODE
            foreach ($line in $cliOutput) { Write-Host ([string] $line) }
            if ($cliExitCode -ne 0 -or ($cliOutput -match '^\s*(?:Error|SyntaxError|TypeError|ReferenceError):')) {
                throw "Obsidian could not open the vault (CLI exit code $cliExitCode)."
            }
            Write-Host 'Sent open-vault request (unofficial IPC).'
        }
        exit 0
    }

    Write-Warning 'This folder is not registered as an Obsidian vault.'
    Write-Warning 'No Obsidian.com CLI was found. Obsidian 1.12.7+ installer and CLI setup are required for automatic opening of new folders.'
    Write-Warning 'See README.md in the obsidian-vault-launcher folder.'
    if (-not $CheckOnly) {
        Write-Host 'Opening Obsidian Vault Manager instead...'
        Start-Process -FilePath 'obsidian://choose-vault'
    }
    exit 2
}
catch {
    Write-Error $_.Exception.Message
    exit 1
}
