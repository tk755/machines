#!/usr/bin/env python3

"""
This script configures my monitors by performing the following tasks:

1. Disables inactive monitors.
2. Sets resolution of laptop screen based on hostname.
3. Sets resolution of active monitors to max.
4. Sets placement of monitors.
5. Sets wallpapers based on hostname.
"""

import os, re, socket, subprocess, sys

# get hostname
HOSTNAME = socket.gethostname()

# get list of connected and disconnected monitors from `xrandr`
stdout, _ = subprocess.Popen(['xrandr'], text=True, stdout=subprocess.PIPE).communicate()
CONNECTED_MONITORS = [re.search('^(.*) connected .*', line).group(1) for line in stdout.split('\n') if re.search('^(.*) connected .*', line)]
DISCONNECTED_MONITORS = [re.search('^(.*) disconnected .*', line).group(1) for line in stdout.split('\n') if re.search('^(.*) disconnected .*', line)]

def set_monitors():
    # disable monitors
    for monitor in CONNECTED_MONITORS + DISCONNECTED_MONITORS:
        subprocess.call(['xrandr', '--output', monitor, '--off'])

    # set resolution and position of all active monitors
    for idx, monitor in enumerate(CONNECTED_MONITORS):
        # set resolution of display
        if idx == 0 and HOSTNAME == 'kawasaki':
            subprocess.call(['xrandr', '--output', monitor, '--mode', '1680x1050'])
        elif idx == 0 and HOSTNAME == 'yamaha':
            subprocess.call(['xrandr', '--output', monitor, '--mode', '1920x1080'])
        else:
            subprocess.call(['xrandr', '--output', monitor, '--auto'])
        # position monitors from right to left
        if idx > 0:
            subprocess.call(['xrandr', '--output', monitor, '--left-of', CONNECTED_MONITORS[idx-1]])

# get wallpaper directory
stdout, _ = subprocess.Popen(['xdg-user-dir', 'PICTURES'], text=True, stdout=subprocess.PIPE).communicate()

WALLPAPER_DIR = os.path.join(stdout.strip(), 'wallpapers/active/')
DEFAULT_WALLPAPER = os.path.join(WALLPAPER_DIR, 'default')

def _wallpaper_path(name):
    """Return path to wallpaper if it exists, otherwise return default wallpaper path."""
    if os.path.isfile(os.path.join(WALLPAPER_DIR, name)):
        return os.path.join(WALLPAPER_DIR, name)
    else:
        return DEFAULT_WALLPAPER

def set_wallpapers():
    """Set wallpapers on each active monitor using feh."""
    # get paths to wallpapers
    wallpaper_names = [HOSTNAME] + list(map(str, range(1, len(CONNECTED_MONITORS))))
    wallpaper_paths = [_wallpaper_path(name) for name in wallpaper_names]

    # set wallpapers using `feh`
    feh_command = ['feh']
    for path in wallpaper_paths:
        feh_command.append('--bg-fill')
        feh_command.append(path)

    subprocess.call(feh_command)

if __name__ == '__main__':
    set_monitors()
    set_wallpapers()

    # send notification
    SCRIPT_NAME = os.path.basename(sys.argv[0])
    subprocess.Popen(['notify-send', SCRIPT_NAME, 'Configured the following monitors: ' + ', '.join(CONNECTED_MONITORS), '-u', 'low'])
