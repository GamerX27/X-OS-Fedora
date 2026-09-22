# X-OS-Fedora

Custom Fedora Kinoite, built with [BlueBuild](https://blue-build.org/).

- Base: `ghcr.io/gamerx27/x-os-fedora` — [recipe.yml](recipes/recipe.yml)
- LTS kernel: `ghcr.io/gamerx27/x-os-fedora-lts` — [recipe-lts.yml](recipes/recipe-lts.yml)
- Gaming: `ghcr.io/gamerx27/x-os-gaming` — [recipe-gaming.yml](recipes/recipe-gaming.yml)
- Media PC: `ghcr.io/gamerx27/x-os-media-pc` — [recipe-media-pc.yml](recipes/recipe-media-pc.yml)

## What's in it

- Brave (default browser), debranded with [X-Linuxtool](https://codeberg.org/X27/X-Linuxtool)
- Removed: Firefox, KHelpCenter, Discover
- Dark theme, Papirus icons, Fish shell, Kitty terminal, fastfetch banner
- fastfetch, htop, nvtop, nano, pciutils, lm_sensors, topgrade
- VLC and Bazaar (Flatpak), Bazaar replacing Discover
- Brave, Dolphin, Kitty, and Bazaar pinned to the taskbar (new accounts only)
- Hot corners and the shake-to-locate-cursor effect disabled (new accounts only)
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

Swap `x-os-fedora` for `x-os-fedora-lts` (LTS kernel), `x-os-gaming`
(Steam/gaming, see below), or `x-os-media-pc` (media center, see below) in
the commands above.

## Update

```
topgrade
```

Updates the system image, Flatpaks, and everything else in one command.
Nothing updates on its own — you always run this yourself.

## First login after rebasing

Theme, icons, shell, and the hot-corners/shake-cursor settings only apply to
new accounts. Run once as
yourself, no `sudo`:

```
plasma-apply-lookandfeel -a org.kde.breezedark.desktop
chsh -s /usr/bin/fish "$USER"
kquitapp6 plasmashell; kstart plasmashell >/dev/null 2>&1 &
```

`plasma-apply-lookandfeel` now brings Papirus-Dark icons with it (our
`org.kde.breezedark.desktop` package overrides the upstream defaults, which
otherwise apply `breeze-dark`).

Log out and back in afterward for the shell change to take effect.

Remove leftover Anaconda KDE games if you have them:

```
sudo flatpak remove --noninteractive org.kde.elisa org.kde.kmahjongg org.kde.kolourpaint org.kde.kmines
sudo flatpak remote-modify --disable fedora fedora-testing
```

## Kernel

`x-os-fedora` and `x-os-gaming` ship the
[CachyOS kernel](https://copr.fedorainfracloud.org/coprs/bieszczaders/kernel-cachyos/)
(BORE scheduler); `x-os-fedora-lts` and `x-os-media-pc` ship its LTS variant
instead. All replace the stock Fedora kernel.

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
- Steam, Kitty, Brave, and Bazaar pinned to the taskbar (new accounts only)

## Media PC variant

Everything in the base image, plus:

- LTS kernel (see above)
- Jellyfin Desktop and Finamp (Flatpak) for media playback
- LocalSend (Flatpak) for quick file transfers
- Jellyfin Desktop, VLC, Finamp, and Bazaar pinned to the taskbar (new accounts only)

## Build

Pushes to `main` build and publish automatically via GitHub Actions, which
also rebuilds weekly to pick up upstream Kinoite/Brave/kernel updates.

## Build ISO locally

Generates an installer ISO from the already-published `ghcr.io/gamerx27`
image, the same approach as the CI [`iso.yml`](.github/workflows/iso.yml)
workflow — nothing is built from local recipes, so this needs a network
connection to GHCR.

**Prerequisites:**
- docker (the script forces `--build-driver docker --run-driver docker`;
  rootful podman's networking can be broken on some machines - Docker runs
  its own daemon-managed NAT and sidesteps that)
- sudo access
- ~20GB free disk (image pull + ISO — past ISOs have run ~6.5GB)
- x86_64-v3 CPU to boot the resulting image (see [Kernel](#kernel) above)

```
./scripts/build-iso.sh [fedora|lts|gaming|media-pc]
```

Defaults to `fedora` if no argument is given. Installs the BlueBuild CLI on
first run if it's missing (asks for confirmation before running the
installer; pass `-y` to skip the prompt). Output goes to `iso-out/` at the
repo root: `<name>.iso` and `<name>.iso.sha256sum`.
