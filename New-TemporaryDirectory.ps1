function New-TemporaryDirectory {
    <#
    .SYNOPSIS
    Create and return a new temporary directory.

    .DESCRIPTION
    This function creates temporary directories that you can use in
    scripts.

    The New-TemporaryDirectory function creates an empty directory in
    the user's temporary directory and returns the directory in a
    DirectoryInfo object.
    
    This function uses [System.IO.Path]::GetTempPath() to locate the
    user's temporary directory and [System.IO.Path]::GetRandomFileName()
    to generate a random name.  If the -UseUUID switch is set to $true,
    [System.Guid]::NewGuid() is used instead.

    .EXAMPLE
    New-TemporaryDirectory

    ⁠    Directory: C:\Users\end.user\AppData\Local\Temp

    Mode                 LastWriteTime         Length Name
    ----                 -------------         ------ ----
    d----            4/7/2024  8:14 PM                221a5jms.l4f

    .EXAMPLE
    New-TemporaryDirectory -UseUUID

    ⁠    Directory: C:\Users\end.user\AppData\Local\Temp

    Mode                 LastWriteTime         Length Name
    ----                 -------------         ------ ----
    d----            4/7/2024  8:56 PM                e47239a1-84d8-4718-aacd-18cb45533d47

    .EXAMPLE
    $TempDir = New-TemporaryDirectory
    PS > $TempDir

    ⁠    Directory: C:\Users\end.user\AppData\Local\Temp

    Mode                 LastWriteTime         Length Name
    ----                 -------------         ------ ----
    d----            4/7/2024  9:03 PM                ggfqti44.zkz

    .EXAMPLE
    $TempDir = New-TemporaryDirectory -UseUUID
    PS > $TempDir

    ⁠    Directory: C:\Users\end.user\AppData\Local\Temp

    Mode                 LastWriteTime         Length Name
    ----                 -------------         ------ ----
    d----            4/7/2024  9:05 PM                09d43ea8-bee0-46d9-a04e-8e57484403b9

    .INPUTS
    This script does not accept pipeline input.

    .OUTPUTS
    System.IO.DirectoryInfo
        This function returns the temporary directory that it creates.

    .NOTES
    Function: New-TemporaryDirectory
    Author: Kevin A. Pieckiel
    Based on code by Michael Kropat
    Last updated: April 7, 2024
    Source: https://stackoverflow.com/a/34559554

    .LINK
    https://stackoverflow.com/a/34559554

    .LINK
    [System.IO.Path]::GetTempPath()

    .LINK
    [System.IO.Path]::GetRandomFileName()

    .LINK
    [System.Guid]::NewGuid()
    #>

    [CmdletBinding()]
    param (
        [Parameter()]
        [switch]
        $UseUUID = $False
    )

    $Parent = [System.IO.Path]::GetTempPath()
    [string]$Name = Switch ($UseUUID)
    {
        $false { [System.IO.Path]::GetRandomFileName() }
        $true { [System.Guid]::NewGuid() }
    }

    return New-Item -ItemType Directory -Path (Join-Path $Parent $Name)
}
