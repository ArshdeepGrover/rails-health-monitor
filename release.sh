#!/bin/bash

# Get current version
CURRENT_VERSION=$(grep -o 'VERSION = "[^"]*"' lib/rails_health_monitor/version.rb | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')

echo "Current version: $CURRENT_VERSION"
read -p "Enter new version: " NEW_VERSION

if [ -z "$NEW_VERSION" ]; then
  echo "No version entered. Exiting."
  exit 1
fi

echo "Updating version from $CURRENT_VERSION to $NEW_VERSION"

# Update version file
sed -i '' "s/VERSION = \"$CURRENT_VERSION\"/VERSION = \"$NEW_VERSION\"/" lib/rails_health_monitor/version.rb

# Update changelog
TODAY=$(date +%Y-%m-%d)
sed -i '' "1,/## \[/s/## \[/## [$NEW_VERSION] - $TODAY\n\n### Changed\n- Version bump to $NEW_VERSION\n\n## [/" CHANGELOG.md

# Build gem to update Gemfile.lock
bundle exec rake build

# Commit and release
git add .
git commit -m "Bump version to $NEW_VERSION"

bundle exec rake release

echo "Released version $NEW_VERSION"