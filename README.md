# kinoite-x27

Custom Fedora Kinoite, built with [BlueBuild](https://blue-build.org/).
Recipe: [`recipes/recipe.yml`](recipes/recipe.yml) (also
[`recipes/recipe-lts.yml`](recipes/recipe-lts.yml) for the LTS-kernel variant)
Image: `ghcr.io/gamerx27/kinoite-x27` (LTS: `ghcr.io/gamerx27/kinoite-x27-lts`)

## What's in it

- Brave Origin (native package, set as default browser), debranded/hardened
  further at build time ([make_brave_great_again.sh](https://codeberg.org/X27/X-Linuxtool/src/branch/main/Desktop/Linux-Desktop/Browser/make_brave_great_again.sh))
- [X-Linuxtool](https://codeberg.org/X27/X-Linuxtool) installed as `x-linuxtool`
- Removed: Firefox, KHelpCenter, Discover
- Dark theme, Papirus-Dark icons, Konsole on Fish, Fish as default shell,
  fastfetch banner on new interactive shells
- fastfetch, htop, nvtop, nano, pciutils, lm_sensors, topgrade
- NetworkManager connectivity check off, `NetworkManager-config-connectivity-fedora` removed
- Auto-updates off — `bootc-fetch-apply-updates.timer` is masked; a weekly
  desktop notification reminds you to run `topgrade` instead (see below)
- `LC_TIME=C.UTF-8`, Plymouth pinned to Fedora's `bgrt` boot theme
- CachyOS kernel (BORE scheduler) instead of stock Fedora — see caveats below
  (an LTS-kernel variant is also published, see below)
- `/etc/os-release` stamped with the build date each week

## Install

**Fresh machine, no OS yet:** a custom installer ISO with everything in this
repo already baked in can be built on demand from
[the `build-iso` workflow](.github/workflows/iso.yml) (Actions →
**build-iso** → **Run workflow**, then grab it from that run's
**Artifacts** section once it finishes — needs a GitHub login, expires after
60 days). It's not a GitHub Release: the ISO comes out over 2 GiB, which is
GitHub's hard size limit per Release asset. Flash it (Fedora Media Writer
works) and install like any other Fedora ISO.

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

**Want the LTS kernel instead of CachyOS's rolling one?** Use
`kinoite-x27-lts` in place of `kinoite-x27` in the commands above.

## Update

Auto-updates are off. Run this yourself (a desktop notification reminds you
weekly):

```
topgrade
```

`topgrade` updates the system image (via `rpm-ostree`/`bootc`), Flatpaks, and
more, all in one command. To update just the system image and reboot:

```
sudo rpm-ostree upgrade
systemctl reboot
```

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

`kinoite-x27` ships the [CachyOS kernel](https://copr.fedorainfracloud.org/coprs/bieszczaders/kernel-cachyos/)
(BORE scheduler); `kinoite-x27-lts` ships the
[CachyOS LTS kernel](https://copr.fedorainfracloud.org/coprs/bieszczaders/kernel-cachyos-lts/)
instead — same vendor, a longterm-stable upstream kernel rather than the
rolling one. Both instead of stock Fedora's kernel.

- **CPU must support x86_64-v3** (any Zen-family AMD, Haswell+ Intel), for
  either variant. Installing on an unsupported CPU produces an unbootable
  system. Check with:
  `/lib64/ld-linux-x86-64.so.2 --help | grep "(supported, searched)"`
- **Unsigned.** If Secure Boot is on, either turn it off or sign the kernel
  yourself with `sbsigntools`/`mokutil` (both included in the image) — see the
  copr page's Secure Boot instructions.

## Build

Pushes to `main` build and publish automatically via GitHub Actions, which
also rebuilds weekly (Sundays) to pick up upstream Kinoite/Brave/kernel
updates. Each weekly build stamps that date into `/etc/os-release`
(`PRETTY_NAME`/`BUILD_ID`) so you can tell which build you're on.
