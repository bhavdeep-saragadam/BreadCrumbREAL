#!/bin/bash

# Back up the project file
cp BreadCrumb.xcodeproj/project.pbxproj BreadCrumb.xcodeproj/project.pbxproj.bak

# Extract the Resources Build Phase ID
RESOURCES_PHASE_ID=$(grep -A 3 "Resources.*PBXResourcesBuildPhase" BreadCrumb.xcodeproj/project.pbxproj | head -1 | sed 's/^[ \t]*//' | cut -d ' ' -f 1 | sed 's/"//g')

if [ -z "$RESOURCES_PHASE_ID" ]; then
    echo "Could not find Resources Build Phase ID"
    exit 1
fi

echo "Resources Build Phase ID: $RESOURCES_PHASE_ID"

# Use plutil to extract the file references
INFOPLIST_REF=$(plutil -p BreadCrumb.xcodeproj/project.pbxproj | grep -i "BreadCrumb/Info.plist" | head -1 | cut -d "=" -f 1 | sed 's/^ *"//' | sed 's/"$//')

if [ -z "$INFOPLIST_REF" ]; then
    echo "Could not find Info.plist reference"
    exit 1
fi

echo "Info.plist File Reference: $INFOPLIST_REF"

# Use sed to remove the Info.plist reference from the Resources build phase
sed -i.tmp "/\"$RESOURCES_PHASE_ID\".*PBXResourcesBuildPhase/,/}/ s/\"$INFOPLIST_REF\",//g" BreadCrumb.xcodeproj/project.pbxproj

echo "Updated project.pbxproj file. Original backed up as project.pbxproj.bak" 