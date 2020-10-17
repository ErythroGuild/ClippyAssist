# Remove old packages
Remove-Item "ClippyAssist-v*.zip"
Remove-Item "ClippyAssist-v*.7z"

# Fetch version number
$VERSION = "X.X"
foreach ($line in Get-Content "ClippyAssist/ClippyAssist.toc") {
	if ($line -match "^## Version: (\d+\.\d+\.\d+)") {
		$VERSION = $Matches[1]
		break
	}
}

# Trim patch number
if ($VERSION -match "(\d+\.\d+)\.0") {
	$VERSION = $Matches[1]
}

# Copy license file into package
Copy-Item "License.md" -Destination "ClippyAssist/License.md"

# Copy acknowledgements into package
Copy-Item "Acknowledgements.md" -Destination "ClippyAssist/Acknowledgements.md"

# Create new packages
$PATH_7Z = "C:/Program Files/7-Zip"
&"$PATH_7Z/7z.exe" a -tzip -mmt -mx9 -r "ClippyAssist-v$VERSION.zip" "ClippyAssist/"
&"$PATH_7Z/7z.exe" a -t7z -mmt -mx9 -r "ClippyAssist-v$VERSION.7z" "ClippyAssist/"

# Cleanup license file
Remove-Item "ClippyAssist/License.md"

# Cleanup acknowledgements file
Remove-Item "ClippyAssist/Acknowledgements.md"
