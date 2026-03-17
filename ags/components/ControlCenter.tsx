import Astal from "gi://Astal?version=3.0"
import Gtk from "gi://Gtk?version=3.0"

/* ---------- Component ---------- */
export function ControlCenter(app: Astal.Application) {

    let windowVisible = true

    /* ---------- Global Sizes / Spacing ---------- */
    const SIZES = {
        windowWidth: 300,
        windowHeight: 520,
        marginLeft: 10,
        spacingMain: 8,
        spacingTile: 6,
        spacingIcon: 4,
        sliderHeight: 20
    }

    /* ---------- Helpers ---------- */
    const icon = (name: string, cls: string) => {
        const i = new Astal.Icon({ icon: name })
        if (cls) i.get_style_context().add_class(cls)
        return i
    }

    const circleBtn = (iconName: string, cls = "") => {
        const b = new Astal.Button()
        b.get_style_context().add_class("circle-btn")
        if (cls) b.get_style_context().add_class(cls)
        b.add(icon(iconName, "circle-icon"))
        return b
    }

    const label = (text: string, cls: string) => {
        const l = new Astal.Label({ label: text, xalign: 0 })
        if (cls) l.get_style_context().add_class(cls)
        return l
    }

    const tile = (cls = "", vertical = true, spacing = SIZES.spacingTile) => {
        const b = new Astal.Box({ vertical, spacing })
        b.get_style_context().add_class("tile")
        if (cls) b.get_style_context().add_class(cls)
        return b
    }

    const slider = (value: number) => {
        const s = new Astal.Slider()
        s.get_style_context().add_class("cc-slider")
        s.min = 0
        s.max = 1
        s.value = value
        s.step = 0.01
        return s
    }

    const makeSliderTile = (title: string, iconStart: string, iconEnd: string, value: number) => {
        const t = tile("tile-slider")
        t.pack_start(label(title, "section-label"), false, false, 0)
        const row = new Astal.Box({ spacing: SIZES.spacingIcon })
        row.pack_start(icon(iconStart, "slider-icon"), false, false, 0)
        row.pack_start(slider(value), true, true, 0)
        row.pack_start(icon(iconEnd, "slider-icon"), false, false, 0)
        t.pack_start(row, false, false, 0)
        return t
    }

    /* ---------- Window ---------- */
    const window = new Astal.Window({
        application: app,
        name: "control-center",
        namespace: "control-center",
        title: "control-center",
        layer: Astal.Layer.OVERLAY,
        anchor: Astal.WindowAnchor.TOP | Astal.WindowAnchor.RIGHT,
        exclusivity: Astal.Exclusivity.EXCLUSIVE,
        keymode: Astal.Keymode.ON_DEMAND,
        visible: windowVisible,
    })

    app.requestHandler = (req, res) => {
        if (req === "toggle") {
            windowVisible = !windowVisible
            window.visible = windowVisible
            res("toggled")
        } else res("unknown")
    }

    window.set_default_size(SIZES.windowWidth, SIZES.windowHeight)
    window.set_resizable(false)

    const root = new Astal.Box({ vertical: true, spacing: SIZES.spacingMain })
    root.get_style_context().add_class("cc-root")
    root.set_margin_start(SIZES.marginLeft)

    /* ---------- Wi-Fi Tile ---------- */
    const wifiTile = tile("tile-wifi")
    const wifiHeader = new Astal.Box({ spacing: SIZES.spacingIcon })

    const wifiIconWrap = new Astal.Box()
    wifiIconWrap.get_style_context().add_class("tile-icon-wrap")
    wifiIconWrap.pack_start(icon("network-wireless-signal-excellent-symbolic", "tile-icon"), true, true, 0)

    const wifiText = new Astal.Box({ vertical: true, spacing: 2 })
    wifiText.pack_start(label("Wi-Fi", "tile-title"), false, false, 0)
    wifiText.pack_start(label("Home", "tile-subtitle"), false, false, 0)

    wifiHeader.pack_start(wifiIconWrap, false, false, 0)
    wifiHeader.pack_start(wifiText, true, true, 0)
    wifiTile.pack_start(wifiHeader, false, false, 0)

    /* ---------- Quick Buttons ---------- */
    const quick = new Astal.Box({ spacing: SIZES.spacingIcon })
    const bluetoothBtn = circleBtn("bluetooth-active-symbolic")
    bluetoothBtn.get_style_context().add_class("active-btn")
    quick.pack_start(bluetoothBtn, false, false, 0)

    const hotspot = circleBtn("network-wireless-hotspot-symbolic")
    hotspot.get_style_context().add_class("active-btn")
    quick.pack_start(hotspot, false, false, 0)

    /* ---------- Music Tile ---------- */
    const music = tile("tile-big tile-music")
    const musicHead = new Astal.Box({ spacing: SIZES.spacingIcon })

    const album = new Astal.Box()
    album.get_style_context().add_class("album-art")
    album.get_style_context().add_class("album-art-mock")

    const musicText = new Astal.Box({ vertical: true, spacing: 2 })
    musicText.pack_start(label("Besties", "music-title"), false, false, 0)
    musicText.pack_start(label("Black Country, New...", "music-subtitle"), false, false, 0)

    musicHead.pack_start(album, false, false, 0)
    musicHead.pack_start(musicText, true, true, 0)

    const controls = new Astal.Box({ spacing: SIZES.spacingIcon, halign: Gtk.Align.CENTER })
    controls.pack_start(icon("media-skip-backward-symbolic", "control-btn"), false, false, 0)
    controls.pack_start(icon("media-playback-start-symbolic", "control-btn"), false, false, 0)
    controls.pack_start(icon("media-skip-forward-symbolic", "control-btn"), false, false, 0)

    music.pack_start(musicHead, false, false, 0)
    music.pack_start(controls, true, true, 0)

    /* ---------- Layout ---------- */
    const left = new Astal.Box({ vertical: true, spacing: SIZES.spacingMain })
    left.pack_start(wifiTile, true, true, 0)
    left.pack_start(quick, true, true, 0)

    const right = new Astal.Box({ vertical: true })
    right.pack_start(music, true, true, 0)

    const topRow = new Astal.Box({ spacing: SIZES.spacingMain })
    topRow.pack_start(left, true, true, 0)
    topRow.pack_start(right, true, true, 0)

    /* ---------- Mid Row ---------- */
    const midRow = new Astal.Box({ spacing: SIZES.spacingMain })

    const focus = new Astal.Box({ spacing: SIZES.spacingIcon })
    focus.get_style_context().add_class("pill")
    focus.pack_start(icon("night-light-symbolic", "pill-icon"), false, false, 0)
    focus.pack_start(label("Focus", ""), false, false, 0)

    const mirrors = new Astal.Box({ spacing: SIZES.spacingIcon })

    const airplaneBtn = circleBtn("airplane-mode-symbolic")
    airplaneBtn.get_style_context().add_class("icon-white")
    mirrors.pack_start(airplaneBtn, false, false, 0)

    const lockBtn = circleBtn("system-lock-screen-symbolic")
    lockBtn.get_style_context().add_class("icon-white")
    mirrors.pack_start(lockBtn, false, false, 0)

    midRow.pack_start(focus, true, true, 0)
    midRow.pack_start(mirrors, false, false, 0)

    /* ---------- Sliders ---------- */
    const displayTile = makeSliderTile("Display", "display-brightness-symbolic", "weather-clear-symbolic", 0.55)
    const soundTile = makeSliderTile("Sound", "audio-volume-low-symbolic", "audio-volume-high-symbolic", 0.45)

    /* ---------- Assemble ---------- */
    root.pack_start(topRow, false, false, 0)
    root.pack_start(midRow, false, false, 0)
    root.pack_start(displayTile, false, false, 0)
    root.pack_start(soundTile, false, false, 0)

    window.add(root)

    return window
}