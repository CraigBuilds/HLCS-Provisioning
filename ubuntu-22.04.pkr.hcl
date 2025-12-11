# Packer configuration for building Ubuntu 22.04 Virtual Machine
# This file uses HCL2 (HashiCorp Configuration Language) syntax

# Packer block defines the minimum Packer version required
# This ensures compatibility with the syntax and features used
packer {
  required_version = ">= 1.8.0"
  
  # Required plugins - Packer will automatically download these
  required_plugins {
    # VirtualBox plugin for building virtual machines
    virtualbox = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/virtualbox"
    }
    # QEMU plugin for building virtual machines (used in CI)
    qemu = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

# Variable definitions allow customization of the build
# The vm_name variable sets the output filename for the virtual machine
variable "vm_name" {
  type    = string
  default = "ubuntu-22.04"
  description = "Name of the virtual machine output file"
}

# Variable for Ubuntu version to make it easy to update
variable "ubuntu_version" {
  type    = string
  default = "22.04.5"
  description = "Ubuntu version to download and build"
}

# Source block defines where to get the base image and how to build it
# The "virtualbox-iso" builder creates virtual machines using VirtualBox
source "virtualbox-iso" "ubuntu" {
  # Name of the VM being built (used in output messages and VirtualBox)
  vm_name = "${var.vm_name}"
  
  # ISO image URL - this downloads the Ubuntu 22.04 desktop installation ISO
  iso_url = "https://releases.ubuntu.com/${var.ubuntu_version}/ubuntu-${var.ubuntu_version}-desktop-amd64.iso"
  
  # Checksum to verify the ISO file integrity (prevents corrupted downloads)
  # This is the SHA256 hash for Ubuntu 22.04.5 Desktop
  iso_checksum = "sha256:bfd1cee02bc4f35db939e69b934ba49a39a378797ce9aee20f6e3e3e728fefbf"
  
  # Output directory where the built VM will be stored
  output_directory = "output-${var.vm_name}"
  
  # Disk configuration
  disk_size = 30720              # Size of the virtual hard disk in MB (30GB - desktop needs more space)
  hard_drive_interface = "sata"  # SATA interface for the hard drive
  
  # VM hardware configuration
  memory = 4096                  # RAM in megabytes (4GB - desktop needs more RAM)
  cpus = 2                       # Number of virtual CPU cores
  
  # Guest OS type - tells VirtualBox what OS to expect
  # This optimizes settings for Ubuntu 64-bit
  guest_os_type = "Ubuntu_64"
  
  # Boot configuration
  # The boot_command sends keystrokes during installation to automate it
  # This configures the Ubuntu autoinstall (cloud-init based installation)
  boot_command = [
    # Wait for boot menu
    "<wait>",
    # Press 'e' to edit boot parameters
    "e<wait>",
    # Navigate to the kernel line
    "<down><down><down><end>",
    # Add autoinstall parameters to the kernel command line
    " autoinstall ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/",
    # Boot with the modified parameters
    "<f10>"
  ]
  
  # Boot wait time - how long to wait before sending boot_command
  boot_wait = "5s"
  
  # HTTP directory to serve cloud-init configuration files
  # Packer starts a temporary web server to serve these files during installation
  http_directory = "http"
  
  # SSH configuration - Packer uses SSH to connect to the VM after installation
  ssh_username = "ubuntu"           # Default user created by autoinstall
  ssh_password = "ubuntu"           # Temporary password (should be changed in production)
  ssh_timeout = "30m"               # Maximum time to wait for SSH to become available
  ssh_handshake_attempts = 100      # Number of SSH connection attempts
  
  # Shutdown command - run after build completes to cleanly shut down the VM
  # The sudo command requires the password, which is provided via echo
  shutdown_command = "echo 'ubuntu' | sudo -S shutdown -P now"
  
  # Headless mode - set to false if you want to see the VM console during build
  headless = true
  
  # VirtualBox Guest Additions - not installed by default for minimal setup
  guest_additions_mode = "disable"
  
  # Export format - OVF is the standard format for VirtualBox VMs
  format = "ova"
}

# Source block for QEMU builder (used in CI)
# The "qemu" builder creates virtual machines using QEMU emulation
# This allows building x86_64 VMs on any platform without requiring VirtualBox
source "qemu" "ubuntu" {
  # Name of the VM being built
  vm_name = "${var.vm_name}"
  
  # ISO image URL - same Ubuntu 22.04 desktop ISO as VirtualBox builder
  iso_url = "https://releases.ubuntu.com/${var.ubuntu_version}/ubuntu-${var.ubuntu_version}-desktop-amd64.iso"
  
  # Checksum to verify the ISO file integrity
  iso_checksum = "sha256:bfd1cee02bc4f35db939e69b934ba49a39a378797ce9aee20f6e3e3e728fefbf"
  
  # Output directory where the built VM will be stored
  output_directory = "output-${var.vm_name}"
  
  # Disk configuration
  disk_size = 30720              # Size of the virtual hard disk in MB (30GB)
  disk_interface = "virtio"      # Use virtio for better performance
  format = "qcow2"               # QEMU's native format, easily convertible to VDI
  
  # VM hardware configuration
  memory = 4096                  # RAM in megabytes (4GB)
  cpus = 2                       # Number of virtual CPU cores
  
  # QEMU machine type - use standard x86_64 PC
  machine_type = "pc"
  
  # Accelerator - use "none" for software virtualization (works on GitHub Actions)
  # This allows QEMU to run without requiring KVM/nested virtualization
  accelerator = "none"
  
  # Network configuration
  net_device = "virtio-net"
  
  # Boot configuration - reuse same autoinstall boot command as VirtualBox
  boot_command = [
    # Wait for boot menu
    "<wait>",
    # Press 'e' to edit boot parameters
    "e<wait>",
    # Navigate to the kernel line
    "<down><down><down><end>",
    # Add autoinstall parameters to the kernel command line
    " autoinstall ds=nocloud-net\\;s=http://{{.HTTPIP}}:{{.HTTPPort}}/",
    # Boot with the modified parameters
    "<f10>"
  ]
  
  # Boot wait time
  boot_wait = "5s"
  
  # HTTP directory to serve cloud-init configuration files
  http_directory = "http"
  
  # SSH configuration - same as VirtualBox builder
  ssh_username = "ubuntu"
  ssh_password = "ubuntu"
  ssh_timeout = "30m"
  ssh_handshake_attempts = 100
  
  # Shutdown command
  shutdown_command = "echo 'ubuntu' | sudo -S shutdown -P now"
  
  # Headless mode - no GUI
  headless = true
  
  # QEMU display - use none since we're running headless
  display = "none"
}

# Build block defines what to do with the source
# This is where we specify provisioners and post-processors
build {
  # Name of the build for logging purposes
  name = "ubuntu-22.04-build"
  
  # Sources to build from
  # Using QEMU builder for CI (works reliably on GitHub Actions ubuntu-latest)
  # The VirtualBox builder above is kept for local builds if needed
  sources = ["source.qemu.ubuntu"]
  
  # Provisioner: shell commands to run inside the VM after installation
  # This updates the system and installs basic tools
  provisioner "shell" {
    # Inline commands to execute
    inline = [
      # Wait for cloud-init to finish (prevents package lock conflicts)
      "cloud-init status --wait",
      # Update package lists
      "sudo apt-get update",
      # Upgrade all packages to latest versions
      "sudo apt-get upgrade -y",
      # Clean up package cache to reduce image size
      "sudo apt-get clean"
    ]
  }
  
  # Post-processor: compress is removed - we'll convert to VDI and compress in CI
  # The QEMU builder produces a qcow2 disk that will be converted to VDI format
}
