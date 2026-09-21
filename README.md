# kinoite-x27

Custom Fedora Kinoite, built with [BlueBuild](https://blue-build.org/).
Recipe: [`recipes/recipe.yml`](recipes/recipe.yml)
Image: `ghcr.io/gamerx27/kinoite-x27`

## What's in it

- Brave Origin (native package, set as default browser)
- Removed: Firefox, KHelpCenter, Discover
- Dark theme, Papirus-Dark icons, Konsole on Fish, Fish as default shell
- fastfetch, htop, nvtop, nano, pciutils, lm_sensors
- NetworkManager connectivity check off, auto-updates on
- CachyOS kernel (BORE scheduler) instead of stock Fedora — see caveats below

## Install

**Fresh machine, no OS yet:** a custom installer ISO with everything in this
repo already baked in is built weekly (and on demand) by
[the `build-iso` workflow](.github/workflows/iso.yml) and published to the
**[Releases page](https://github.com/GamerX27/X27-Kionite/releases/tag/iso-latest)**
(always the current `main`, not a fixed version). Flash it (Fedora Media
Writer works) and install like any other Fedora ISO.

**Already running stock Fedora Kinoite:** rebase onto this image instead.
(No Kinoite at all and don't want the custom ISO? [Grab the stock one here](https://fedoraproject.org/atomic-desktops/kinoite/).)

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
new ones. Run once, **as yourself, no `sudo`** (sudo writes to root's config,
not yours):

```
plasma-apply-lookandfeel -a org.kde.breezedark.desktop
kwriteconfig6 --file kdeglobals --group Icons --key Theme Papirus-Dark
chsh -s /usr/bin/fish "$USER"
kquitapp6 plasmashell; kstart plasmashell >/dev/null 2>&1 &
```

`chsh` asks for **your own login password**, not root's — that's normal.
Then log out and back in: the shell change needs a new session, and Konsole
needs to be relaunched to pick up the profile.

Old Anaconda-installed KDE games may still be around:

```
sudo flatpak remove --noninteractive org.kde.elisa org.kde.kmahjongg org.kde.kolourpaint org.kde.kmines
sudo flatpak remote-modify --disable fedora fedora-testing
```

## Kernel caveats

This image ships the [CachyOS kernel](https://copr.fedorainfracloud.org/coprs/bieszczaders/kernel-cachyos/)
instead of stock Fedora's.

- **CPU must support x86_64-v3** (any Zen-family AMD, Haswell+ Intel). Installing
  on an unsupported CPU produces an unbootable system. Check with:
  `/lib64/ld-linux-x86-64.so.2 --help | grep "(supported, searched)"`
- **Unsigned.** If Secure Boot is on, either turn it off or sign the kernel
  yourself with `sbsigntools`/`mokutil` (both included in the image) — see the
  copr page's Secure Boot instructions.

## Build

Pushes to `main` build and publish automatically via GitHub Actions.
