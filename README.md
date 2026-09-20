# kinoite-x27

A custom [Fedora Kinoite](https://kinoite.fedoraproject.org/) image, built with
[BlueBuild](https://blue-build.org/), that bakes in the configuration from
[X27/X-Linuxtool](https://codeberg.org/X27/X-Linuxtool)'s `Fedora-Kionite-Setup.sh`
plus the KDE tweaks from `Fedora-PostSetup.sh`, so a fresh rebase already has
everything applied instead of needing a post-install script run.

## What's in the image

- **Brave Origin**, layered straight into the image from Brave's official repo,
  the same way Firefox is normally shipped on stock Kinoite. `firefox` /
  `firefox-langpacks` / `khelpcenter` are removed, and Brave Origin is set as the
  default browser (`/etc/xdg/mimeapps.list`).
- **KDE tweaks**: Breeze Dark + Papirus-Dark icons system-wide (`/etc/xdg/kdeglobals`),
  Konsole with Fish as its default profile and menu bar/toolbar/tab bar hidden
  (`/etc/xdg/konsolerc`, `/usr/share/konsole/Fish.profile`), Fish set as the default
  shell for new accounts (`/etc/default/useradd`), plus `fastfetch`, `htop`, `nano`,
  `papirus-icon-theme`, `pciutils`, `lm_sensors` layered in.
- **Flatpaks** (Flathub, system-wide): VLC, Jellyfin, LocalSend, Bazaar, Finamp.
  The `default-flatpaks` module also switches the default flatpak remote from
  Fedora's own to Flathub.
- NetworkManager connectivity-check disabled. Automatic updates run via
  `bootc-fetch-apply-updates.timer` (enabled by default on this base image);
  `/etc/rpm-ostreed.conf` sets `AutomaticUpdatePolicy=stage` for any manual
  `rpm-ostree upgrade` runs too.

## One-time manual step after rebasing an *existing* install

`/etc/default/useradd` only affects accounts created after the rebase. If you're
rebasing a machine that already has your user account on it, run this once:

```
chsh -s /usr/bin/fish "$USER"
```

## Building

This repo builds automatically via `.github/workflows/build.yml` once pushed to
GitHub. It publishes to `ghcr.io/gamerx27/kinoite-x27`.

## Rebasing onto this image

The package must be **public** on ghcr.io first (Package settings → Change
visibility → Public), otherwise the pull will be rejected as unauthorized.

```
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/gamerx27/kinoite-x27:latest
systemctl reboot
```
