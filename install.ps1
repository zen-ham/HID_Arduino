# paths and variables
$RepoName = "HID_Arduino"
$DocumentsPath = [Environment]::GetFolderPath("MyDocuments")
$ZipPath = Join-Path $DocumentsPath "temp_install.zip"
$DownloadUrl = "https://raw.githubusercontent.com/zen-ham/$RepoName/master/.zip"

# download file
Invoke-WebRequest -Uri $DownloadUrl -OutFile $ZipPath

# extract the file
tar -xf $ZipPath -C $DocumentsPath

# cleanup
Remove-Item -Path $ZipPath -Force -ErrorAction SilentlyContinue

# open file in arduino ide
$InoFilePath = "$DocumentsPath\Arduino\$RepoName\$RepoName.ino"
Invoke-Item $InoFilePath