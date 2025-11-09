#!/bin/bash

# Get current version
CURRENT_VERSION=$(grep -o 'VERSION = "[^"]*"' lib/rails_health_monitor/version.rb | grep -o '[0-9]\+\.[0-9]\+\.[0-9]\+')

# Increment patch version
IFS='.' read -ra VERSION_PARTS <<< "$CURRENT_VERSION"
MAJOR=${VERSION_PARTS[0]}
MINOR=${VERSION_PARTS[1]}
PATCH=$((VERSION_PARTS[2] + 1))
NEW_VERSION="$MAJOR.$MINOR.$PATCH"

echo "Bumping version from $CURRENT_VERSION to $NEW_VERSION"

# Update version file
sed -i '' "s/VERSION = \"$CURRENT_VERSION\"/VERSION = \"$NEW_VERSION\"/" lib/rails_health_monitor/version.rb

# Update changelog
TODAY=$(date +%Y-%m-%d)
sed -i '' "1,/## \[/s/## \[/## [$NEW_VERSION] - $TODAY\n\n### Changed\n- Version bump\n\n## [/" CHANGELOG.md

# Commit and release
git add .
git commit -m "Bump version to $NEW_VERSION"
bundle exec rake release

echo "Released version $NEW_VERSION"