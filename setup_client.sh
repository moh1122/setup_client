#!/bin/bash

# Step 1: Ask for the client name
echo "🚀 Welcome to the Client Setup Script!"
read -p "📌 Enter the client name (e.g., Thrive, Nahdi, etc...): " CLIENT_NAME

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

# Step 3: Confirm HOME_URL before proceeding
echo "✅ You entered the following details:"
echo "   - Client Name: $CLIENT_NAME"
echo "   - HOME_URL: $CLIENT_URL"
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
BRANCH_NAME="client-$CLIENT_NAME"

if git show-ref --verify --quiet "refs/heads/$BRANCH_NAME"; then
  echo "🔄 Branch $BRANCH_NAME already exists. Switching to it..."
  git checkout $BRANCH_NAME
else
  echo "🔄 Creating new branch: $BRANCH_NAME"
  git checkout -b $BRANCH_NAME
fi

# Step 6: Update HOME_URL in app/index.tsx
echo "🔄 Updating HOME_URL for $CLIENT_NAME..."

# Make sure the line starts with "const HOME_URL =" and replace the URL correctly
sed -i.bak "s|const HOME_URL = .*|const HOME_URL = '$CLIENT_URL'|" app/index.tsx && rm app/index.tsx.bak

# Verify the change was applied
echo "🔍 Verifying HOME_URL update..."
grep "const HOME_URL" app/index.tsx

# Step 7: Replace matching assets without deleting existing files
echo "📁 Updating assets for $CLIENT_NAME..."
cp -R local_assets/$CLIENT_NAME/* assets/

# Verify copied assets
ls -l assets/

# Step 8: Commit and push changes only if modifications exist
if ! git diff --quiet; then
  echo "📌 Staging changes..."
  git add app/index.tsx assets/
  git commit -m "Updated HOME_URL ($CLIENT_URL) and replaced assets for $CLIENT_NAME"
  git push origin $BRANCH_NAME
  echo "✅ Branch $BRANCH_NAME updated and pushed successfully!"
else
  echo "⚠️ No changes detected. Skipping commit and push."
fi

# Step 9: Ask if the user wants to build the app now
read -p "⚙️ Do you want to build the app now? (y/n): " build_now
if [[ "$build_now" == "y" ]]; then
  echo "📦 Building the app for iOS & Android..."
  npx react-native run-android && npx react-native run-ios
  echo "🎉 Build completed!"
else
  echo "🚀 Setup completed! You can build the app later using:"
  echo "   👉 npx react-native run-android"
  echo "   👉 npx react-native run-ios"
fi
