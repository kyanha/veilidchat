#!/bin/bash

# Fail out if any step has an error
set -e

if [ "$1" == "patch" ]; then
    echo Bumping patch version
    PART=patch
elif [ "$1" == "minor" ]; then
    echo Bumping minor version
    PART=minor
elif [ "$1" == "major" ]; then
    echo Bumping major version
    PART=major
else
    echo Unsupported part! Specify 'patch', 'minor', or 'major'
    exit 1
fi

# Function to increment the build code
increment_buildcode() {
    local current_version=$1
    local major_minor_patch=${current_version%+*}
    local buildcode=${current_version#*+}
    local new_buildcode=$((buildcode + 1))
    echo "${major_minor_patch}+${new_buildcode}"
}

# Function to get the current version from pubspec.yaml
get_current_version() {
    grep -oP '(?<=version: ).*' pubspec.yaml
}

# Function to update the version in pubspec.yaml
update_version() {
    local new_version=$1
    sed -i "s/version: .*/version: ${new_version}/" pubspec.yaml
}

# I pray none of this errors! - I think it should popup an error should that happen..

current_version=$(get_current_version)

echo "Current Version: $current_version"

# Bump the major, minor, or patch version using bump2version
bump2version $PART

# Get the new version after bump2version
new_version=$(get_current_version)

# Preserve the current build code
buildcode=${current_version#*+}
new_version="${new_version%+*}+${buildcode}"

# Increment the build code
final_version=$(increment_buildcode $new_version)

# Update pubspec.yaml with the final version
update_version $final_version

# Print the final version
echo "New Version: $final_version"

#git add pubspec.yaml
#git commit -m "Bump version to $final_version"
#git tag "v$final_version"

