# `ducati`

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

- **Host OS:** Ubuntu Server 24.04 LTS (w/ i3wm + dev tools)
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

[TODO]
