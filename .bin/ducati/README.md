# `ducati`

**NOTE:** **Currently `ducati` does not use GPU passthrough for VMs.** I performed the installation steps so I know they work, but I reverted back after realizing that 95% of my usage is on Linux. It doesn't currently make sense to reserve my GPU for the other 5%. But I leave this document in case the need ever arises in the future.

## Purpose

Linux development workstation with an on-demand Windows VM using GPU passthrough for applications like CAD and occasional gaming.
- When the VM is off, Linux retains full GPU access for compute workloads.
- When the VM is on, the GPU is exclusively passed through to Windows.
- Linux graphics always run on the iGPU for stability and uninterrupted desktop access.
- Accessible remotely via Tailscale.

## Hardware

Type | Make | Model | Date | Price
--- | --- | --- | --- | ---
GPU | NVIDIA | RTX 3090 Ti | Oct 2022 | $1,172.86
CPU | Intel | Core i7-13700K | Nov 2022 | $392.57
RAM | Corsair | Vengeance LPX 64 GB DDR4 3600 MHz | Nov 2022 | $183.38
Storage | WD | SN850X 2 TB NVMe SSD (x2) | Nov 2022 | $362.50
Motherboard | MSI | MAG 7690 Tomahawk WIFI DDR4 | Nov 2022 | $267.56

## Architecture

- **Host OS:** Fedora Linux 42 (Sway)
- **Virtualization:** QEMU/KVM hypervisor (w/ libvirt, virt-manager, VFIO, Looking Glass)
- **Networking:** Tailscale for private SSH and streaming access
- **Game Streaming:** Sunshine server on Windows VM for Moonlight clients
- **Media Services:** Docker Compose stack (Jellyfin, *Arr suite, qBittorrent w/ Gluetun) until migrated to `aprilia`

## Virtualization

- **QEMU/KVM:** Provides hardware-accelerated virtual machines with near-native performance
- **libvirt:** Manages VM definitions, lifecycle, and hardware passthrough consistently via CLI and API
- **virt-manager:** GUI front-end for easy creation and configuration of VMs
- **VFIO GPU passthrough:** Temporarily unbinds the GPU from Linux and assigns it directly to the Windows VM on launch (blocks if the GPU is in use by any Linux process); returns it to Linux on shutdown
- **Looking Glass:** Displays the Windows VM inside the Linux desktop with low latency, removing the need for a separate monitor

## Scripts
Script | Purpose
--- | ---
`windows-start` | Start VM, bind GPU to VFIO, launch LG client
`windows-stop` | Gracefully stop VM, rebind GPU to Linux
`vfio-status` | Show whether GPU is bound to Linux or VFIO + list active GPU processes
`gpu-rebind-nvidia` | Force GPU back to Linux if passthrough gets stuck
`install-hooks` | Deploy/update libvirt VFIO hooks (idempotent)
`install-services` | Install optional systemd services (e.g., LG client autostart)
`lg-test` (opt) | Sanity-check Looking Glass after update
`vm-health` (opt) | Summarize VM state, vCPU/RAM, PCI devices

## Usage

From host or SSH session:

```bash
windows-start         # Start VM + Looking Glass (blocks if GPU in use by Linux)
windows-stop          # Stop VM and reattach GPU to Linux
vfio-status           # Check GPU binding and usage
```

From client machine (via Tailscale):

```
ssh ducati windows-start
```

> You can start/stop the Windows VM remotely; GPU workloads on Linux will be interrupted while Windows owns the GPU.

## Installation

### 0. UEFI Setup

In BIOS/UEFI:
- Enable IOMMU (Intel VT-d or AMD-Vi)
- Set iGPU as the primary display

Plug monitors into the iGPU ports and reboot.

### 1. Enable IOMMU in Kernel

Edit GRUB:
```bash
sudo nano /etc/default/grub
```

Add to `GRUB_CMDLINE_LINUX=`:
- Intel CPU:
    ```ini
    intel_iommu=on iommu=pt rd.driver.pre=vfio-pci
    ```
- AMD CPU:
    ```ini
    amd_iommu=on iommu=pt rd.driver.pre=vfio-pci
    ```

Rebuild GRUB:
```bash
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
```

### 2. Identify NVIDIA GPU devices

Run:
```bash
lspci -nn | grep -i nvidia
```

Output on `ducati`:
```
01:00.0 VGA compatible controller [0300]: NVIDIA Corporation GA102 [GeForce RTX 3090 Ti] [10de:2203] (rev a1) 
01:00.1 Audio device [0403]: NVIDIA Corporation GA102 High Definition Audio Controller [10de:1aef] (rev a1)
```
Note the PCI IDs for both VGA and Audio (`10de:2203`, `10de:1aef`).

### 3. Bind NVIDIA to VFIO

Create files for vfio binding + nvidia drivers blacklist:
```bash
# Bind RTX 3090 Ti and its audio function to vfio-pci
sudo bash -c 'cat >/etc/modprobe.d/vfio.conf <<EOF
options vfio-pci ids=10de:2203,10de:1aef disable_vga=1
EOF'

# Prevent both nouveau and proprietary nvidia from loading on the host
sudo bash -c 'cat >/etc/modprobe.d/blacklist-nvidia.conf <<EOF
blacklist nouveau
blacklist nova_core
blacklist nvidia
blacklist nvidia_drm
blacklist nvidia_modeset
EOF'
```

Create a file to load vfio module early (required on Fedora):
```bash
sudo bash -c 'echo "force_drivers+=\" vfio vfio_pci vfio_iommu_type1 \"" > /etc/dracut.conf.d/vfio.conf'
```

Rebuild initramfs so this takes effect early in boot:
```bash
sudo dracut --force
```

### 4. Reboot and confirm VFIO binding

After reboot:
```bash
lspci -nnk -d 10de:2203
```

Expected:
```
Kernel driver in use: vfio-pci
```

### 5. Install virtualization stack

```bash
sudo dnf install -y @virtualization
```

Enable services:
```bash
sudo systemctl enable --now libvirtd
```

### 6. Create Windows VM

[I never got this far]