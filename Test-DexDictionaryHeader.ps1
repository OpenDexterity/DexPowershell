function Test-DexDictionaryHeader {
    #region Help
    <#
        .SYNOPSIS
        Checks to see if a file is a Dexterity dictionary.
        .DESCRIPTION
        Checks a file's header to see if it is a Dexterity dictionary.
        .EXAMPLE
        Test-DexDictionaryHeader "C:\Path\To\Dictionary.dic"
        .INPUTS
        Path to a Dexterity dictionary (.dic) or chunk dictionary (.cnk)
        .OUTPUTS
        Boolean
        .NOTES
        Created by Sean Cale, September 2021
    #>
    #endregion

    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true, ValueFromPipeline=$true)]
        [ValidateScript({
            #checking if it's a file
            if (-not (Test-Path -Path $_ -PathType Leaf)) {
                #not a file = error
                throw "The specified path does not exist or is not a file."
            }

            #checking for dic or cnk extension
            $ext = [System.IO.Path]::GetExtension($_)
            if (($ext -eq ".dic") -or ($ext -eq ".cnk")) {
                return $true
            } else {
                throw "Specified file does not have .dic or .cnk extension."
            }
        })]
        [string]$Path
    )

    BEGIN {
        #initialize stream reader
        try {
            $reader = New-Object -TypeName System.IO.FileStream -ArgumentList $Path,Open
        } catch {
            #forcing the script to exit if it can't open the file
            throw
            break
        }
    }

    PROCESS {
        #read the first 4 bytes, which is the signature
        #always expected to be 25 56 54 4c in hex
        [byte[]]$buffer = [byte[]]::new(4)
        $reader.Read($buffer, 0, 4) | Out-Null #read 4 chars from beginning of file into $buffer

        #now compare with what it's supposed to be
        [byte[]]$dicHeader = @(0x25, 0x56, 0x54, 0x4c)
        for ($i = 0; $i -lt 4; $i++) {
            if ($buffer[$i] -ne $dicHeader[$i]) {
                #if there's a mismatch
                return $false
            }
        }

        #if code reaches this point, the check passed
        return $true
    }

    END {
        #close file + misc cleanup
        $reader.Close()
        $reader.Dispose()
    }
}