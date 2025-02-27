#!/bin/bash

# Step 1: Ask for the client name
echo "🚀 Welcome to the Client Setup Script!"
read -p "📌 Enter the client name (e.g., Thrive, Nahdi, etc...): " CLIENT_NAME

# Convert client name to lowercase for consistency
CLIENT_NAME_LOWER=$(echo "$CLIENT_NAME" | tr '[:upper:]' '[:lower:]')

# Validate client name
if [ -z "$CLIENT_NAME" ]; then
  echo "❌ Client name cannot be empty. Please enter a valid client name."
  exit 1
fi

# Step 2: Ask for the HOME_URL
read -p "🔗 Enter the HOME_URL for $CLIENT_NAME: " CLIENT_URL

# Validate HOME_URL
if [ -z "$CLIENT_URL" ]; then
  echo "❌ HOME_URL cannot be empty. Please enter a valid URL."
  exit 1
fi

# Step 2.5: Ask for the bundle identifier
read -p "🔑 Enter the bundle identifier for $CLIENT_NAME (e.g., com.example.app): " BUNDLE_IDENTIFIER

# Validate bundle identifier
if [ -z "$BUNDLE_IDENTIFIER" ]; then
  echo "❌ Bundle identifier cannot be empty. Please enter a valid identifier."
  exit 1
fi

# Step 3: Confirm details before proceeding
echo "✅ You entered the following details:"
echo "   - Client Name: $CLIENT_NAME"
echo "   - HOME_URL: $CLIENT_URL"
echo "   - Bundle Identifier: $BUNDLE_IDENTIFIER"
read -p "⚠️ Are these details correct? (y/n): " confirm

if [[ "$confirm" != "y" ]]; then
  echo "❌ Setup canceled. Please re-run the script and enter the correct details."
  exit 1
fi

echo "🔄 Proceeding with client setup for $CLIENT_NAME..."

# Step 4: Checkout the main branch and pull latest changes
git checkout main
git pull origin main

# Step 5: Create or switch to the client branch
BRANCH_NAME="client-$CLIENT_NAME_LOWER"

if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
  echo "🔄 Branch $BRANCH_NAME already exists. Switching to it..."
  git checkout $BRANCH_NAME
else
  echo "🔄 Creating new branch: $BRANCH_NAME"
  git checkout -b $BRANCH_NAME
fi

# Step 6: Update HOME_URL in app/index.tsx
echo "🔄 Updating HOME_URL for $CLIENT_NAME..."
sed -i.bak "s|const HOME_URL = .*|const HOME_URL = '$CLIENT_URL'|" app/index.tsx && rm app/index.tsx.bak

# Verify the change was applied
echo "🔍 Verifying HOME_URL update..."
grep "const HOME_URL" app/index.tsx

# Step 7: Modify app.config.js (Change name, bundleIdentifier, package)
echo "🔄 Updating app.config.js for $CLIENT_NAME..."
sed -i.bak -E "s|name: '.*'|name: '$CLIENT_NAME'|" app.config.js
sed -i.bak -E "s|bundleIdentifier: '.*'|bundleIdentifier: '$BUNDLE_IDENTIFIER'|" app.config.js
sed -i.bak -E "s|package: '.*'|package: '$BUNDLE_IDENTIFIER'|" app.config.js
rm app.config.js.bak

# Verify the change was applied
echo "🔍 Verifying app.config.js update..."
grep "name:" app.config.js
grep "bundleIdentifier:" app.config.js
grep "package:" app.config.js

# Step 8: Replace matching assets without deleting existing files
echo "📁 Updating assets for $CLIENT_NAME..."
cp -R local_assets/$CLIENT_NAME/* assets/

# Verify copied assets
ls -l assets/

# Execute expo prebuild command
echo "🚀 Running npx expo prebuild..."
npx expo prebuild

# Step 9: Commit and push changes only if modifications exist
if ! git diff --quiet; then
  echo "📌 Staging changes..."
  git add app/index.tsx app.config.js assets/
  git commit -m "Updated HOME_URL ($CLIENT_URL), app.config.js (bundleIdentifier: $BUNDLE_IDENTIFIER), and replaced assets for $CLIENT_NAME"
  git push origin $BRANCH_NAME
  echo "✅ Branch $BRANCH_NAME updated and pushed successfully!"
else
  echo "⚠️ No changes detected. Skipping commit and push."
fi

# Step 10: Ask if the user wants to build the app now
read -p "⚙️ Do you want to build the app now? (y/n): " build_now
if [[ "$build_now" == "y" ]]; then
  echo "📦 Building Android app locally..."
  if eas build --platform android --local; then
    echo "✅ Android build completed."
  else
    echo "❌ Android build failed."
    exit 1
  fi

  echo "📦 Building iOS app locally..."
  if eas build --platform ios --local; then
    echo "✅ iOS build completed."
  else
    echo "❌ iOS build failed."
    exit 1
  fi
fi
