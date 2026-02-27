# HyperLight Hyprland Dotfiles (Arch Linux)

Personal Hyprland rice focused on dark glass styling, practical keybinds, lock/suspend flow, screenshots, recording, wallpaper tools, and Waybar modules.

## 1. What this includes
- WM: `hyprland`
- Bar: `waybar`
- Launcher: `wofi`
- OSD: `swayosd`
- Notification center: `swaync`
- Terminal: `kitty`
- File manager: `thunar`
- Lock screen: `hyprlock` + `hypridle`
- Wallpaper engine: `hyprpaper`

## 2. Install packages
```bash
sudo pacman -S --needed \
  hyprland hyprlock hypridle hyprpaper xdg-desktop-portal-hyprland \
  waybar wofi kitty thunar tumbler ffmpegthumbnailer \
  swayosd swaynotificationcenter dunst libnotify \
  grim slurp wl-clipboard wf-recorder \
  pipewire wireplumber pipewire-pulse pavucontrol \
  brightnessctl playerctl acpi bluez bluez-utils blueman \
  polkit-gnome networkmanager
```

Optional packages used by some scripts:
```bash
sudo pacman -S --needed sddm fprintd qt6ct libcanberra
```

## 3. Copy configs to your laptop
Clone this repo anywhere, then copy only the needed folders:
```bash
mkdir -p ~/.config
cp -r hypr waybar wofi swayosd swaync dunst kitty Thunar gtk-4.0 systemd ~/.config/
```

Make sure scripts are executable:
```bash
chmod +x ~/.config/hypr/scripts/*.sh ~/.config/waybar/scripts/*.sh
```

## 4. Replace hardcoded username paths
Some files use `/home/jegan/...`. Replace with your real `$HOME`:
```bash
for d in hypr waybar systemd kitty; do
  find "$HOME/.config/$d" -type f -print0 2>/dev/null | xargs -0 -r sed -i "s|/home/jegan|$HOME|g"
done
```

## 5. Enable required services
```bash
sudo systemctl enable --now NetworkManager.service
sudo systemctl enable --now bluetooth.service
systemctl --user daemon-reload
systemctl --user enable --now hypr-battery-alert.service
```

If you want SDDM login manager:
```bash
sudo systemctl enable sddm.service
sudo ~/.config/hypr/scripts/apply-sddm-main-screen.sh
```

## 6. Wallpaper folder
Put wallpapers in one of these folders (first existing one is used):
- `~/Pictures/Wallpapers`
- `~/Pictures/wallpapers`
- `~/Pictures`
- `~/pictures/wallpapers`
- `~/pictures/Wallpapers`
- `~/pictures`

## 7. Start Hyprland
- From display manager: choose `Hyprland`.
- From TTY:
```bash
exec Hyprland
```

## 8. Important keybinds
- `SUPER + RETURN`: open Kitty
- `SUPER + E`: open Thunar
- `SUPER + SPACE`: app launcher
- `SUPER + W`: random wallpaper
- `SUPER + SHIFT + W`: wallpaper picker (preview list)
- `SUPER + L`: lock and auto-suspend after 30s if still locked
- `SUPER + SHIFT + R`: start/stop screen recording
- `SUPER + S`: screenshot to clipboard
- `SUPER + SHIFT + B`: open Bluetooth manager
- `SUPER + B`: toggle Waybar

## 9. Optional security setup
Fingerprint + password fallback for `hyprlock`:
```bash
sudo ~/.config/hypr/scripts/fingerprint-fallback-setup.sh "$USER"
sudo ~/.config/hypr/scripts/apply-hyprlock-pam.sh
```

Laptop lid suspend policy:
```bash
sudo ~/.config/hypr/scripts/apply-logind-lid-policy.sh
```

## 10. Reload after edits
```bash
hyprctl reload
pkill waybar && waybar &
pkill swaync && swaync &
```

## 11. Main directories
- `hypr/` - Hyprland, hyprlock, hypridle, scripts
- `waybar/` - bar modules and styles
- `wofi/` - launcher and wallpaper picker styles
- `swayosd/` - volume/brightness OSD style
- `swaync/` - notifications + control center
- `kitty/` - terminal config + long-command notifications
- `Thunar/`, `gtk-4.0/` - file manager behavior + GTK tweaks

## Notes
- Scripts that change `/etc` require `sudo`.
- Keep backups before changing PAM or display manager config.
- If something does not apply, restart your session once after install.
