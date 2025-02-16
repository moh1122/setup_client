# Client Setup Script

This script automates the process of setting up a new client environment by performing the following tasks:

- **Prompt for Client Details:**  
  Requests the client name and a `HOME_URL`, ensuring that valid information is provided.

- **Git Operations:**  
  Checks out the main branch, pulls the latest changes, and then creates (or switches to) a new branch named `client-<client_name>` (with the client name in lowercase).

- **Configuration Updates:**  
  Updates the `HOME_URL` in `app/index.tsx` and modifies the `app.config.js` file to set the correct app `name`, `bundleIdentifier`, and `package`.

- **Assets Replacement:**  
  Copies client-specific assets from a local directory (`local_assets/<client_name>`) into the `assets/` directory without deleting existing files.  
  **Note:** Ensure that a folder matching the client name (in lowercase) exists in the `local_assets` directory and contains the necessary asset files.

- **Committing Changes:**  
  If any changes are detected, the script stages, commits, and pushes them to the newly created branch.

- **Local Builds (Optional):**  
  Offers an option to build the app locally for both Android and iOS using the Expo Application Services (EAS) CLI.  
  **Important:** Local iOS builds require a macOS environment with Xcode installed.

## Prerequisites

- **Git:** Make sure Git is installed and properly configured.
- **EAS CLI:** [EAS CLI](https://docs.expo.dev/build/eas-cli/) should be installed and you must be logged in.
- **Expo Project Setup:** This script is designed for projects using Expo.
- **Assets Directory:** A `local_assets` directory should exist with subdirectories for each client containing the respective assets. For example:
  ```
  local_assets/
    ├── client1/
    │   └── <client-assets>
    └── client2/
        └── <client-assets>
  ```
- **macOS for iOS Builds:** For local iOS builds, a macOS system with Xcode is required.

## Usage

1. **Clone the Repository:**
   ```bash
   git clone <repository-url>
   cd <repository-directory>
   ```

2. **Ensure Assets are in Place:**
   - Verify that the `local_assets` directory contains a subfolder for the client you intend to set up (the subfolder name should be in lowercase and match the client name you will enter).

3. **Make the Script Executable:**
   ```bash
   chmod +x setup-client.sh
   ```

4. **Run the Script:**
   ```bash
   ./setup-client.sh
   ```

5. **Follow the Prompts:**
   - **Client Name:** Enter the name of the client (e.g., Thrive, Nahdi, etc.). The script will convert this to lowercase for consistency.
   - **HOME_URL:** Provide the URL to be used in the app.
   - **Confirmation:** Confirm the details before the script proceeds.
   - **Git Operations & Updates:** The script will then checkout the main branch, create or switch to the appropriate client branch, update configuration files, and copy the assets.
   - **Commit & Push:** If changes are detected, they will be committed and pushed.
   - **Local Builds:** You’ll be asked whether to build the app locally. If you choose "y":
     - The script will run local builds for Android and iOS sequentially, reporting the success or failure of each build.

## Troubleshooting

- **Build Issues:**  
  If a build fails, the script will exit and display an error message. Verify that your local environment meets the requirements (especially for iOS builds on macOS).

- **Asset Copying:**  
  If client-specific assets are not copied as expected, ensure that the `local_assets/<client_name>` folder exists and contains the necessary files.

- **Git Branch Issues:**  
  Ensure you have no uncommitted changes before running the script, as it will switch branches and perform commits.
---
