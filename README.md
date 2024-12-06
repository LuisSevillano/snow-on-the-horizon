 # Using GitHub Actions to get webcams info


This repository is designed to monitor webcams from the Spanish Directorate General of Traffic (DGT) to track the real-time evolution of snowfall across various regions. It uses snow forecasts from AEMET to compare the expected weather conditions with live camera feeds, providing a dynamic and up-to-date visualization of snow-affected areas.

## Features

- Automated Image Capture: Using GitHub Actions, the webcam images are periodically captured and saved.
- Check if the image is new before downloading it.
- Image Upload: The captured images are automatically uploaded to this repository.

## GitHub Actions Workflow
The repository contains GitHub Actions workflows defined in the .github/workflows directory. These workflows handle:

- Fetching images from the webcam at regular intervals.
- Committing and pushing these images to the repository.
