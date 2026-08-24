//@ pragma UseQApplication

import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

import qs.Common
import qs.Modules
import qs.Popups

ShellRoot {
    id: root
    
    // Main Dynamic Island
    Island { id: island }

    // Popups (e.g. Notifications)
    NotificationList { id: notification }
}