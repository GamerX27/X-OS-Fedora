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
GitHub (requires `SIGNING_SECRET` set in the repo's Actions secrets — see
"Signing" below). It publishes to `ghcr.io/gamerx27/kinoite-x27`.

## Signing

A cosign/sigstore keypair has already been generated locally (`cosign.pub` is
committed; `cosign.private` is git-ignored — **do not commit it**). Before
pushing, add its contents as a GitHub Actions secret named `SIGNING_SECRET`:

```
gh secret set SIGNING_SECRET < cosign.private
```

## Rebasing onto this image

The package must be **public** on ghcr.io first (Package settings → Change
visibility → Public), otherwise the pull will be rejected as unauthorized.

Rebase unsigned to pull the image:

```
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/gamerx27/kinoite-x27:latest
systemctl reboot
```

### Optional: switch to signature-verified pulls

Running `ostree-image-signed:docker://...` directly will fail with
`containers-policy.json specifies a default of insecureAcceptAnything;
refusing usage` — the system's default container policy doesn't know how to
verify this image's signature yet. Tell it how, using the `cosign.pub` key
committed in this repo, **before** running the signed rebase:

```
sudo mkdir -p /etc/pki/containers
sudo curl -fsSL -o /etc/pki/containers/kinoite-x27.pub \
  https://raw.githubusercontent.com/GamerX27/X27-Kionite/main/cosign.pub

sudo python3 -c "
import json
path = '/etc/containers/policy.json'
with open(path) as f:
    policy = json.load(f)
policy.setdefault('transports', {}).setdefault('docker', {})['ghcr.io/gamerx27/kinoite-x27'] = [
    {'type': 'sigstoreSigned', 'keyPath': '/etc/pki/containers/kinoite-x27.pub'}
]
with open(path, 'w') as f:
    json.dump(policy, f, indent=2)
"

sudo rpm-ostree rebase ostree-image-signed:docker://ghcr.io/gamerx27/kinoite-x27:latest
```
