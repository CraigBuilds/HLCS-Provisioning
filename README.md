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
- **Format**: VDI (VirtualBox disk image)
- **Size**: ~30GB disk space
- **Memory**: 2GB RAM (configurable)
- **CPU**: 2 cores (configurable)
- **Packages**: OpenSSH server, cloud-init

### Build Method

The VM is built using **QEMU** in CI (GitHub Actions) and then converted to VirtualBox-compatible VDI format. This approach:
- Works reliably on GitHub-hosted runners
- Doesn't require nested virtualization
- Produces VirtualBox-compatible disk images
- Avoids VirtualBox ARM/x86 compatibility issues
- Uses Ubuntu Server (not Desktop) for faster installation in software emulation

### Default Credentials

⚠️ **Security Note**: Change these credentials after first login!

- **Username**: `ubuntu`
- **Password**: `ubuntu`

### How to Build Locally

#### Prerequisites

- [Packer](https://www.packer.io/downloads) (>= 1.8.0)
- Either VirtualBox OR QEMU installed on your system
- At least 30GB of free disk space

#### Build Steps

```bash
# Initialize Packer (downloads required plugins)
packer init ubuntu-22.04.pkr.hcl

# Validate the configuration
packer validate ubuntu-22.04.pkr.hcl

# Build the VM
# The template is configured to use QEMU by default (for CI compatibility)
# To use VirtualBox instead, edit ubuntu-22.04.pkr.hcl and change:
#   sources = ["source.qemu.ubuntu"]
# to:
#   sources = ["source.virtualbox-iso.ubuntu"]
packer build ubuntu-22.04.pkr.hcl
```

The build process will:
1. Download the Ubuntu 22.04 ISO
2. Create a virtual machine using QEMU (or VirtualBox if configured)
3. Perform automated installation
4. Update all packages
5. Output a disk image in `output-ubuntu-22.04/`

Note: If building with QEMU locally, you can convert the output to VDI with:
```bash
qemu-img convert -O vdi output-ubuntu-22.04/ubuntu-22.04 ubuntu-22.04.vdi
```

### How to Build with GitHub Actions

The easiest way to build the VM is using the automated GitHub Actions workflow:

1. Go to the **Actions** tab in this repository
2. Click on **"Build Ubuntu 22.04 VM"** workflow
3. Click **"Run workflow"** button
4. Click the green **"Run workflow"** button

The workflow will:
- Build the VM automatically using QEMU on `ubuntu-latest` runners
- Convert the disk image to VirtualBox-compatible VDI format
- Create a new release
- Upload the VM as a downloadable artifact

⏱️ The build process takes approximately 30-45 minutes (QEMU software emulation is slower than hardware virtualization).

### How to Use the Built VM

After downloading the release:

```bash
# Extract the VM
tar -xzf ubuntu-22.04.tar.gz

# You'll get a ubuntu-22.04.vdi file
```

**To import into VirtualBox:**

1. Open VirtualBox
2. Click **"New"** to create a new virtual machine
3. Name: Ubuntu 22.04 (or any name you prefer)
4. Type: Linux
5. Version: Ubuntu (64-bit)
6. Click **"Next"**
7. When prompted for a hard disk, select **"Use an existing virtual hard disk file"**
8. Click the folder icon and browse to select `ubuntu-22.04.vdi`
9. Click **"Create"**
10. Adjust settings if needed (RAM, CPU, network, etc.)
11. Start the VM

**Recommended VM Settings:**
- RAM: 4096 MB (4GB) or more
- CPUs: 2 or more
- Network: NAT or Bridged Adapter

**Alternative:** You can also attach the VDI to an existing VM:
- Settings → Storage → Controller: SATA → Add Hard Disk → Choose Existing Disk → Select the VDI file

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
