# Build ChromeOS

GitHub Actions workflow to build generic ChromeOS image for amd64 devices with Google Play Store support.

The generic ChromeOS flex do not support Google Play Store for running Android apps. This script will build a generic ChromeOS image with Google Play Store support for amd64 devices.

The script will download latest stable recovery image from https://cros.tech/ for the given codename and latest brunch (https://github.com/sebanc/brunch) release. It will then extract the recovery image and build a generic ChromeOS image for amd64 devices.

## Inputs

### `codename`

Codename for ChromeOS build. Choose one of the following options based on your processor:

- Intel Processor:
    - 3rd gen or older: samus
    - 4th and 5th gen: leona
    - 6th gen to 9th gen: shyvana
    - 10th gen: jinlon
    - 11th gen and newer: voxel

- AMD Processor:
    - Ryzen: gumboz

## Usage

1. Fork this repository.
2. Goto your GitHub profile and click on the repository you forked.
3. Click on the `Actions` tab.
4. Click on the `Build ChromeOS` workflow.
5. Give the codename of the ChromeOS build you want to build.
6. Click on the `Run workflow` button.
7. Wait for the build to complete.
8. Download the build from the artifacts section of the workflow.
