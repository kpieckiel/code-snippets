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

#		[Parameter(ParameterSetName = 'StandardOptions')]
#		[Parameter(ParameterSetName = 'ExcludeDirs')]
#		[Parameter(ParameterSetName = 'IncludeDirs')]
#		[ValidateSet('AICH', 'BLAKE2b', 'BLAKE2s', 'BTIH', 'CRC32', 'CRC32C',
#			'ED2K', 'EDON-R256', 'EDON-R512', 'GOST12-256', 'GOST12-512', 'GOST94',
#			'GOST94-CRYPTOPRO', 'HAS-160', 'MD4', 'MD5', 'RMD160', 'SHA1',
#			'SHA224', 'SHA256', 'SHA3-224', 'SHA3-256', 'SHA3-384', 'SHA3-512',
#			'SHA384', 'SHA512', 'SNEFRU-128', 'SNEFRU-256', 'TIGER', 'TTH',
#			'WHIRLPOOL')]
#		[string[]]
#		$Algorithm,

	[CmdletBinding(DefaultParameterSetName = 'StandardOptions')]
	Param(
		[Parameter(ParameterSetName = 'ExcludeDirs', Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string[]]
		$ExcludeDirs,

		[Parameter(ParameterSetName = 'IncludeDirs', Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string[]]
		$IncludeDirs,

		[Parameter(ParameterSetName = 'StandardOptions')]
		[Parameter(ParameterSetName = 'ExcludeDirs')]
		[Parameter(ParameterSetName = 'IncludeDirs')]
		[switch]
		$NoSign
	)

    function New-DirList {
        [CmdletBinding(DefaultParameterSetName = 'StandardOptions')]
        Param(
            [Parameter(Mandatory = $true)]
            [ValidateNotNullOrEmpty()]
            [string[]]
            $Directories
        )

        $DirList = New-Object -TypeName System.Collections.Generic.List[string]
        foreach ($dir in $Directories) {
            if (-not (Test-Path -Path $dir -IsValid)) {
                Write-Warning -Message "Invalid syntax '$dir'"
            }
            elseif (Test-Path -Path $dir) {
                if (-not (Test-Path -Path $dir -PathType Container)) {
                    Write-Warning -Message "'$dir' is not a directory"
                }
                else {
                    $temp = Get-Item -Path $dir
                    if ($temp.Parent.FullName -eq $temp.Parent.Root) {
                        $Separator = ''
                    } else {
                        $Separator = '\'
                    }

                    $string = $temp.Parent.FullName+$Separator+$temp.BaseName
                        $DirList.Add($string)
                }
            }
            else {
                Write-Debug -Message "'$dir' does not exist"
            }
        }
        
        return $DirList
    }

	# Resolve all of the directories passed into a consistant specification.
	if ($PSCmdlet.ParameterSetName -eq 'ExcludeDirs') { $ExcludedDirs = New-DirList -Directories $ExcludeDirs }
    if ($PSCmdlet.ParameterSetName -eq 'IncludeDirs') { $IncludedDirs = New-DirList -Directories $IncludeDirs }

    Write-Debug "ExcludedDirs is $ExcludedDirs"
    Write-Debug "IncludedDirs is $IncludedDirs"

	$dirs = Get-ChildItem -Directory
	$hashfiles = [System.Collections.Generic.List[PSCustomObject]]::new()
	foreach ($dir in $dirs)
	{
		# Save the full directory name with the same specification as with the parameters above.
		$dirstring = $dir.Parent.Fullname+'\'+$dir.BaseName
        Write-Debug "dirstring is $dirstring"

		if ((($dirstring -in $ExcludedDirs) -and ($PSCmdlet.ParameterSetName -eq 'ExcludeDirs')) -or
			(($dirstring -notin $IncludedDirs) -and ($PSCmdlet.ParameterSetName -eq 'IncludeDirs')))
		{
			Write-Host -NoNewline 'Skipping '
			Write-Host -ForegroundColor Magenta ($dir.FullName)
			continue
		}
		
		if ((Get-ChildItem -Path $dir.FullName).Count -eq 0) {
			Write-Host -NoNewline 'Skipping '
			Write-Host -NoNewline -ForegroundColor Magenta ($dir.BaseName.ToString())
			Write-Host ' because it''s empty!'
			continue
		}

		$path = Push-Location -PassThru -Path $dir.FullName
		$hashfile = 'hashes.txt'
		$sig = $hashfile + ".sig"
		if (Test-Path -Path $hashfile) { Remove-Item -Path $hashfile }
		if (Test-Path -Path $sig) { Remove-Item -Path $sig }

		Write-Host
		Write-Host -NoNewline -ForegroundColor Green ($path.ToString() + '\')
		Write-Host -NoNewline -ForegroundColor Cyan $hashfile
		Write-Host -ForegroundColor Green ':'
		Write-Host -Separator $null -ForegroundColor Green (@('-') * ($path.ToString().Length + $hashfile.Length + 2))
	
        Write-Debug "rhash goes here"
		& rhash --sha256 --bsd -rPo $hashfile *
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
            Write-Debug "gpg goes here"
			& gpg @('--detach-sign', '--armor', ($file['Path'] + $file['File']))
		}
	}
	else {
		Write-Host
		Write-Host -ForegroundColor White 'Skipping hash signatures at user request.'
	}
}
