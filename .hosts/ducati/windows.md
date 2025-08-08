## Winget

Winget is a Windows package manager CLI tool that enables users to discover, install, upgrade, and manage software applications from a centralized repository. It is like `apt` on Debian or `pacman` on Arch.

### Install Packages

This is my current external package list.

```json
{
  "Packages": [
    { "PackageIdentifier": "7zip.7zip" },
    { "PackageIdentifier": "Bambulab.Bambustudio" },
    { "PackageIdentifier": "Docker.DockerDesktop" },
    { "PackageIdentifier": "Git.Git" },
    { "PackageIdentifier": "REALiX.HWiNFO" },
    { "PackageIdentifier": "Mozilla.Firefox" },
    { "PackageIdentifier": "VideoLAN.VLC" },
    { "PackageIdentifier": "LedgerHQ.LedgerLive" },
    { "PackageIdentifier": "RaspberryPiFoundation.RaspberryPiImager" },
    { "PackageIdentifier": "Logitech.OptionsPlus" },
    { "PackageIdentifier": "dorssel.usbipd-win" },
    { "PackageIdentifier": "Dropbox.Dropbox" },
    { "PackageIdentifier": "Microsoft.Edge" },
    { "PackageIdentifier": "OBSProject.OBSStudio" },
    { "PackageIdentifier": "Microsoft.DotNet.SDK.8" },
    { "PackageIdentifier": "ExpressVPN.ExpressVPN" },
    { "PackageIdentifier": "Microsoft.PowerToys" },
    { "PackageIdentifier": "Discord.Discord" },
    { "PackageIdentifier": "Zoom.Zoom.EXE" },
    { "PackageIdentifier": "Obsidian.Obsidian" },
    { "PackageIdentifier": "Microsoft.VisualStudioCode" },
    { "PackageIdentifier": "Microsoft.WindowsTerminal" }
  ]
}
```

Copy the list above to `packages.json` and install it with this (run as admin):

```powershell
winget import -i packages.json --accept-source-agreements --accept-package-agreements
```

### Update Packages

Update all packages automatically (run as admin):

```powershell
winget source reset --force
winget source update
winget upgrade --all --include-unknown `
  --accept-package-agreements --accept-source-agreements `
  --silent --disable-interactivity
```