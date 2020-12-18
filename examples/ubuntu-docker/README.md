# Fluid-Slurm-GCP Custom Image Bakery : Ubuntu + Docker
This repository contains tools to build custom images on top of Fluid-Slurm-GCP specific to your organizations applications.
This example installs docker on top of the `fluid-slurm-gcp-compute-ubuntu-v2-5-0` image.

## Quick Start
In your GCP project, create this image with Google Cloud Build
```
gcloud builds submit . --async
```
This will create an image called `fluid-slurm-gcp-compute-ubuntu-docker`.
After launching your cluster, log in to the controller instance and create a cluster config file.
```
sudo su
cluster-services list all > config.yaml
```
Open the `config.yaml` file in a text editor and edit the partitions block to create a partition for running openfoam. Set the following variables:
* `partitions[0].name = docker`
* `partitions[0].machines[0].name = docker`
* `partitions[0].machines[0].disk_size_gb = 50`
* `partitions[0].machines[0].image = projects/PROJECT-ID/global/images/fluid-slurm-gcp-compute-ubuntu-docker`

Be sure to replace `PROJECT-ID` with your GCP project ID. Save the changes in `config.yaml`. 

Update your cluster's partitions using `cluster-services`. *Make sure you are on your cluster's controller instance* 
First, preview the changes you are about to make
```
cluster-services update partitions --config=config.yaml --preview
```
Once you are ready to apply the changes, run the same command without the `--preview` flag.
```
cluster-services update partitions --config=config.yaml
```

## License & Usage
*  [**This Repository**](./LICENSE)
*  [**Packer**](https://github.com/hashicorp/packer/blob/master/LICENSE)
*  [**Fluid-Slurm-GCP**](https://help.fluidnumerics.com/slurm-gcp/eula) - Use of the fluid-slurm-gcp images during the build of your custom images incur a $0.01 USD/vCPU/hour and $0.09 USD/GPU/hour usage fee on Google Cloud Platform. Additionally, use of custom images built on top of the fluid-slurm-gcp images will continue to incur the same usage fee when deployed on Google Cloud Platform. This usage fee entitles you to support from Fluid Numerics according to the terms and conditions of the [Fluid-Slurm-GCP End User License Agreement](https://help.fluidnumerics.com/slurm-gcp/eula).

