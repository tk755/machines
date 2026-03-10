# Colloid-Suzuki

Custom dark variant of [Colloid GTK Theme](https://github.com/vinceliuice/Colloid-gtk-theme) with a blue-tinted grey ramp to match a dark blue wallpaper and semi-transparent waybar.

## Custom grey ramp

Only the dark greys were modified from the default palette. Each value shifts R-2, G+0, B+6 relative to a neutral grey at the same perceived luminance:

| Variable   | Default  | This theme |
|------------|----------|------------|
| $grey-550  | #555555  | #494b53    |
| $grey-600  | #464646  | #393b46    |
| $grey-650  | #3C3C3C  | #2f313b    |
| $grey-700  | #2C2C2C  | #20222c    |
| $grey-750  | #242424  | #191b23    |
| $grey-800  | #212121  | #15171f    |
| $grey-850  | #121212  | #0e1018    |
| $grey-900  | #0F0F0F  | #090b12    |
| $grey-950  | #030303  | #040509    |

## Custom accent colors

Warning and success colors adjusted to match waybar/mako/fuzzel:

| Variable       | Default  | This theme |
|----------------|----------|------------|
| $green-light   | #66BB6A  | #4CAF50    |
| $yellow-light  | #FFD600  | #FBC02D    |

## Rebuilding

Requires `sassc` (`sudo pacman -S sassc`).

```sh
git clone https://github.com/vinceliuice/Colloid-gtk-theme /tmp/colloid
cd /tmp/colloid

# create custom palette (copy default, edit greys)
cp src/sass/_color-palette-default.scss src/sass/_color-palette-custom.scss
# edit grey values in _color-palette-custom.scss

# point the build at the custom palette
sed -i 's/color-palette-default/color-palette-custom/' src/sass/_tweaks.scss

# install dark variant only
./install.sh -c dark -t default -n Colloid-Suzuki
```
