# PowerShell Script for Mass Video Encoding

Script automates the process of converting large amount of video files to a HEVC using FFmpeg. It takes two parameters: the input folder where the source MP4 files are located, and the output folder where the converted files will be saved.

## Usage

To use this script, navigate to the folder containing the script and execute it from the PowerShell command line, providing the paths to the input and output folders:

```powershell
.\massencode.ps1 '\path\to\input\folder' '\path\to\output\folder'
```

> [!WARNING]  
> `After output file encoding is finished, source file will be deleted!`

### Possible Execution Policy Errors

If there is PowerShell Execution Policy error, you can set different execution policy for current PowerShell Session:
```powershell
Set-ExecutionPolicy -Scope Process -ExecutionPolicy Unrestricted
```
Or for current user overall (unsafe):
```powershell
Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy Unrestricted
```

## How it works

#### FFmpeg arguments can be found on line 55.

- If the specified output folder does not exist, the script will create it.
- Script will attempt to locate `ffmpeg.exe` within the same directory as the script itself. If it fails, it will try to locate `ffmpeg` in system's PATH.
- Script will look for all `.mp4` files in directory and put them in queue.
    - For each file, script invokes FFmpeg with certain arguments.
    - Upon successful conversion, the script will check for the presence of the converted file in the output folder, and the original file will be deleted from the input folder.
- Control-C can be used to stop the script and the ffmpeg process from executing. It will stop the conversion process and will not remove the file currently being processed.

## TODO
#### 1. Make standard parameters into named arguments:

Currently:
```powershell
.\massencode.ps1 '\path\to\input\folder' '\path\to\output\folder'
```
Should become:
```powershell
.\massencode.ps1 -i '\path\to\input\folder' -o '\path\to\output\folder'
```
#### 2. Add possibility to change default FFmpeg arguments by passing other arguments to the script.
For example:
```powershell
.\massencode.ps1 -i '\path\to\input\folder' --quality 10 --fps 60 --audio [pass/merge] --keep -o '\path\to\output\folder'
```

## Why?

The script was created for educational purposes for one particular scenario.
