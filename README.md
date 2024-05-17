# ChromeOS Build Script

Script to build generic ChromeOS image for amd64 devices with Google Play Store support.

The generic ChromeOS flex do not support Google Play Store for running Android apps. This script will build a generic ChromeOS image with Google Play Store support for amd64 devices.

The script will download latest stable recovery image from https://cros.tech/ for the given codename and latest brunch (https://github.com/sebanc/brunch) release. It will then extract the recovery image and build a generic ChromeOS image for amd64 devices.

## Inputs

### `codename`

Codename for ChromeOS build. Choose one of the following options based on your processor:

#### Intel Processor

| Processor Generation | Codename |
|---------------------|----------|
| 3rd gen or older    | samus    |
| 4th and 5th gen     | leona    |
| 6th gen to 9th gen  | shyvana  |
| 10th gen            | jinlon   |
| 11th gen and newer  | voxel    |

#### AMD Processor

| Processor | Codename |
|-----------|----------|
| Ryzen     | gumboz   |

## Local Usage

You will need debian based linux distro to run the script. You can use Ubuntu in WSL on Windows.

1. Clone this repository.
   ```shell
   git clone https://github.com/rabilrbl/ChromeOS.git
   ```
2. Switch to the repository directory.
   ```shell
   cd ChromeOS
   ```
3. Give execute permission to the script.
   ```shell
   chmod +x build.sh
   ```
4. Run the script.
   ```shell
    ./build.sh <code_name> # Replace <code_name> with the codename of the ChromeOS build you want to build.
    ```
5. Once the build is complete, the image will be available at `chromeos/chromeos.img`.
6. Use a tool like [Balena Etcher](https://www.balena.io/etcher/) to flash the image to a USB drive.

## GitHub Actions Usage

1. Fork this repository.
2. Goto your GitHub profile and click on the repository you forked.
3. Click on the `Actions` tab.
4. Click on the `Build ChromeOS` workflow.
5. Give the codename of the ChromeOS build you want to build.
6. Click on the `Run workflow` button.
7. Wait for the build to complete.
8. Download the build from the artifacts section of the workflow.

## Credits

- [Techy Druid YouTube Channel](https://www.youtube.com/@TechyDruid) for the tutorial on building ChromeOS image. You can check their tutorial videos.
- [cros.tech](https://cros.tech/) for providing recovery images.
- [brunch](https://github.com/sebanc/brunch) for ChromeOS on x86_64 PC