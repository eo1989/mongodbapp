#!/usr/bin/env bash

# =========================== DOWNLOAD ==================================

# Get latest Production Relase version number
echo "--> Getting Production Release version number"
VERSION=$(curl -s https://www.mongodb.org/downloads | grep -o 'Current Stable Release (.*)' | grep -o '[0-9]*\.[0-9]*\.[0-9]*')
echo "--> Production Release: $VERSION"

# Create download url
DOWNLOAD_URL="http://downloads.mongodb.org/osx/mongodb-osx-ssl-x86_64-$VERSION.tgz"

# Download latest mongodb for mac
echo "--> Downloading: $DOWNLOAD_URL"
curl -o /tmp/mongodb.tgz $DOWNLOAD_URL

# Clean old mongodb dir
echo "--> Cleaning directory $(pwd)/Vendor/mongodb"
rm -rf $(pwd)/Vendor/mongodb

# Create dir
echo "--> Creating directory $(pwd)/Vendor/mongodb"
mkdir -p $(pwd)/Vendor/mongodb

# Extract
echo "--> Unzipping..."
tar xvzf /tmp/mongodb.tgz -C /tmp

# move files
echo "--> Moving files to $(pwd)/Vendor/mongodb/"
mv /tmp/mongodb-osx-x86_64-*/* Vendor/mongodb

# cleanup
echo "--> Removing /tmp/mongodb.tgz"
rm /tmp/mongodb.tgz

echo "--> Removing /tmp/mongodb-osx-x86_64-*"
rm -r /tmp/mongodb-osx-x86_64-*

echo "--> Download completed!"


# =========================== PUBLISH ==================================
BUILD_VERSION="${VERSION}-build.$(date +%s)"

echo "--> Update Info.plist version ${BUILD_VERSION}"
/usr/libexec/PlistBuddy -c "Set :CFBundleVersion ${BUILD_VERSION}" MongoDB/Info.plist
/usr/libexec/PlistBuddy -c "Set :CFBundleShortVersionString ${BUILD_VERSION}" MongoDB/Info.plist

echo "--> Clean build folder"
rm -rf build/

echo "--> Build with defaults"
xcodebuild

echo "--> Zip"
cd build/Release
zip -r -y ~/Desktop/MongoDB.zip MongoDB.app
cd ../../

# Get zip file size
FILE_SIZE=$(du ~/Desktop/MongoDB.zip | cut -f1)

# Get date
DATE_TIME=$(date +"%a, %d %b %G %H:%M:%S %z")

echo "--> Creting a git commit and tag"
git commit -am $BUILD_VERSION
git tag $BUILD_VERSION

echo "--> Echo Appcast item"
echo "============================="
echo "
<item>
  <title>${BUILD_VERSION}</title>
  <description>
    <![CDATA[
      <h2>${BUILD_VERSION}</h2>
      <ul>
        <li>Updates mongodb to ${VERSION}</li>
      </ul>
    ]]>
  </description>
  <pubDate>$DATE_TIME</pubDate>
  <enclosure url=\"https://github.com/gcollazo/mongodbapp/releases/download/$BUILD_VERSION/MongoDB.zip\" sparkle:version=\"$BUILD_VERSION\" length=\"$FILE_SIZE\" type=\"application/octet-stream\"/>
  <sparkle:minimumSystemVersion>10.10</sparkle:minimumSystemVersion>
</item>
"
echo "============================="

echo "--> Done"
echo ""


echo "Next steps:"
echo ""
echo "git push origin --tags"
echo ""
echo "Upload the zip file to GitHub"
echo "https://github.com/gcollazo/mongodbapp/releases/tag/$BUILD_VERSION"
echo ""
echo "Update Appcast file."
echo ""
echo ""
