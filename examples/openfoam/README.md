# Fluid-Slurm-GCP Custom Image Bakery : OpenFOAM
This repository contains tools to build custom images on top of Fluid-Slurm-GCP specific to your organizations applications.
This example builds OpenFOAM with GCC-9.2.0 and OpenMPI 4.0.5. The resulting image is called `openfoam-gcp-${timestamp}` and is posted to your GCP projects VM images.


## Quick Start
Fluid Numerics currently offers a publicly available OpenFOAM image that is ready-to-use with the autoscaling [Fluid-Slurm-GCP HPC Cluster](https://console.cloud.google.com/marketplace/details/fluid-cluster-ops/fluid-slurm-gcp). To quickly get started with OpenFOAM, set
```
default_compute_image =
```
in your [cluster-configuration file](https://help.fluidnumerics.com/slurm-gcp/documentation/cluster-services) on your fluid-slurm-gcp cluster.

## License & Usage
*  [**This Repository**](./LICENSE)
*  [**OpenFOAM**](https://openfoam.org/licence/)
*  [**Fluid-Slurm-GCP**](https://help.fluidnumerics.com/slurm-gcp/eula) - Use of the fluid-slurm-gcp images during the build of your custom images incur a $0.01 USD/vCPU/hour and $0.09 USD/GPU/hour usage fee on Google Cloud Platform. Additionally, use of custom images built on top of the fluid-slurm-gcp images will continue to incur the same usage fee when deployed on Google Cloud Platform. This usage fee entitles you to support from Fluid Numerics according to the terms and conditions of the [Fluid-Slurm-GCP End User License Agreement](https://help.fluidnumerics.com/slurm-gcp/eula).

## Build the Image yourself
These steps walk you through setting up Google Cloud Build to create custom fluid-slurm-gcp compute node images with Packer.

To get started,
1. Enable the Cloud Build API `gcloud services enable cloudbuild.googleapis.com`
2. Provide the Cloud Build service account the Compute Admin and Service Account User IAM roles.

### Create the OpenFOAM image
Custom GCE VM Images are created using Google Cloud Build with a Packer build step. 

1. Review the [startup-script.sh](./startup-script.sh).
2. Review the [cloudbuild.yaml](./cloudbuild.yaml) to familiarize yourself with the substitution variables.
3. Launch Google Cloud Build.
```
$ gcloud builds submit .
```

## Substituting Custom Images in your Compute Partitions
Once you have created a custom image for OpenFOAM, you can set the image for any `partitions[].machines[].image` in your [cluster-configuration file](https://help.fluidnumerics.com/slurm-gcp/documentation/cluster-services) on your fluid-slurm-gcp cluster.


