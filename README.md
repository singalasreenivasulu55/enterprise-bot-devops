# Enterprise Bot DevOps Take-Home Assignment

## Overview
This project packages a Python HTTP service in Docker and deploys it to Kubernetes using Helm.

## Components
- `service/`: Python application and Dockerfile.
- `chart/`: Helm chart for Kubernetes deployment.
- `setup.sh`: cluster setup and deployment script.
- `kind-config.yaml`: Kind cluster configuration.

## Endpoints
- `/`: returns application name, version, and pod hostname.
- `/healthz`: health check endpoint.

## Validation
Run `helm lint ./chart` to validate the Helm chart.

Run `bash setup.sh` to build the image and deploy the application. The setup script still requires successful end-to-end verification.

## Resource settings
The chart requests 100m CPU and 64Mi memory, with limits of 500m CPU and 128Mi memory. These are starting values for a small demo and should be tuned using observed resource usage.

## Production improvements
Add automated CI tests, image vulnerability scanning, monitoring, secret management, and deployment rollback checks.

## AI usage
AI assistance was used to explain errors and help troubleshoot the Docker, Kubernetes, and Helm configuration. Commands and deployment behavior should be verified before production use.

## Known limitations
The full setup and lab exercise have not yet been completely verified.