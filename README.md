# Fluid-Slurm-GCP Custom Image Bakery
This repository contains tools to build custom images on top of Fluid-Slurm-GCP specific to your organizations applications.

## Getting started
These steps walk you through setting up Google Cloud Build to create custom fluid-slurm-gcp compute node images with Packer.

To get started,
1. Enable the Cloud Build API `gcloud services enable cloudbuild.googleapis.com`
2. Provide the Cloud Build service account the Compute Admin IAM Role.
3. (Optional) Create your own packer build step from the [community-cloud-builders repository](https://github.com/GoogleCloudPlatform/cloud-builders-community/tree/master/packer)

### Create the Packer Cloud Build builder
Before creating your own images, you first need to create a Docker image in your Google Container Registry that contains the Packer CLI.
1. `cd packer`
2. `gcloud builds submit .`


### Create your custom images
Custom GCE VM Images are created using Google Cloud Build with a Packer build step. 

1. Edit the [startup-script.sh](./startup-script.sh) to include the steps necessary to install your package.
2. Review the [cloudbuild.yaml](./cloudbuild.yaml) to familiarize yourself with the substitution variables.
3. Launch Google Cloud Build with the necessary substitutions. For example, the command below will build your image on a 30 GB disk using the Ubuntu fluid-slurm-gcp image as a starting point. The image family will be marked as "my-app" and the specific image that is created will be "my-app-$timestamp" where "$timestamp" will be replaced with the timestamp for when the image is created.
```
$ gcloud builds submit . --substitutions=_DISK_SIZE_GB=30,_FLUID_BASE="ubuntu",_IMAGE_NAME="my-app"
```

Note that you can make a fork of this repository and [set up build triggers](https://cloud.google.com/cloud-build/docs/automating-builds/create-manage-triggers) to automate builds of your custom images.


## Substituting Custom Images in your Compute Partitions
Once you have created a custom image for your application, you can set the image for any `partitions[].machines[].image` in your [cluster-configuration file](https://help.fluidnumerics.com/slurm-gcp/documentation/cluster-services) on your fluid-slurm-gcp cluster.

### Example
Suppose you created an image with `_IMAGE_NAME=MY-APP` in a GCP project with the project ID `MY-GCP-PROJECT-ID`.

On your cluster's controller instances, 
1. Go root `$ sudo su`
2. Create a config file `$ cluster-services list all > config.yaml`
3. Find the partitions.machines block you want to use to deploy your image. Set the image field within this block to `projects/MY-GCP-PROJECT-ID/global/images/family/MY-APP`
4. Preview the partition update `$ cluster-services update partitions --config=config.yaml --preview`
5. Apply the partition update `$ cluster-services update partitions --config=config.yaml`

## License
### [This Repository](./LICENSE)

### Fluid-Slurm-GCP Images
Use of the `projects/fluid-cluster-ops/global/images/fluid-slurm-gcp-*` images used in the build of your custom images incur a $0.01 USD/vCPU/hour and $0.09 USD/GPU/hour usage fee on Google Cloud Platform. Additionally, use of custom images built on top of the fluid-slurm-gcp images will continue to incur the same usage fee. This usage fee entitles you to support from Fluid Numerics according to the terms and conditions of the [Fluid-Slurm-GCP End User License Agreement](https://help.fluidnumerics.com/slurm-gcp/eula).
