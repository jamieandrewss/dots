------------------
--- AUTO START ---
------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user start xdg-desktop-portal-hyprland")
    hl.exec_cmd("systemctl --user start xdg-desktop-portal-gtk")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")

    hl.exec_cmd("gsettings set org.gnome.desktop.interface cursor-theme 'phinger-cursors-dark'")
end)
