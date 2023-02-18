function Invoke-HashAndSignFiles {
	<#
	.SYNOPSIS
	Generate hash files and detached signatures for them.

	.DESCRIPTION
	This script iterates through subdirectories (one level deep) of the
	current directory, uses the external rhash program to calculate hash
	files, and then signs the hash files with GPG.

	.PARAMETER ExcludeDirs
	Specifies a string array of subdirectory names to exclude from processing.

	.PARAMETER IncludeDirs
	Specifies a string array of subdirectory names to include in processing.

	.PARAMETER NoSign
	Do not sign the hash files.

	.PARAMETER NoStats
	Do not collect or display file statistics.

	.INPUTS
	This script does not take pipelined inputs.

	.OUTPUTS
	This script does not output any objects.

	.NOTES
	External dependencies:
	* rhash
	* GNU Privacy Guard (GPG)

	.LINK
	https://github.com/rhash/RHash

	.LINK
	https://gnupg.org/

	.LINK
	https://gpg4win.org/
	#>

	[CmdletBinding(DefaultParameterSetName = 'StandardOptions')]
	Param(
		[Parameter(Mandatory = $true, ParameterSetName = 'ExcludeDirs')]
		[ValidateNotNullOrEmpty()]
		[IO.DirectoryInfo[]]
		$ExcludeDirs,

		[Parameter(Mandatory = $true, ParameterSetName = 'IncludeDirs')]
		[ValidateNotNullOrEmpty()]
		[IO.DirectoryInfo[]]
		$IncludeDirs,

		[Parameter(ParameterSetName = 'StandardOptions')]
		[Parameter(ParameterSetName = 'ExcludeDirs')]
		[Parameter(ParameterSetName = 'IncludeDirs')]
		[switch]
		$NoSign,

		[Parameter(ParameterSetName = 'StandardOptions')]
		[Parameter(ParameterSetName = 'ExcludeDirs')]
		[Parameter(ParameterSetName = 'IncludeDirs')]
		[switch]
		$NoStats
	)

	$ExcludedDirs = New-Object -TypeName System.Collections.Generic.List[string]
	foreach ($dir in $ExcludeDirs) {
		if (-not (Test-Path -Path $dir -IsValid)) {
			Write-Warning -Message "Invalid syntax '$dir'"
		}
		elseif (Test-Path -Path $dir) {
			if (-not (Test-Path -Path $dir -PathType Container)) {
				Write-Warning -Message "'$dir' is not a directory"
			}
			else {
				$temp = Get-Item -Path $dir
				$string = $temp.Parent.FullName+"\"+$temp.BaseName
				$ExcludedDirs.Add($string)
			}
		}
		else {
			Write-Debug -Message "'$dir' does not exist"
		}
	}

	$IncludedDirs = New-Object -TypeName System.Collections.Generic.List[string]
	foreach ($dir in $IncludeDirs) {
		if (-not (Test-Path -Path $dir -IsValid)) {
			Write-Warning -Message "Invalid syntax '$dir'"
		}
		elseif (Test-Path -Path $dir) {
			if (-not (Test-Path -Path $dir -PathType Container)) {
				Write-Warning -Message "'$dir' is not a directory"
			}
			else {
				$temp = Get-Item -Path $dir
				$string = $temp.Parent.FullName+"\"+$temp.BaseName
				$IncludedDirs.Add($string)
			}
		}
		else {
			Write-Debug -Message "'$dir' does not exist"
		}
	}

	$dirs = Get-ChildItem -Directory
	$hashfiles = [System.Collections.Generic.List[PSCustomObject]]::new()
	[int]$skipcount = 0
	[int]$signcount = 0
	[int]$filecount = 0
	[int64]$bytecount = 0

	foreach ($dir in $dirs)
	{
		$dirstring = $dir.Parent.Fullname+'\'+$dir.BaseName
		if ((($dirstring -in $ExcludedDirs) -and ($PSCmdlet.ParameterSetName -eq 'ExcludeDirs')) -or
			(($dirstring -notin $IncludedDirs) -and ($PSCmdlet.ParameterSetName -eq 'IncludeDirs')))
		{
			Write-Host -NoNewline 'Skipping '
			Write-Host -ForegroundColor Magenta ($dir.FullName)
			++$skipcount
			continue
		}
		
		if ((Get-ChildItem -Path $dir.FullName).Count -eq 0) {
			Write-Host -NoNewline 'Skipping '
			Write-Host -NoNewline -ForegroundColor Magenta ($dir.BaseName.ToString())
			Write-Host ' because it''s empty!'
			++$skipcount
			continue
		}

		$path = Push-Location -PassThru -Path $dir.FullName
		$hashfile = $dir.BaseName.ToString() + ".sha256"
		$sig = $hashfile + ".sig"
		if (Test-Path -Path $hashfile) { Remove-Item -Path $hashfile }
		if (Test-Path -Path $sig) { Remove-Item -Path $sig }

		Write-Host
		Write-Host -NoNewline -ForegroundColor Green ($path.ToString() + '\')
		Write-Host -NoNewline -ForegroundColor Cyan $hashfile
		Write-Host -ForegroundColor Green ':'
		Write-Host -Separator $null -ForegroundColor Green (@('-') * ($path.ToString().Length + $hashfile.Length + 2))
	
		& rhash --sha256 -rPo $hashfile *
		Write-Host
		[PSCustomObject]$fileobj = @{
			'Path' = $path.ToString() + '\'
			'File' = $hashfile
		}
		$hashfiles.Add($fileobj)
		Pop-Location
	}

	if (-not ($NoSign)) {
		Write-Host
		Write-Host -ForegroundColor Red 'Enter your GPG password if prompted to do so.'
		foreach ($file in $hashfiles)
		{
			Write-Host -NoNewline -ForegroundColor Green 'Signing: '
			Write-Host -ForegroundColor Cyan $file['File']
			& gpg @('--detach-sign', ($file['Path'] + $file['File']))
			++$signcount
		}
	}
	else {
		Write-Host
		Write-Host -ForegroundColor White 'Skipping hash signatures at user request.'
	}

	if (-not ($NoStats)) {
		foreach ($file in $hashfiles)
		{
			foreach ($line in Get-Content -Path ($file['Path'] + $file['File']))
			{
				++$filecount
				$bytecount += (Get-ChildItem -Force -Path ($file['Path'] + $line.Remove(0,66))).Length
			}
		}

		Write-Host
		Write-Host -NoNewline 'Skipped '
		Write-Host -NoNewline -ForegroundColor Cyan ("{0:n0}" -f $skipcount)
		Write-Host ' subdirectories'
		Write-Host -NoNewline 'Visited '
		Write-Host -NoNewline -ForegroundColor Cyan ("{0:n0}" -f $hashfiles.Count)
		Write-Host ' subdirectories'
		Write-Host -NoNewline 'Hashed '
		Write-Host -NoNewline -ForegroundColor Cyan ("{0:n0}" -f $filecount)
		Write-Host ' files'
		Write-Host -NoNewline 'Hashed '
		Write-Host -NoNewline -ForegroundColor Cyan ("{0:n0}" -f $bytecount)
		Write-Host ' bytes'
	}
}
