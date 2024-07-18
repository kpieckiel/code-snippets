function Format-Size() {
    <#
    .SYNOPSIS
    Convert a number specified in bytes to another unit (e.g., kilobytes, megabytes, etc.).

    .DESCRIPTION
    This function converts a number in bytes to another unit (e.g., kilobytes, megabytes, etc.).
    The resulting unit is automatically determined unless explicitly overridden by the -Unit
    parameter.  Automatic unit detection will choose the largest unit that can represent the
    number as a number less than 1024.
    
    Available units are:
    • Byte (B) (2^0 bytes)
    • Kilobyte (KB) (2^10 bytes)
    • Megabyte (MB) (2^20 bytes)
    • Gigabyte (GB) (2^30 bytes)
    • Terabyte (TB) (2^40 bytes)
    • Petabyte (PB) (2^50 bytes)
    • Exabyte (EB) (2^60 bytes)
    • Zettabyte (ZB) (2^70 bytes)
    • Yottabyte (YB) (2^80 bytes)

    .PARAMETER SizeInBytes
    The number of bytes that is to be converted to another unit.

    .PARAMETER Unit
    The resulting unit of the conversion.  May be 'Auto' to pick the largest unit that can
    represent the number as a number less than 1024.

    .PARAMETER NoGrouping
    Suppress including a grouping character (e.g., comma or period) in the number when output.
    
    .PARAMETER Precision
    The number of digits to display after the decimal point.

    .PARAMETER MaxPrecision
    The maximum number of digits to display after the decimal point.  Fewer than this number of
    digits may be displayed if full precision is reached.

    .INPUTS
    System.Numerics.BigInteger.  This function accepts an unsigned integer that is to be conversion.

    .OUTPUTS
    System.String.  This function returns the input number converted to the specified unit
    with a unit identifier.
    
    .NOTES
    This function is an adaptation of the Format-Size() function provided by Theo in a Stack
    Overflow post.  See related link.

    .LINK
    https://stackoverflow.com/a/57535522
    #>

    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true)]
        [decimal]
        $SizeInBytes,
        
        [Parameter()]
        [ValidateSet('Auto', 'B', 'KB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB')]
        [string]
        $Unit = 'Auto',
        
        [Parameter()]
        [switch]
        $NoGrouping = $false,
        
        [Parameter(ParameterSetName = 'Precision')]
        [Byte]
        $Precision = 2,

        [Parameter(Mandatory = $true, ParameterSetName = 'MaxPrecision')]
        [Byte]
        $MaxPrecision
    )
    
    Write-Debug "Bound parameters: $($PSBoundParameters.Keys)"
    
    $Grouping = $NoGrouping ? '0' : '#,0'
    $PrecisionMarker = $PSBoundParameters.ContainsKey('MaxPrecision') ? '#' : '0'
    $Decimals = $PSBoundParameters.ContainsKey('MaxPrecision') ? $MaxPrecision : $Precision
    $Zeroes = $Precision -eq 0 ? '' : '.' + $PrecisionMarker * $Decimals
    $Format = "{0:$Grouping$Zeroes}"
    
    Write-Debug "Precision marker is $PrecisionMarker"
    Write-Debug "Format is $Format"
    Write-Debug "SizeInBytes is $SizeInBytes"
    Write-Debug "SizeInBytes is $(""{0:#,#}"" -f $SizeInBytes)"

    Set-Variable EB -Option ReadOnly -Value ([decimal]1PB * [decimal]1KB)
    Set-Variable ZB -Option ReadOnly -Value ([decimal]1PB * [decimal]1MB)
    Set-Variable YB -Option ReadOnly -Value ([decimal]1PB * [decimal]1GB)
        
    switch ($Unit) {
        {$_ -eq 'Auto' -and $SizeInBytes -ge $YB -or $_ -eq 'YB'} {Write-Output $("$Format YB" -f [math]::Round([decimal]::Divide($SizeInBytes, $YB), $Decimals, [System.MidpointRounding]::ToZero)); break}
        {$_ -eq 'Auto' -and $SizeInBytes -ge $ZB -or $_ -eq 'ZB'} {Write-Output $("$Format ZB" -f [math]::Round([decimal]::Divide($SizeInBytes, $ZB), $Decimals, [System.MidpointRounding]::ToZero)); break}
        {$_ -eq 'Auto' -and $SizeInBytes -ge $EB -or $_ -eq 'EB'} {Write-Output $("$Format EB" -f [math]::Round([decimal]::Divide($SizeInBytes, $EB), $Decimals, [System.MidpointRounding]::ToZero)); break}
        {$_ -eq 'Auto' -and $SizeInBytes -ge 1PB -or $_ -eq 'PB'} {Write-Output $("$Format PB" -f [math]::Round([decimal]::Divide($SizeInBytes, 1PB), $Decimals, [System.MidpointRounding]::ToZero)); break}
        {$_ -eq 'Auto' -and $SizeInBytes -ge 1TB -or $_ -eq 'TB'} {Write-Output $("$Format TB" -f [math]::Round([decimal]::Divide($SizeInBytes, 1TB), $Decimals, [System.MidpointRounding]::ToZero)); break}
        {$_ -eq 'Auto' -and $SizeInBytes -ge 1GB -or $_ -eq 'GB'} {Write-Output $("$Format GB" -f [math]::Round([decimal]::Divide($SizeInBytes, 1GB), $Decimals, [System.MidpointRounding]::ToZero)); break}
        {$_ -eq 'Auto' -and $SizeInBytes -ge 1MB -or $_ -eq 'MB'} {Write-Output $("$Format MB" -f [math]::Round([decimal]::Divide($SizeInBytes, 1MB), $Decimals, [System.MidpointRounding]::ToZero)); break}
        {$_ -eq 'Auto' -and $SizeInBytes -ge 1KB -or $_ -eq 'KB'} {Write-Output $("$Format KB" -f [math]::Round([decimal]::Divide($SizeInBytes, 1KB), $Decimals, [System.MidpointRounding]::ToZero)); break}
        default {Write-Output $("$Format B" -f [math]::Round($SizeInBytes, $Decimals, [System.MidpointRounding]::ToZero))}
    }
}
