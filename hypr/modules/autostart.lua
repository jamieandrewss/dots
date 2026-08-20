------------------
--- AUTO START ---
------------------

hl.on("hyprland.start", function()
    hl.exec_cmd("systemctl --user start xdg-desktop-portal-hyprland")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
end)
