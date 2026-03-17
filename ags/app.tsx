import Astal from "gi://Astal?version=3.0"
import GLib from "gi://GLib?version=2.0"
import { ControlCenter } from "./components/ControlCenter"

const app = new Astal.Application()

const configRoot =
    GLib.getenv("XDG_CONFIG_HOME") ??
    GLib.build_filenamev([GLib.get_home_dir(), ".config"])

const cssPath = GLib.build_filenamev([configRoot, "ags", "style.css"])

app.connect("startup", () => app.apply_css(cssPath, false))

app.connect("activate", () => {
    const cc = ControlCenter(app)
    cc.show_all()
})

app.run([])