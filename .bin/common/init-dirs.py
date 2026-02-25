#!/usr/bin/env python3
#
# Initialize home directory structure.
#
# Creates short-named directories (~/dwn, ~/docs, etc.), remaps XDG
# user-dirs to point at them, and creates symlinks to cloud storage
# (e.g., Dropbox) when available. Migrates contents from old XDG
# directories if they exist. Idempotent.

import shutil
from pathlib import Path

HOME = Path.home()
XDG_DIRS_FILE = HOME / ".config/user-dirs.dirs"
XDG_CONF_FILE = HOME / ".config/user-dirs.conf"

# XDG directory mappings: XDG variable -> short directory name
XDG_DIRS = {
    "XDG_DOWNLOAD_DIR":  "dwn",
    "XDG_DOCUMENTS_DIR": "docs",
    "XDG_PICTURES_DIR":  "pics",
    "XDG_VIDEOS_DIR":    "vids",
    "XDG_MUSIC_DIR":     "music",
}

# symlinks: destination -> source (created only if source exists)
SYMLINKS = {
    "code":    "Dropbox/code",
    "docs":    "Dropbox/documents",
    "pics":    "Dropbox/media/pictures",
    "vids":    "Dropbox/media/videos",
    "music":   "Dropbox/media/music",
}


def read_xdg_dirs():
    """Read current XDG user-dirs.dirs into a dict."""
    dirs = {}
    if not XDG_DIRS_FILE.exists():
        return dirs
    for line in XDG_DIRS_FILE.read_text().splitlines():
        line = line.strip()
        if line.startswith("#") or "=" not in line:
            continue
        name, path = line.split("=", 1)
        path = path.strip('"').replace("$HOME", str(HOME))
        dirs[name] = path
    return dirs


def create_directories():
    """Create short-named home directories."""
    for name in XDG_DIRS.values():
        path = HOME / name
        if path.exists() or path.is_symlink():
            continue
        path.mkdir(parents=True)
        print(f"created {path}")


def migrate_xdg_contents():
    """Move contents from old XDG directories to new ones."""
    current = read_xdg_dirs()
    for xdg_var, short_name in XDG_DIRS.items():
        new_dir = HOME / short_name
        old_dir = current.get(xdg_var)
        if old_dir is None:
            continue
        old_dir = Path(old_dir)
        if not old_dir.exists() or old_dir == new_dir:
            continue
        # move contents
        for item in old_dir.iterdir():
            dest = new_dir / item.name
            if not dest.exists():
                shutil.move(str(item), str(dest))
        # remove empty old directory
        if not any(old_dir.iterdir()):
            old_dir.rmdir()
            print(f"migrated {old_dir} -> {new_dir}")


def create_symlinks():
    """Create symlinks to cloud storage, skipping missing sources."""
    for name, source in SYMLINKS.items():
        src = HOME / source
        dst = HOME / name
        if not src.exists():
            continue
        if dst.is_symlink():
            if dst.resolve() == src.resolve():
                continue
            dst.unlink()
        if dst.exists():
            continue
        dst.symlink_to(src)
        print(f"linked {dst} -> {src}")


def write_xdg_config():
    """Write XDG user-dirs.dirs and disable auto-creation."""
    XDG_DIRS_FILE.parent.mkdir(parents=True, exist_ok=True)

    # build new config
    lines = []
    for xdg_var, short_name in XDG_DIRS.items():
        lines.append(f'{xdg_var}="$HOME/{short_name}"')
    new_content = "\n".join(lines) + "\n"

    # skip if unchanged
    if XDG_DIRS_FILE.exists() and XDG_DIRS_FILE.read_text() == new_content:
        return

    XDG_DIRS_FILE.write_text(new_content)
    for xdg_var, short_name in XDG_DIRS.items():
        print(f"set {xdg_var} -> ~/{short_name}")

    # disable automatic XDG directory creation
    XDG_CONF_FILE.write_text("enabled=False\n")


def main():
    create_directories()
    migrate_xdg_contents()
    create_symlinks()
    write_xdg_config()


if __name__ == "__main__":
    main()
