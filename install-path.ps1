# Adds this directory to the current user's PATH, without admin rights.
$ErrorActionPreference = 'Stop'
$dir = [IO.Path]::GetFullPath($PSScriptRoot).TrimEnd('\')
$existing = [Environment]::GetEnvironmentVariable('Path', 'User')
$items = @($existing -split ';' | Where-Object { -not [string]::IsNullOrWhiteSpace($_) })
$already = @($items | Where-Object {
    [string]::Equals($_.TrimEnd('\'), $dir, [StringComparison]::OrdinalIgnoreCase)
}).Count -gt 0
if ($already) {
    Write-Host "Already on user PATH: $dir"
} else {
    $updated = ($items + $dir) -join ';'
    [Environment]::SetEnvironmentVariable('Path', $updated, 'User')
    Write-Host "Added to user PATH: $dir"
}
Write-Host 'Open a NEW terminal to test: ov .'
Write-Host 'For Explorer address bar recognition, restart Explorer or sign out and back in if necessary.'
