import Astal from "gi://Astal?version=3.0"
import Gtk from "gi://Gtk?version=3.0"
import GLib from "gi://GLib?version=2.0"

/* ---------- Component ---------- */

// ags run --gtk 3
export function ControlCenter(app: Astal.Application) {

    let windowVisible = true

    const SIZES = {
        windowWidth: 260,
        windowHeight: 450,
        marginLeft: 8,
        spacingMain: 6,
        spacingTile: 4,
        spacingIcon: 3,
        sliderHeight: 18
    }

    const icon = (name: string, cls: string) => {
        const i = new Astal.Icon({ icon: name })
        if (cls) i.get_style_context().add_class(cls)
        return i
    }

const circleBtn = (iconName: string, cls = "") => {
    const b = new Astal.Button()

    b.get_style_context().add_class("circle-btn")
    if (cls) b.get_style_context().add_class(cls)

    // 🔥 force button to center content
    b.set_halign(Gtk.Align.FILL)
    b.set_valign(Gtk.Align.FILL)

    const wrapper = new Astal.Box({
        halign: Gtk.Align.CENTER,
        valign: Gtk.Align.CENTER,
        hexpand: true,   // ✅ THIS is key
        vexpand: true    // ✅ THIS is key
    })

    const i = icon(iconName, "circle-icon")

    wrapper.add(i)
    b.add(wrapper)

    return b
}

const setActive = (btn: any, state: boolean) => {
    if (state) {
        btn.get_style_context().add_class("active-btn")
    } else {
        btn.get_style_context().remove_class("active-btn")
    }
}

    const label = (text: string, cls: string) => {
        const l = new Astal.Label({ label: text, xalign: 0 })

        // enable ellipsis
        l.set_ellipsize(3) // Pango.EllipsizeMode.END
        l.set_max_width_chars(20) // adjust based on your UI
        l.set_single_line_mode(true)

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
        const row = new Astal.Box({ spacing: SIZES.spacingIcon })
        const s = slider(value)

        row.pack_start(icon(iconStart, "slider-icon"), false, false, 0)
        row.pack_start(s, true, true, 0)
        row.pack_start(icon(iconEnd, "slider-icon"), false, false, 0)

        t.pack_start(label(title, "section-label"), false, false, 0)
        t.pack_start(row, false, false, 0)

        return { tile: t, slider: s }
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

    const root = new Astal.Box({ vertical: true, spacing: SIZES.spacingMain })
    root.get_style_context().add_class("cc-root")
    root.set_margin_start(SIZES.marginLeft)

    /* ---------- Wi-Fi ---------- */
    let wifiOn = true
    const wifiTile = tile("tile-wifi")
    setActive(wifiTile, wifiOn) // Initial state

    wifiTile.connect("button-press-event", () => {
        wifiOn = !wifiOn
        GLib.spawn_command_line_async(`nmcli radio wifi ${wifiOn ? "on" : "off"}`)
        setActive(wifiTile, wifiOn)
    })

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

    /* ---------- Quick ---------- */
    const quick = new Astal.Box({ spacing: SIZES.spacingIcon })

    let btOn = true
    const bluetoothBtn = circleBtn("bluetooth-active-symbolic")
    bluetoothBtn.get_style_context().add_class("active-btn")
    bluetoothBtn.connect("clicked", () => {
        btOn = !btOn
        GLib.spawn_command_line_async(`bluetoothctl power ${btOn ? "on" : "off"}`)
        setActive(bluetoothBtn, btOn)
    })

    let hotspotOn = true
    const hotspot = circleBtn("network-wireless-hotspot-symbolic")
    hotspot.get_style_context().add_class("active-btn")

    hotspot.connect("clicked", () => {
        hotspotOn = !hotspotOn
        GLib.spawn_command_line_async(
            hotspotOn ? "nmcli device wifi hotspot" : "nmcli connection down Hotspot"
        )
        setActive(hotspot, hotspotOn)
    })

    quick.pack_start(bluetoothBtn, false, false, 0)
    quick.pack_start(hotspot, false, false, 0)

    /* ---------- Music ---------- */
    const music = tile("tile-big tile-music")
    const musicHead = new Astal.Box({ spacing: SIZES.spacingIcon })
    music.set_size_request(-1, 60)
    const album = new Astal.Box()
    album.get_style_context().add_class("album-art")

    const title = label("", "music-title")

    title.set_ellipsize(3) // END
    title.set_single_line_mode(true)
    title.set_max_width_chars(18)
    const artist = label("", "music-subtitle")


    const musicText = new Astal.Box({ vertical: true, spacing: 2 })
    musicText.pack_start(title, false, false, 0)
    musicText.pack_start(artist, false, false, 0)

    musicHead.pack_start(album, false, false, 0)
    musicHead.pack_start(musicText, true, true, 0)

    const controls = new Astal.Box({ spacing: SIZES.spacingIcon, halign: Gtk.Align.CENTER })

    const makeBtn = (iconName: string, cmd: string) => {
        const b = new Astal.Button()
        b.get_style_context().add_class("control-btn")

        const box = new Astal.Box({
            halign: Gtk.Align.CENTER,
            valign: Gtk.Align.CENTER
        })

        const i = icon(iconName, "control-icon")
        box.add(i)

        b.add(box)

        b.connect("clicked", () => GLib.spawn_command_line_async(cmd))
        return b
    }

    controls.pack_start(makeBtn("media-skip-backward-symbolic", "playerctl previous"), false, false, 0)
    const playBtn = new Astal.Button()
    playBtn.get_style_context().add_class("control-btn")

    const box = new Astal.Box({
        halign: Gtk.Align.CENTER,
        valign: Gtk.Align.CENTER
    })

    const playIcon = icon("media-playback-start-symbolic", "control-icon")
    box.add(playIcon)

    playBtn.add(box)

    playBtn.connect("clicked", () => {
        GLib.spawn_command_line_async("playerctl play-pause")
    })

    controls.pack_start(playBtn, false, false, 0)
    controls.pack_start(makeBtn("media-skip-forward-symbolic", "playerctl next"), false, false, 0)

    music.pack_start(musicHead, false, false, 0)
    music.pack_start(controls, true, true, 0)
    const decode = (bytes: any) => {
        try {
            if (!bytes) return ""
            return new TextDecoder().decode(bytes).trim()
        } catch {
            return ""
        }
    }
    /* Spotify Cover + Title */
    const updateMusic = () => {
        try {
            const [_, t] = GLib.spawn_command_line_sync("playerctl metadata title")
            const [__, a] = GLib.spawn_command_line_sync("playerctl metadata artist")
            const [___, c] = GLib.spawn_command_line_sync("playerctl metadata mpris:artUrl")

            const titleStr = decode(t)
            const artistStr = decode(a)
            const coverStr = decode(c)

            if (titleStr) title.label = titleStr
            if (artistStr) artist.label = artistStr

            if (!coverStr) return

            let path = ""

            if (coverStr.startsWith("http")) {
                path = "/tmp/ags-cover.jpg"
                GLib.spawn_command_line_async(`curl -s "${coverStr}" -o ${path}`)
            } else if (coverStr.startsWith("file://")) {
                path = coverStr.replace("file://", "")
            } else return

            const css = `
        .album-dynamic {
            background-image: url("${path}");
            background-size: cover;
            background-position: center;
        }`

            const provider = new Gtk.CssProvider()
            provider.load_from_data(css)

            album.get_style_context().add_class("album-dynamic")
            album.get_style_context().add_provider(
                provider,
                Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION
            )

        } catch (e) {
            print("Music error:", e)
        }
    }
    const updatePlaybackState = () => {
        try {
            const [_, s] = GLib.spawn_command_line_sync("playerctl status")
            const status = decode(s)

            if (status === "Playing") {
                playIcon.icon = "media-playback-pause-symbolic"
            } else {
                playIcon.icon = "media-playback-start-symbolic"
            }

        } catch { }
    }
    GLib.timeout_add(GLib.PRIORITY_DEFAULT, 1000, () => {
        updateMusic()
        updatePlaybackState()
        return true
    })

    /* ---------- Focus (Do Not Disturb) ---------- */
    const focus = new Astal.Box({ spacing: SIZES.spacingIcon })
    focus.get_style_context().add_class("pill")

    let focusOn = false
    focus.connect("button-press-event", () => {
        focusOn = !focusOn
        GLib.spawn_command_line_async(`swaync-client -d ${focusOn}`)
        setActive(focus, focusOn)
    })

    focus.pack_start(icon("night-light-symbolic", "pill-icon"), false, false, 0)
    focus.pack_start(label("Focus", "focus-text"), false, false, 0)

    /* ---------- Airplane + Lock ---------- */
    const mirrors = new Astal.Box({ spacing: SIZES.spacingIcon })

    let airplane = false
    const airplaneBtn = circleBtn("airplane-mode-symbolic")
    airplaneBtn.connect("clicked", () => {
        airplane = !airplane
        GLib.spawn_command_line_async(`nmcli radio all ${airplane ? "off" : "on"}`)
        setActive(airplaneBtn, airplane)
    })

    const lockBtn = circleBtn("system-lock-screen-symbolic")
    lockBtn.connect("clicked", () => {
        GLib.spawn_command_line_async("loginctl lock-session")
    })

    mirrors.pack_start(airplaneBtn, false, false, 0)
    mirrors.pack_start(lockBtn, false, false, 0)

    const midRow = new Astal.Box({ spacing: SIZES.spacingMain })
    midRow.pack_start(focus, true, true, 0)
    midRow.pack_start(mirrors, false, false, 0)

    /* ---------- Sliders ---------- */
    const display = makeSliderTile("Display", "display-brightness-symbolic", "weather-clear-symbolic", 0.55)
    const sound = makeSliderTile("Sound", "audio-volume-low-symbolic", "audio-volume-high-symbolic", 0.45)

    display.slider.connect("value-changed", s =>
        GLib.spawn_command_line_async(`brightnessctl set ${Math.floor(s.value * 100)}%`)
    )

    sound.slider.connect("value-changed", s =>
        GLib.spawn_command_line_async(`pamixer --set-volume ${Math.floor(s.value * 100)}`)
    )

    /* ---------- Layout ---------- */
    const left = new Astal.Box({ vertical: true, spacing: SIZES.spacingMain })
    left.pack_start(wifiTile, true, true, 0)
    left.pack_start(quick, true, true, 0)

    const right = new Astal.Box({ vertical: true })
    right.pack_start(music, true, true, 0)

    const topRow = new Astal.Box({ spacing: SIZES.spacingMain })
    topRow.pack_start(left, true, true, 0)
    topRow.pack_start(right, true, true, 0)

    root.pack_start(topRow, false, false, 0)
    root.pack_start(midRow, false, false, 0)
    root.pack_start(display.tile, false, false, 0)
    root.pack_start(sound.tile, false, false, 0)

    window.add(root)

    return window
}