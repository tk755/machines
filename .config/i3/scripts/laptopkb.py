#!/usr/bin/env python3

import re, subprocess, sys, os

SCRIPT_NAME = os.path.basename(sys.argv[0])

# laptop kb identifiers
IDENTIFIERS = ['Apple Internal Keyboard', 'AT Translated Set']

def detect_olkb():
    """Returns whether an OLKB keyboard is connected to the computer.
    Requires: xinput, grep, wc."""
    proc1 = subprocess.Popen(['xinput', 'list'], stdout=subprocess.PIPE)
    proc2 = subprocess.Popen(['grep', 'OLKB'], stdin=proc1.stdout, stdout=subprocess.PIPE)
    proc3 = subprocess.Popen(['wc', '-l'], stdin=proc2.stdout, stdout=subprocess.PIPE)
    stdout, stderr = proc3.communicate()

    return not int(stdout) == 0

def laptopkb_id():
    """Returns the xinput id of the laptop keyboard."""
    proc = subprocess.Popen(['xinput', 'list'], text=True, stdout=subprocess.PIPE)
    stdout, stderr = proc.communicate()

    pattern = '.*(' + '|'.join(IDENTIFIERS) + ').*id=([\d]*).*'
    match = re.search(pattern, stdout, re.IGNORECASE)
    if match:
        return match.group(2)

def prop_id():
    proc = subprocess.Popen(['xinput', '--list-props', laptopkb_id()], text=True, stdout=subprocess.PIPE)
    stdout, stderr = proc.communicate()

    pattern = 'Device Enabled \(([\d]*)\).*'
    match = re.search(pattern, stdout, re.IGNORECASE)
    if match:
        return match.group(1)

def enablekb():
    subprocess.Popen(['xinput', 'reattach', laptopkb_id(), '3'])
    subprocess.Popen(['xinput', '--set-prop', laptopkb_id(), prop_id(), '1'])
    subprocess.Popen(['notify-send', SCRIPT_NAME, 'Laptop keyboard enabled.', '-u', 'low'])

def disablekb():
    subprocess.Popen(['xinput', 'float', laptopkb_id()])
    subprocess.Popen(['xinput', '--set-prop', laptopkb_id(), prop_id(), '0'])
    subprocess.Popen(['notify-send', SCRIPT_NAME, 'Laptop keyboard disabled.', '-u', 'low'])

if __name__ == '__main__':
    if laptopkb_id() is None:
        subprocess.Popen(['notify-send', SCRIPT_NAME, 'Could not determine laptop keyboard id. Check identifiers list.', '-u', 'critical'])
    elif detect_olkb():
        disablekb()
    else:
        enablekb()
        
