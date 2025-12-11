# HLCS-Provisioning

Automated provisioning of Virtual Machines and Containers using Packer & Docker

## Overview

This repository contains automated build configurations for creating virtual machines and containers. Currently, it includes:

- **Ubuntu 22.04 VM**: A minimal Ubuntu 22.04 LTS server virtual machine built with Packer

## Project Structure

```
.
├── ubuntu-22.04.pkr.hcl    # Packer configuration for Ubuntu 22.04 VM
├── http/                    # Cloud-init configuration files
│   ├── user-data           # Autoinstall configuration
│   └── meta-data           # Cloud-init metadata
└── .github/
    └── workflows/
        └── build-vm.yml    # GitHub Actions workflow for building VMs
```

## Ubuntu 22.04 VM

### Features

- **Base OS**: Ubuntu 22.04 LTS Server
- **Format**: OVA (VirtualBox VM)
- **Size**: ~20GB disk space
- **Memory**: 2GB RAM (configurable)
- **CPU**: 2 cores (configurable)
- **Packages**: OpenSSH server, cloud-init

### Default Credentials

⚠️ **Security Note**: Change these credentials after first login!

- **Username**: `ubuntu`
- **Password**: `ubuntu`

### How to Build Locally

#### Prerequisites

- [Packer](https://www.packer.io/downloads) (>= 1.8.0)
- VirtualBox installed on your system
- At least 20GB of free disk space

#### Build Steps

```bash
# Initialize Packer (downloads required plugins)
packer init ubuntu-22.04.pkr.hcl

# Validate the configuration
packer validate ubuntu-22.04.pkr.hcl

# Build the VM
packer build ubuntu-22.04.pkr.hcl
```

The build process will:
1. Download the Ubuntu 22.04 ISO
2. Create a virtual machine
3. Perform automated installation
4. Update all packages
5. Compress the result into `ubuntu-22.04.tar.gz`

### How to Build with GitHub Actions

The easiest way to build the VM is using the automated GitHub Actions workflow:

1. Go to the **Actions** tab in this repository
2. Click on **"Build Ubuntu 22.04 VM"** workflow
3. Click **"Run workflow"** button
4. (Optional) Customize the VM name
5. Click the green **"Run workflow"** button

The workflow will:
- Build the VM automatically
- Create a new release
- Upload the VM as a downloadable artifact

⏱️ The build process takes approximately 20-30 minutes.

### How to Use the Built VM

After downloading the release:

```bash
# Extract the VM
tar -xzf ubuntu-22.04.tar.gz

# Import into VirtualBox
# Double-click the .ova file, or use the command line:
VBoxManage import ubuntu-22.04.ova
```

Or import the OVA file into your preferred virtualization platform:
- **VirtualBox**: File → Import Appliance → Select the .ova file
- **VMware**: File → Open → Select the .ova file
- **Other platforms**: Most virtualization platforms support OVA format

## Learning Resources

All configuration files are heavily commented to help you understand:
- How Packer builds virtual machines
- How cloud-init automates Ubuntu installation
- How GitHub Actions automates the build and release process

Read through the following files to learn more:
- `ubuntu-22.04.pkr.hcl` - Packer configuration with detailed comments
- `http/user-data` - Cloud-init autoinstall configuration
- `.github/workflows/build-vm.yml` - CI/CD pipeline configuration

## Contributing

Feel free to open issues or submit pull requests to improve the automation or add new VM configurations.

## License

This project is open source. Please check the repository for license details.
