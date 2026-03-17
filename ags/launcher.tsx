import Astal from "gi://Astal?version=3.0"
import GLib from "gi://GLib?version=2.0"

const app = new Astal.Application()

const configRoot =
    GLib.getenv("XDG_CONFIG_HOME") ??
    GLib.build_filenamev([GLib.get_home_dir(), ".config"])
const cssPath = GLib.build_filenamev([configRoot, "ags", "style.css"])

app.connect("startup", () => {
    app.apply_css(cssPath, false)
})

app.connect("activate", () => {
    const window = new Astal.Window({
        application: app,
        title: "Launcher",
    })

    window.set_default_size(240, 360)
    window.set_resizable(false)

    const card = new Astal.Box({
        vertical: true,
        spacing: 10,
    })
    card.get_style_context().add_class("glass-card")

    const title = new Astal.Label({ label: "Launcher", xalign: 0 })
    title.get_style_context().add_class("section-label")

    card.pack_start(title, false, false, 0)

    const root = new Astal.CenterBox()
    root.get_style_context().add_class("launcher-root")
    root.center_widget = card

    window.add(root)
    window.show_all()
})

app.run([])
