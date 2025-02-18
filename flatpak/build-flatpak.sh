#!/bin/bash


# Convert the archive of the Flutter app to a Flatpak.


# Exit if any command fails
set -e

# Echo all commands for debug purposes
set -x


# No spaces in project name.
projectName=VeilidChat
projectId=com.veilid.veilidchat
executableName=veilidchat


# ------------------------------- Build Flatpak ----------------------------- #

# Copy the portable app to the Flatpak-based location.
cp -r bundle/ /app/$projectName
chmod +x /app/$projectName/$executableName
mkdir -p /app/bin
ln -s /app/$projectName/$executableName /app/bin/$executableName

# Install the icon.
iconDir=/app/share/icons/hicolor/256x256/apps
mkdir -p $iconDir
cp $projectId.png $iconDir/$projectId.png

# Install the desktop file.
desktopFileDir=/app/share/applications
mkdir -p $desktopFileDir
cp -r $projectId.desktop $desktopFileDir/

# Install the AppStream metadata file.
metadataDir=/app/share/metainfo
mkdir -p $metadataDir
cp -r $projectId.metainfo.xml $metadataDir/
