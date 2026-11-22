param(
    [string]$ReleaseDirectory = (Join-Path $PSScriptRoot '../build/windows/x64/runner/Release'),
    [string]$OutputDirectory = (Join-Path $PSScriptRoot '../build/distribution')
)

$ErrorActionPreference = 'Stop'
$release = (Resolve-Path -LiteralPath $ReleaseDirectory).ProviderPath
$output = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath($OutputDirectory)
$output = [IO.Path]::GetFullPath($output)
$releasePrefix = $release.TrimEnd('\', '/') + [IO.Path]::DirectorySeparatorChar
if ($output -eq $release -or $output.StartsWith($releasePrefix, [StringComparison]::OrdinalIgnoreCase)) {
    throw 'Choose an output directory outside the release bundle.'
}

foreach ($file in 'focuspilot.exe', 'flutter_windows.dll', 'sqlite3.dll', 'data/app.so', 'data/icudtl.dat', 'data/flutter_assets/AssetManifest.bin') {
    if (-not (Test-Path -LiteralPath (Join-Path $release $file) -PathType Leaf)) {
        throw "Missing $file. Build FocusPilot with 'flutter build windows --release' first."
    }
}

# Flutter deploys the executable, native DLLs and data directory. The test
# runner can also leave a machine-specific native_assets.json at the root.
$files = @((Get-Item -LiteralPath (Join-Path $release 'focuspilot.exe')))
$files += Get-ChildItem -LiteralPath $release -File -Filter '*.dll'
$files += Get-ChildItem -LiteralPath (Join-Path $release 'data') -File -Recurse -Force

[IO.Directory]::CreateDirectory($output) | Out-Null
$name = 'focuspilot-windows-x64.zip'
$archivePath = Join-Path $output $name
$tempPath = Join-Path $output ([guid]::NewGuid().ToString() + '.zip')
Add-Type -AssemblyName System.IO.Compression.FileSystem
try {
    $zip = [IO.Compression.ZipFile]::Open($tempPath, [IO.Compression.ZipArchiveMode]::Create)
    try {
        foreach ($file in $files) {
            $entry = $file.FullName.Substring($releasePrefix.Length).Replace('\', '/')
            [IO.Compression.ZipFileExtensions]::CreateEntryFromFile($zip, $file.FullName, $entry) | Out-Null
        }
    } finally {
        $zip.Dispose()
    }
    $checksum = (Get-FileHash -LiteralPath $tempPath -Algorithm SHA256).Hash.ToLowerInvariant()
    Move-Item -LiteralPath $tempPath -Destination $archivePath -Force
    Set-Content -LiteralPath "$archivePath.sha256" -Value "$checksum  $name" -Encoding ascii
    Write-Output $archivePath
} finally {
    if (Test-Path -LiteralPath $tempPath) {
        Remove-Item -LiteralPath $tempPath
    }
}
