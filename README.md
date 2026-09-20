# kinoite-x27

A custom [Fedora Kinoite](https://kinoite.fedoraproject.org/) image, built with
[BlueBuild](https://blue-build.org/), that bakes in the configuration from
[X27/X-Linuxtool](https://codeberg.org/X27/X-Linuxtool)'s `Fedora-Kionite-Setup.sh`
plus the KDE tweaks from `Fedora-PostSetup.sh`, so a fresh rebase already has
everything applied instead of needing a post-install script run.

## What's in the image

- **Brave Origin**, layered as a native `rpm-ostree` package (Brave's official repo),
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
- NetworkManager connectivity-check disabled, and `rpm-ostree` automatic staged
  updates enabled (`rpm-ostreed-automatic.timer`).

## One-time manual step after rebasing an *existing* install

`/etc/default/useradd` only affects accounts created after the rebase. If you're
rebasing a machine that already has your user account on it, run this once:

```
chsh -s /usr/bin/fish "$USER"
```

## Building

This repo builds automatically via `.github/workflows/build.yml` once pushed to
GitHub (requires `SIGNING_SECRET` set in the repo's Actions secrets — see
"Signing" below). It publishes to `ghcr.io/<your-github-user>/kinoite-x27`.

## Signing

A cosign/sigstore keypair has already been generated locally (`cosign.pub` is
committed; `cosign.private` is git-ignored — **do not commit it**). Before
pushing, add its contents as a GitHub Actions secret named `SIGNING_SECRET`:

```
gh secret set SIGNING_SECRET < cosign.private
```

## Rebasing onto this image

First rebase unsigned to pull the image, then switch to verified/signed pulls:

```
rpm-ostree rebase ostree-unverified-registry:ghcr.io/<your-github-user>/kinoite-x27:latest
systemctl reboot
```

After reboot, switch to signature-verified pulls going forward:

```
sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/<your-github-user>/kinoite-x27:latest
```
