#!/bin/bash
# Wrapper script for building Ubuntu VM with Packer
# This script provides informative output during the build process

set -e  # Exit on error

echo ""
echo "════════════════════════════════════════════════════════════════════════════════"
echo "🚀 Starting Ubuntu 22.04 VM Build with Packer"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""
echo "Build process overview:"
echo "  1. Downloading Ubuntu ISO (if not cached)"
echo "  2. Creating VirtualBox VM"
echo "  3. Starting automated installation"
echo "  4. ⏱️  Waiting for SSH (15-25 minutes) ← THIS IS THE LONGEST STEP"
echo "  5. Running provisioning scripts"
echo "  6. Compressing final output"
echo ""
echo "════════════════════════════════════════════════════════════════════════════════"
echo "📋 IMPORTANT: About the 'Waiting for SSH to become available...' step"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""
echo "When you see the message:"
echo "  '==> ubuntu-22.04-build.virtualbox-iso.ubuntu: Waiting for SSH to become available...'"
echo ""
echo "This is EXPECTED to take 15-25 minutes. During this time:"
echo ""
echo "  ✓ Ubuntu is partitioning the disk"
echo "  ✓ Installing the base system and desktop packages"
echo "  ✓ Configuring users, network, and SSH"
echo "  ✓ Running system finalization tasks"
echo "  ✓ Rebooting the system"
echo ""
echo "SSH will become available automatically when installation completes."
echo "The process is NOT stuck - Ubuntu is actively installing in the background!"
echo ""
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""
echo "⏳ Total estimated build time: 30-40 minutes"
echo ""
echo "Press Ctrl+C to cancel, or press Enter to continue..."
read -r

echo ""
echo "🔧 Initializing Packer plugins..."
packer init ubuntu-22.04.pkr.hcl

echo ""
echo "✅ Validating Packer configuration..."
packer validate ubuntu-22.04.pkr.hcl

echo ""
echo "🏗️  Starting build (this will take 30-40 minutes)..."
echo ""
packer build ubuntu-22.04.pkr.hcl

echo ""
echo "════════════════════════════════════════════════════════════════════════════════"
echo "✅ Build completed successfully!"
echo "════════════════════════════════════════════════════════════════════════════════"
echo ""
echo "Output: ubuntu-22.04.tar.gz"
echo ""
