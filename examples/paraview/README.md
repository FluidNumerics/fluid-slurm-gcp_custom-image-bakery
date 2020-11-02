# Fluid-Slurm-GCP Custom Image Bakery : Paraview
This repository contains tools to build custom images on top of Fluid-Slurm-GCP specific to your organizations applications.
This example builds Paraview with GCC-9.2.0 and OpenMPI 4.0.5. The resulting image is called `paraview-gcp` and is posted to your GCP projects VM images.


## Quick Start

### Configure your Fluid-Slurm-GCP Cluster
Fluid Numerics currently offers a publicly available Paraview image that is ready-to-use with the autoscaling [Fluid-Slurm-GCP HPC Cluster](https://console.cloud.google.com/marketplace/details/fluid-cluster-ops/fluid-slurm-gcp). 

#### Controller configuration
After launching your cluster, log in to the controller instance and create a cluster config file.
```
sudo su
cluster-services list all > config.yaml
```
Open the `config.yaml` file in a text editor and edit the partitions block to create a partition for running openfoam. Set the following variables:
* `partitions[0].name = paraview`
* `partitions[0].machines[0].name = paraview`
* `partitions[0].machines[0].disk_size_gb = 50`
* `partitions[0].machines[0].image = projects/fluid-cluster-ops/global/images/paraview-gcp`
* `partitions[0].machines[0].machine_type = n1-standard-16`

Save the changes in `config.yaml`. Note that the `machine_type` you choose depends on your compute requirements. 

Update your cluster's partitions using `cluster-services`. First, preview the changes you are about to make
```
cluster-services update partitions --config=config.yaml --preview
```
Once you are ready to apply the changes, run the same command without the `--preview` flag.
```
cluster-services update partitions --config=config.yaml
```

#### Login configuration
On your cluster's login node, edit `/etc/ssh/ssd_config` so that `GatewayPorts=yes`. After making this change, restart the sshd service
```
sudo service sshd restart
```


### Connect your Paraview Client
On your local system, make sure you have Paraview 5.8.0 installed.

Open Paraview on your local system
```
paraview &
```
Click the `Connect` icon. When the "Choose Server Configuration" appears, click on "Load Servers". Navigate to the `paraview-gcp.pvsc` file (provided in this repository). Once loaded, click "Connect" and fill out the form that appears. Be sure to use the correct ssh username, external login node IP address, server port, and slurm account. Note that you will need to make sure that the `tcp:$SERVER_PORT` is open in your VPC firewall.



## License & Usage
*  [**This Repository**](./LICENSE)
*  [**Packer**](https://github.com/hashicorp/packer/blob/master/LICENSE)
*  [**Paraview**](https://www.paraview.org/paraview-license/)
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


