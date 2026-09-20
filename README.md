# kinoite-x27

A custom [Fedora Kinoite](https://kinoite.fedoraproject.org/) image, built with
[BlueBuild](https://blue-build.org/), that bakes in the configuration from
[X27/X-Linuxtool](https://codeberg.org/X27/X-Linuxtool)'s `Fedora-Kionite-Setup.sh`
plus the KDE tweaks from `Fedora-PostSetup.sh`.

## What's in the image

- **Brave Origin**, layered straight into the image from Brave's official repo,
  the same way Firefox is normally shipped on stock Kinoite. `firefox` /
  `firefox-langpacks` / `khelpcenter` are removed, and Brave Origin is set as the
  default browser (`/etc/xdg/mimeapps.list`).
- **KDE tweaks**: Breeze Dark + Papirus-Dark icons, Konsole with Fish as its
  default profile and menu bar/toolbar/tab bar hidden, Fish as the default
  shell, plus `fastfetch`, `htop`, `nano`, `papirus-icon-theme`, `pciutils`,
  `lm_sensors` layered in. See **Deploying → step 3** below — these only apply
  automatically to a brand-new user profile.
- **Flatpaks** (Flathub, system-wide): VLC, Jellyfin, LocalSend, Bazaar, Finamp.
  The `default-flatpaks` module also switches the default flatpak remote from
  Fedora's own to Flathub.
- NetworkManager connectivity-check disabled. Automatic updates run via
  `bootc-fetch-apply-updates.timer` (enabled by default on this base image);
  `/etc/rpm-ostreed.conf` sets `AutomaticUpdatePolicy=stage` for any manual
  `rpm-ostree upgrade` runs too.

## Deploying

### 1. Make the package public

The image is private on ghcr.io by default. On GitHub: this repo → **Packages**
(right sidebar) → `kinoite-x27` → package settings → **Change visibility** →
**Public**. Skip this only if you've instead logged in locally with
`sudo podman login ghcr.io` using a token that has `read:packages`.

### 2. Rebase

```
sudo rpm-ostree rebase ostree-unverified-registry:ghcr.io/gamerx27/kinoite-x27:latest
systemctl reboot
```

Confirm it worked after reboot:

```
rpm-ostree status
```

should show `ghcr.io/gamerx27/kinoite-x27:latest` as the booted deployment.

### 3. Apply the KDE tweaks to your account

**This step is required — don't skip it.** The dark theme, Papirus-Dark icons,
Konsole profile, and default shell are all baked into the image as *system-wide
defaults* (`/etc/xdg/kdeglobals`, `/etc/xdg/konsolerc`, `/etc/default/useradd`).
KDE's config system only falls back to those for keys a user's own config
doesn't already set — and if you're rebasing a machine you already used, your
account already has its own `~/.config/kdeglobals` etc. from before, with
those same keys already set to the old values. So the system-wide defaults
never get consulted for your existing account; they'd only apply automatically
to a brand-new user created after this rebase.

To fix that, a helper script is baked into the image at `/usr/bin/x27-apply-tweaks`.
Run it once, as yourself, **without sudo**:

```
x27-apply-tweaks
```

It writes the dark theme, Papirus-Dark icon theme, and Konsole profile
directly into your own `~/.config`/`~/.local/share`, sets Fish as your login
shell, and restarts Plasmashell. Log out and back in afterwards so the shell
and Konsole changes fully apply.

### 4. Verify

- `brave-origin` launches and is the default browser (`xdg-mime query default x-scheme-handler/https`).
- System Settings → Appearance shows Breeze Dark, and icons are Papirus-Dark.
- A new Konsole window opens in Fish with no menu bar/toolbar/tab bar.
- `fish`, `fastfetch`, `htop`, `nano` are all on `$PATH`.
- Flathub apps installed: `flatpak list | grep -E 'VLC|Jellyfin|localsend|Bazaar|finamp'`
  (these install automatically on first boot via the `default-flatpaks` module
  and may take a minute or two after login to appear).

## Building

This repo builds automatically via `.github/workflows/build.yml` once pushed to
GitHub. It publishes to `ghcr.io/gamerx27/kinoite-x27`.
