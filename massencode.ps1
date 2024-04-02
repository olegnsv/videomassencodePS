param (
    [string]$inputFolder,
    [string]$outputFolder
)

function Show-Help {
    Write-Host "Usage: .\massencode.ps1 '\path\to\input\folder' '\path\to\output\folder'"
    Write-Host "First parameter - Folder containing input files."
    Write-Host "Second parameter - Folder for output files."
    exit
}

if (-not $inputFolder -or -not $outputFolder) {
    Show-Help
}

if (-not (Test-Path -Path $outputFolder -PathType Container)) {
    New-Item -ItemType Directory -Path $outputFolder
}

$files = Get-ChildItem -Path $inputFolder -File -Filter *.mp4
$totalFiles = $files.Count
$currentFileIndex = 0

$ffmpegPath = Join-Path -Path $PSScriptRoot -ChildPath "ffmpeg.exe"
if (-not (Test-Path -Path $ffmpegPath)) {
    try {
        $ffmpegPath = (Get-Command ffmpeg.exe).Source
        Write-Host "Using ffmpeg from PATH: $ffmpegPath" -ForegroundColor Yellow
    }
    catch {
        Write-Host "ffmpeg.exe could not be found. Please ensure it is installed and available in the PATH." -ForegroundColor Red
        exit
    }
} else {
    Write-Host "Using ffmpeg from the script's directory: $ffmpegPath" -ForegroundColor Yellow
}

function Stop-FFmpeg {
    Get-Process ffmpeg -ErrorAction SilentlyContinue | Stop-Process -Force
    Write-Host "`nExiting, ffmpeg stopped."
}

$spinner = @('|', '/', '-', '\')
$spinnerPosition = 0

try {
    foreach ($file in $files) {
        $currentFileIndex++
        $sourceFile = $file.FullName
        $outputFile = Join-Path -Path $outputFolder -ChildPath ($file.BaseName + "_converted.mp4")

        Write-Host "`nProcessing file ($currentFileIndex/$totalFiles): $file.Name" -ForegroundColor Cyan
        
        $process = Start-Process -FilePath $ffmpegPath -ArgumentList "-loglevel error -y -i `"$sourceFile`" -map 0:v -map 0:a -vcodec libx265 -q:v 10 -r:v 60 `"$outputFile`"" -NoNewWindow -PassThru
        
        while (!$process.HasExited) {
            $spinnerPosition = ($spinnerPosition + 1) % $spinner.Length
            Write-Host "`r[$($spinner[$spinnerPosition])] Converting..." -NoNewline
            Start-Sleep -Milliseconds 200
        }

        if (Test-Path -Path $outputFile) {
            Remove-Item -Path $sourceFile -Force
            Write-Host "`rConversion successful. Source file deleted.`n" -ForegroundColor Green
        } else {
            Write-Host "`rConversion failed for $sourceFile, source file not deleted.`n" -ForegroundColor Red
        }
    }
}
catch {
    Write-Host "An error occurred."
}
finally {
    Stop-FFmpeg
}