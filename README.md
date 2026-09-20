# kinoite-x27

Custom Fedora Kinoite image built with [BlueBuild](https://blue-build.org/).
Source: [`recipes/recipe.yml`](recipes/recipe.yml). Published to
`ghcr.io/gamerx27/kinoite-x27`.

## What's in it

- Brave Origin, layered in from Brave's official repo. `firefox`,
  `firefox-langpacks`, `khelpcenter`, `plasma-discover`, `plasma-discover-notifier`
  removed. Brave Origin set as default browser.
- Dark theme (Breeze Dark), Papirus-Dark icons, Konsole set to Fish with no
  menu bar/toolbar/tab bar, Fish as the default shell.
- `fastfetch`, `htop`, `nvtop`, `nano`, `papirus-icon-theme`, `pciutils`,
  `lm_sensors`.
- Flathub flatpaks (system-wide): VLC, Jellyfin, LocalSend, Bazaar, Finamp.
- NetworkManager connectivity check disabled. Updates apply automatically via
  `bootc-fetch-apply-updates.timer`.

## First-time rebase

The signing key and `/etc/containers/policy.json` entry for this image are
baked into the image itself (`files/system/etc/pki/containers/kinoite-x27.pub`,
`files/system/etc/containers/policy.json`) — same way the base image trusts
itself. That means the very first pull (from your *current*, pre-rebase
system, which doesn't have that policy yet) has to be unverified, but the
moment you're on this image you already have everything needed for verified
pulls, with no manual key/policy setup:

```
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/gamerx27/kinoite-x27:latest
systemctl reboot
```

Then switch to verified pulls — no setup needed, it's already there:

```
sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/gamerx27/kinoite-x27:latest
systemctl reboot
```

After the second reboot: `rpm-ostree status` should show
`ghcr.io/gamerx27/kinoite-x27:latest` as booted, with `GPG: N/A, Signed: true`.

## Getting later updates

Already rebased? Updates apply on their own (`bootc-fetch-apply-updates.timer`
checks and stages automatically). To force one immediately:

```
sudo rpm-ostree upgrade
systemctl reboot
```

## Existing accounts: two things rebasing can't fix

- **Theme/shell/Konsole don't apply.** They're system-wide defaults
  (`/etc/xdg/kdeglobals`, `/etc/xdg/konsolerc`, `/etc/default/useradd`) that
  only take effect for a brand-new user profile — your account already has
  its own `~/.config` with the old values, which always wins. Apply them
  yourself once:
  ```
  plasma-apply-lookandfeel -a org.kde.breezedark.desktop
  kwriteconfig6 --file kdeglobals --group Icons --key Theme Papirus-Dark
  chsh -s /usr/bin/fish "$USER"
  ```
- **KDE games/apps still installed.** If this machine was originally set up
  by Anaconda, `org.kde.elisa`/`kmahjongg`/`kolourpaint`/`kmines` are
  pre-existing Flatpak state under `/var` — rebasing the OS image never
  touches it. Remove them yourself:
  ```
  sudo flatpak remove --noninteractive org.kde.elisa org.kde.kmahjongg org.kde.kolourpaint org.kde.kmines
  sudo flatpak remote-modify --disable fedora fedora-testing
  ```

## Verify

- `brave-origin` is installed and the default browser.
- Dark theme + Papirus-Dark icons, Konsole in Fish with no menu/toolbar/tab bar.
- `fastfetch`, `htop`, `nvtop`, `nano` on `$PATH`; Discover is gone.
- `flatpak list` shows VLC, Jellyfin, LocalSend, Bazaar, Finamp (installed
  automatically on first boot, may take a minute or two).

## Building

Builds automatically via `.github/workflows/build.yml` on push to `main`.
