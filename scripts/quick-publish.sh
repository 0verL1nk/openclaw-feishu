#!/bin/bash
set -e

BLUE='\033[0;34m'
GREEN='\033[0;32m'
NC='\033[0m'

VERSION_TYPE=${1:-patch}

echo -e "${BLUE}快速发布: ${VERSION_TYPE}${NC}"

npm version "$VERSION_TYPE" --no-git-tag-version
NEW_VERSION=$(node -p "require('./package.json').version")

sed -i "s/openclaw-feishu-[0-9]\+\.[0-9]\+\.[0-9]\+/openclaw-feishu-${NEW_VERSION}/g" README.md README_EN.md

git add package.json README.md README_EN.md
git commit -m "chore: bump version to ${NEW_VERSION}"
git push

npm publish --access public

curl -X PUT https://registry.npmmirror.com/@overlink/openclaw-feishu/sync > /dev/null 2>&1

echo -e "${GREEN}✅ 发布完成: v${NEW_VERSION}${NC}"
echo "https://www.npmjs.com/package/@overlink/openclaw-feishu"
