Param(
    [string]$arg
)

$script = "moveto.rb"
$tempfile = "moveto.ps1"
$directory = Split-Path -Path $MyInvocation.MyCommand.Definition -Parent
$path = Join-Path $directory $tempfile

ruby (Join-Path $directory $script) $arg -p > $path
if($LASTEXITCODE -eq 10) {
	& $path
} else {
	Get-Content $path
}
