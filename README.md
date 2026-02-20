# Hyprland Dotfiles (Arch Linux)

Personal desktop config for a transparent, dark, Arch-blue Hyprland setup.
A minimal, performance-focused Hyprland configuration designed for speed, simplicity, and modern security.
## Stack
- WM: `Hyprland`
- Bar: `Waybar`
- Launcher: `Wofi`
- OSD: `swayosd`
- Terminal: `kitty`
- File manager: `nautilus`
- Lock screen: `hyprlock`
- Display manager (boot login): `SDDM` (theme: `maya`)

## Main Features
- Transparent UI across Hyprland windows and core components.
- Themed Waybar, Wofi, swayosd, Kitty, Nautilus.
- Custom lock flow with `SUPER + L`.
- Screenshot workflow with copy-to-clipboard and notifications.
- Random wallpaper changer keybind.
- Battery low notifier daemon.
- Bluetooth details module in Waybar with click actions.

## Repository Layout
- `hypr/hyprland.conf` - main Hyprland config and keybinds
- `hypr/hyprlock.conf` - lockscreen UI
- `hypr/scripts/` - helper scripts:
  - `lock-screen.sh`
  - `battery-alert.sh`
  - `screenshot-copy.sh`
  - `wallpaper-random.sh`
  - `polkit-agent.sh`
  - `fingerprint-fallback-setup.sh`
  - `apply-hyprlock-pam.sh`
  - `apply-sddm-main-screen.sh`
- `waybar/config.jsonc`, `waybar/style.css`, `waybar/scripts/bluetooth-status.sh`
- `wofi/style.css`
- `swayosd/style.css`
- `kitty/kitty.conf`
- `gtk-3.0/gtk.css`, `gtk-4.0/gtk.css` (Nautilus/GTK styling)

## Keybinds (Important)
- `SUPER + SPACE` - app launcher (Wofi)
- `SUPER + B` - toggle/restart Waybar
- `SUPER + W` - random wallpaper
- `SUPER + S` - full screenshot to clipboard
- `SUPER + L` - lock screen

## Fingerprint + Password Fallback
This repo includes scripts to apply fingerprint-first auth with password fallback:
- `hypr/scripts/fingerprint-fallback-setup.sh`
- `hypr/scripts/apply-hyprlock-pam.sh`

Run (with sudo) when needed:
```bash
sudo ~/.config/hypr/scripts/fingerprint-fallback-setup.sh $USER
sudo ~/.config/hypr/scripts/apply-hyprlock-pam.sh
```

## SDDM Main Login Screen Theming
Apply custom boot/login screen theme:
```bash
sudo ~/.config/hypr/scripts/apply-sddm-main-screen.sh
```

## Dependencies
Install core packages (adjust as needed):
```bash
sudo pacman -S hyprland hyprlock hyprpaper waybar wofi kitty nautilus \
  swayosd grim slurp wl-clipboard brightnessctl playerctl \
  acpi libnotify bluez bluez-utils fprintd sddm
```

## Apply / Reload
- Reload Hyprland:
```bash
hyprctl reload
```
- Restart Waybar:
```bash
pkill waybar && waybar &
```
- Restart Nautilus:
```bash
nautilus -q
```

## Notes
- Some scripts modify system files under `/etc` and must be run with `sudo`.
- Test changes in a terminal before rebooting.
- Keep backups of PAM and display manager configs.
