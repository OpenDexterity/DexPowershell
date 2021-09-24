function Get-DexDictionaryBlockTable {
    #region Help
    <#
        .SYNOPSIS
        Reads a Dexterity dictionary's block table.
        .DESCRIPTION
        Reads the block table from a Dexterity dictionary.
        .EXAMPLE
        Get-DexDictionaryBlockTable "C:\Path\To\Dictionary.dic"
        .INPUTS
        Path to a Dexterity dictionary (.dic) or chunk dictionary (.cnk)
        .OUTPUTS
        PSCustomObject[]
        .NOTES
        Created by Sean Cale, September 2021
    #>
    #endregion

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true,ValueFromPipeline=$true)]
        [ValidateScript({
            Test-DexDictionaryHeader -Path $_
            return $true
        })]
        [string]$Path
    )

    BEGIN {
        #intializing reader
        try {
            $file = [System.IO.File]::Open($Path, [System.IO.FileMode]::Open)
            $reader = New-Object -TypeName System.IO.BinaryReader -ArgumentList $file
        } catch {
            #forcing the script to exit if it can't open the file
            throw
            break
        }

        #vars
        [UInt32]$tblOffset = 0
        [UInt32]$tblSize = 0
        $stopwatch = New-Object -TypeName System.Diagnostics.Stopwatch
    }

    PROCESS {
        #getting the offset and size
        $reader.BaseStream.Seek(0xe, [System.IO.SeekOrigin]::Begin) | Out-Null #block table offset is at offset 0xe in the file
        $tblOffset = $reader.ReadUInt32() #this method seeks automatically
        $tblSize = $reader.ReadUInt32()

        #verbosity
        Write-Verbose "Block table is at offset $tblOffset and contains $tblSize records."

        #going to that offset
        $reader.BaseStream.Seek($tblOffset, [System.IO.SeekOrigin]::Begin) | Out-Null

        $stopwatch.Start()
        #reading the records
        $tblSizeBytes = $tblSize * 0xe #block table records are 0xe bytes in size
        [UInt32]$blkNum = 1
        [PSCustomObject[]]$records = for ($i = 0; $i -lt ($tblSizeBytes); $i += 0xe) {
            #directly putting the results of the loop into $records takes about 790 ticks (0.079 ms) per record
            #using a .net collection and the .Add() function takes about 1650 ticks (0.165 ms) per record
            #using a powershell array and the += operator takes about 2130 ticks (0.213 ms) per record
            [PSCustomObject]@{
                BlockNumber = $blkNum
                BlockType = $reader.ReadUInt16()
                StartOffset = $reader.ReadUInt32()
                Size = $reader.ReadUInt32()
                UnusedSpace = $reader.ReadUInt32()
            }
            $blkNum++
        }

        $stopwatch.Stop()
    }

    END {
        $reader.Close()
        $reader.Dispose()

        #verbose only
        Write-Verbose "Done. Processed $tblSize records in $($stopwatch.ElapsedTicks) ticks, or $($stopwatch.ElapsedMilliseconds) ms."
        Write-Verbose "$($stopwatch.ElapsedTicks / $tblSize) ticks per record, $($stopwatch.ElapsedMilliseconds / $tblSize) ms per record."

        return $records
    }
}