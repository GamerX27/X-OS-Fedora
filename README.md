# kinoite-x27

Custom Fedora Kinoite, built with [BlueBuild](https://blue-build.org/).
Recipe: [`recipes/recipe.yml`](recipes/recipe.yml)
Image: `ghcr.io/gamerx27/kinoite-x27`

## What's in it

- Brave Origin (native package, set as default browser)
- Removed: Firefox, KHelpCenter, Discover
- Dark theme, Papirus-Dark icons, Konsole on Fish, Fish as default shell
- fastfetch, htop, nvtop, nano, pciutils, lm_sensors
- Flatpaks: VLC, Jellyfin, LocalSend, Bazaar, Finamp
- NetworkManager connectivity check off, auto-updates on

## Install

No Kinoite yet? [Download the ISO](https://fedoraproject.org/atomic-desktops/kinoite/).

```
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/gamerx27/kinoite-x27:latest
systemctl reboot
```

Then switch to verified pulls (key's already in the image, nothing to set up):

```
sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/gamerx27/kinoite-x27:latest
systemctl reboot
```

## Update

```
sudo rpm-ostree upgrade
systemctl reboot
```

(also happens automatically in the background)

## If you rebased an existing install

Theme/icons/shell/Konsole won't apply to your account automatically — only to
new ones. Run once:

```
plasma-apply-lookandfeel -a org.kde.breezedark.desktop
kwriteconfig6 --file kdeglobals --group Icons --key Theme Papirus-Dark
chsh -s /usr/bin/fish "$USER"
```

Old Anaconda-installed KDE games may still be around:

```
sudo flatpak remove --noninteractive org.kde.elisa org.kde.kmahjongg org.kde.kolourpaint org.kde.kmines
sudo flatpak remote-modify --disable fedora fedora-testing
```

## Build

Pushes to `main` build and publish automatically via GitHub Actions.
