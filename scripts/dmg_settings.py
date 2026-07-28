# dmgbuild settings for the Termina installer image.
# Invoked by scripts/make-dmg.sh:
#   dmgbuild -s dmg_settings.py -D app=... -D background=... -D icns=... "Termina" out.dmg

app = defines.get("app")  # noqa: F821

volume_name = "Termina"
format = "UDZO"

files = [app]
symlinks = {"Applications": "/Applications"}

icon = defines.get("icns")  # noqa: F821  (volume icon)
badge_icon = None

background = defines.get("background")  # noqa: F821

show_status_bar = False
show_tab_view = False
show_toolbar = False
show_pathbar = False
show_sidebar = False

window_rect = ((200, 140), (660, 400))
default_view = "icon-view"
icon_size = 128
text_size = 13

# Icon centers in window coordinates (origin top-left).
icon_locations = {
    "Termina.app": (165, 190),
    "Applications": (495, 190),
}
