# `ducati`

## Overview

`ducati` is a Linux development workstation that prioritizes stability and performance for compute workloads.

- Ubuntu 24.04 LTS for well-supported NVIDIA drivers and CUDA.
- Wayland/Sway desktop running on Intel iGPU for stability.
- NVIDIA GPU available on-demand via [NVIDIA PRIME Render Offload](https://wiki.archlinux.org/title/PRIME), avoiding [NVIDIA driver issues](https://wiki.archlinux.org/title/NVIDIA/Troubleshooting) and GPU passthrough fragility.
- Windows VM for Windows-only applications with SSD passthrough.
- Headless Linux VM running media services stack until migrated to `aprilia`.
- Accessible remotely via Tailscale.

## Usage

To enable the NVIDIA GPU for CUDA or gaming, use the `prime-run` command:

```bash
prime-run python3 train.py
```

## Installation

1. BIOS/UEFI configuration:
    - Disable Secure Boot.
    - Enable Above 4G Decoding.
    - Enable Resizable BAR.
    - Set the iGPU as primary and plug monitors into the iGPU.
2. Install [latest Ubuntu LTS Server](https://ubuntu.com/download/server).
    - On the disk partition screen, open a terminal (`Ctrl+Alt+T`) and run `sudo parted -l` to identify the disk to install.
3. Install [NVIDIA drivers](https://documentation.ubuntu.com/server/how-to/graphics/install-nvidia-drivers/#installing-the-drivers-for-generic-use-e-g-desktop-and-gaming) and CUDA toolkit:

    ```bash
    sudo apt update -y
    sudo ubuntu-drivers install             # install recommended NVIDIA drivers
    sudo apt install -y nvidia-cuda-toolkit # install CUDA toolkit
    sudo apt install -y nvidia-prime        # install PRIME offload
    sudo reboot
    ```

    Verify the installation:

    ```bash
    nvidia-smi      # verify driver installation
    nvcc --version  # verify CUDA installation
    which prime-run # verify prime-run installation
    ```

