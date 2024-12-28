## Random wallpaper
Set random wallpaper for GNOME desktop environment

### Setup
```bash
systemctl --user daemon-reload
systemctl --user start randombg.service
systemctl --user enable --now randombg.timer
```

### Debug
```bash
systemctl --user status randombg.timer
systemctl --user status randombg.service
journalctl --user -u randombg.timer
journalctl --user -u randombg.service
journalctl --user --unit randombg.service --follow
```

### Disable
```bash
systemctl --user stop randombg.timer
systemctl --user disable randombg.timer
systemctl --user stop randombg.service
systemctl --user disable randombg.service
```
