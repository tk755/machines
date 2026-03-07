# Colloid-Darker

Custom dark variant of [Colloid GTK Theme](https://github.com/vinceliuice/Colloid-gtk-theme) with a darker grey ramp (between default dark and black).

## Custom grey ramp

Only the dark greys were modified from the default palette:

| Variable   | Default  | This theme |
|------------|----------|------------|
| $grey-550  | #555555  | #464646    |
| $grey-600  | #464646  | #383838    |
| $grey-650  | #3C3C3C  | #303030    |
| $grey-700  | #2C2C2C  | #1A1A1A    |
| $grey-750  | #242424  | #161616    |
| $grey-800  | #212121  | #131313    |
| $grey-850  | #121212  | #0D0D0D    |
| $grey-900  | #0F0F0F  | #080808    |

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
./install.sh -c dark -t default -n Colloid-Darker
```
