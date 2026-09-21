# X-OS-Fedora

Custom Fedora Kinoite, built with [BlueBuild](https://blue-build.org/).

- Base: `ghcr.io/gamerx27/x-os-fedora` — [recipe.yml](recipes/recipe.yml)
- LTS kernel: `ghcr.io/gamerx27/x-os-fedora-lts` — [recipe-lts.yml](recipes/recipe-lts.yml)
- Gaming: `ghcr.io/gamerx27/x-os-gaming` — [recipe-gaming.yml](recipes/recipe-gaming.yml)

## What's in it

- Brave (default browser), debranded with [X-Linuxtool](https://codeberg.org/X27/X-Linuxtool)
- Removed: Firefox, KHelpCenter, Discover
- Dark theme, Papirus icons, Fish shell, Konsole on Fish, fastfetch banner
- fastfetch, htop, nvtop, nano, pciutils, lm_sensors, topgrade
- VLC (Flatpak)
- CachyOS kernel (BORE scheduler); LTS variant published separately
- Auto-updates off — update manually with `topgrade`
- `/etc/os-release` stamped with the build date

## Install

**Fresh machine:**
you can get the ISO file on [archive.org](https://archive.org/details/x-os-fedora)

**Already on Fedora Kinoite:** rebase onto this image.

```
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/gamerx27/x-os-fedora:latest
systemctl reboot
```

Then switch to verified pulls:

```
sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/gamerx27/x-os-fedora:latest
systemctl reboot
```

Swap `x-os-fedora` for `x-os-fedora-lts` (LTS kernel) or `x-os-gaming`
(Steam/gaming, see below) in the commands above.

## Update

```
topgrade
```

Updates the system image, Flatpaks, and everything else in one command.
Nothing updates on its own — you always run this yourself.

## First login after rebasing

Theme, icons, shell, and Konsole only apply to new accounts. Run once as
yourself, no `sudo`:

```
plasma-apply-lookandfeel -a org.kde.breezedark.desktop
kwriteconfig6 --file kdeglobals --group Icons --key Theme Papirus-Dark
chsh -s /usr/bin/fish "$USER"
kquitapp6 plasmashell; kstart plasmashell >/dev/null 2>&1 &
```

Log out and back in afterward for the shell change to take effect.

Remove leftover Anaconda KDE games if you have them:

```
sudo flatpak remove --noninteractive org.kde.elisa org.kde.kmahjongg org.kde.kolourpaint org.kde.kmines
sudo flatpak remote-modify --disable fedora fedora-testing
```

## Kernel

`x-os-fedora` and `x-os-gaming` ship the
[CachyOS kernel](https://copr.fedorainfracloud.org/coprs/bieszczaders/kernel-cachyos/)
(BORE scheduler); `x-os-fedora-lts` ships its LTS variant instead. Both
replace the stock Fedora kernel.

- **Needs an x86_64-v3 CPU** (Zen-family AMD, Haswell+ Intel). Older CPUs
  won't boot it. Check with:
  `/lib64/ld-linux-x86-64.so.2 --help | grep "(supported, searched)"`
- **Unsigned.** Turn off Secure Boot, or sign it yourself with
  `sbsigntools`/`mokutil` (both included).

## Gaming variant

Everything above, plus:

- Steam, GameMode, Gamescope, MangoHud, GOverlay
- Faugus Launcher, Heroic Games Launcher
- RPM Fusion codecs and freeworld Mesa VA-API/Vulkan drivers
- `proton-cachyos-install` — run it yourself to install or update
  [Proton-CachyOS](https://github.com/CachyOS/proton-cachyos) into Steam
- Steam, Konsole, and Brave pinned to the taskbar (new accounts only)

## Build

Pushes to `main` build and publish automatically via GitHub Actions, which
also rebuilds weekly to pick up upstream Kinoite/Brave/kernel updates.
