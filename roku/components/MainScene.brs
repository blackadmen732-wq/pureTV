' PureTV: one scene, plain state. Home tiles, a shared page layout, saved theme/motion.

function themes() as object
    return {
        midnight: {
            name: "Midnight", bg: "0x101923FF", surface: "0x192632FF", text: "0xF2F5F7FF",
            muted: "0xC3D2DEFF", focus: "0xEAF6FFFF", selected: "0x293A4CFF",
            tiles: ["0x34506AFF", "0x36605AFF", "0x5F5170FF", "0x37475AFF", "0x485560FF"]
        },
        graphite: {
            name: "Graphite", bg: "0x161718FF", surface: "0x222326FF", text: "0xF2F2F2FF",
            muted: "0xC8CACDFF", focus: "0xFFFFFFFF", selected: "0x34363BFF",
            tiles: ["0x3D4148FF", "0x3A443FFF", "0x47404CFF", "0x363A40FF", "0x44474CFF"]
        }
    }
end function

function favorites() as object
    return [
        { label: "Movies", action: "library", hint: "Your own movies" },
        { label: "Music", action: "music", hint: "Spotify, Pandora and radio" },
        { label: "Photos", action: "library", hint: "Your own photos" },
        { label: "TV apps", action: "apps", hint: "Open Netflix, YouTube and more" },
        { label: "Settings", action: "settings", hint: "Theme, motion and device" }
    ]
end function

' Streaming apps the TV apps page can open. Ids come from Roku; edit the list to match your TV.
function streamingApps() as object
    return [
        ["YouTube", "837"], ["Netflix", "12"], ["Prime Video", "13"], ["Hulu", "2285"], ["Peacock", "593099"],
        ["Pluto TV", "74519"], ["Tubi", "41468"], ["Plex", "13535"], ["ESPN", "34376"], ["Media Player", "2213"]
    ]
end function

' Music apps for the Music tile. Check ids on your TV with: tools/tv.sh apps
function musicApps() as object
    return [["Spotify", "22297"], ["Pandora", "28"], ["iHeartRadio", "20197"], ["TuneIn", "1453"], ["Vevo", "20445"]]
end function

sub init()
    m.reg = CreateObject("roRegistrySection", "PureTV")
    m.prefs = {
        theme: readPref("theme", "midnight", ["midnight", "graphite"]),
        motion: readPref("motion", "standard", ["standard", "reduced"])
    }
    m.favs = favorites()
    m.screen = "home"
    m.focus = 0
    m.row = 0
    m.appIndex = 0
    m.gridPage = ""
    m.gridApps = []
    m.launcher = CreateObject("roSGNode", "Launcher")

    buildTiles()
    m.clockTimer = m.top.findNode("clockTimer")
    m.clockTimer.observeField("fire", "updateClock")
    m.clockTimer.control = "start"
    updateClock()

    applyTheme()
    showHome()
    m.top.setFocus(true)
end sub

' ---------- preferences ----------

function readPref(key as string, fallback as string, allowed as object) as string
    value = m.reg.Read(key)
    for each ok in allowed
        if value = ok then return value
    end for
    return fallback ' missing or malformed: use the default
end function

sub savePref(key as string, value as string)
    m.prefs[key] = value
    m.reg.Write(key, value)
    m.reg.Flush()
end sub

' ---------- building ----------

sub buildTiles()
    tiles = m.top.findNode("tiles")
    m.tileNodes = []
    for i = 0 to m.favs.Count() - 1
        g = tiles.createChild("Group")
        g.id = "tile" + i.ToStr()
        g.translation = [90 + 352 * i, 600]
        g.scaleRotateCenter = [166, 96]

        ring = g.createChild("Poster")
        ring.uri = "pkg:/images/tile_ring.png"
        ring.width = 348
        ring.height = 208
        ring.translation = [-8, -8]
        ring.visible = false

        face = g.createChild("Poster")
        face.uri = "pkg:/images/tile.png"
        face.width = 332
        face.height = 192

        lbl = g.createChild("Label")
        lbl.text = m.favs[i].label
        lbl.translation = [28, 76]
        font = CreateObject("roSGNode", "Font")
        font.uri = "font:BoldSystemFontFile"
        font.size = 32
        lbl.font = font

        anim = g.createChild("Animation")
        anim.duration = 0.15
        anim.easeFunction = "outQuad"
        interp = anim.createChild("Vector2DFieldInterpolator")
        interp.key = [0.0, 1.0]
        interp.keyValue = [[1.0, 1.0], [1.04, 1.04]]
        interp.fieldToInterp = g.id + ".scale"

        m.tileNodes.Push({ group: g, ring: ring, face: face, label: lbl, anim: anim, interp: interp })
    end for
end sub

sub applyTheme()
    t = themes()[m.prefs.theme]
    m.t = t
    m.top.backgroundColor = t.bg
    m.top.backgroundURI = ""
    m.top.findNode("bg").color = t.bg
    for each id in ["wordmark", "clock", "heroTitle", "favHeading", "focusLabel", "pageTitle", "pageBody"]
        m.top.findNode(id).color = t.text
    end for
    for each id in ["heroSub", "homeHint", "pageSub", "pageHint"]
        m.top.findNode(id).color = t.muted
    end for
    for i = 0 to m.tileNodes.Count() - 1
        n = m.tileNodes[i]
        n.face.blendColor = t.tiles[i]
        n.ring.blendColor = t.focus
        n.label.color = t.text
    end for
    updateTabs()
end sub

sub updateTabs()
    active = "tabHome"
    if m.screen = "page" and m.page = "library" then active = "tabLibrary"
    if m.screen = "page" and m.page = "settings" then active = "tabSettings"
    for each id in ["tabHome", "tabLibrary", "tabSettings"]
        if id = active then m.top.findNode(id).color = m.t.text else m.top.findNode(id).color = m.t.muted
    end for
end sub

sub updateClock()
    now = CreateObject("roDateTime")
    now.ToLocalTime()
    h = now.GetHours()
    suffix = "AM"
    if h >= 12 then suffix = "PM"
    h = h mod 12
    if h = 0 then h = 12
    mins = now.GetMinutes().ToStr()
    if Len(mins) = 1 then mins = "0" + mins
    m.top.findNode("clock").text = h.ToStr() + ":" + mins + " " + suffix
end sub

' ---------- home ----------

sub showHome()
    m.screen = "home"
    m.top.findNode("home").visible = true
    m.top.findNode("page").visible = false
    for i = 0 to m.tileNodes.Count() - 1
        setTileFocus(i, i = m.focus, false)
    end for
    m.top.findNode("focusLabel").text = m.favs[m.focus].label
    updateTabs()
end sub

sub setTileFocus(i as integer, isFocused as boolean, animate as boolean)
    n = m.tileNodes[i]
    n.ring.visible = isFocused
    target = 1.0
    if isFocused then target = 1.04
    n.anim.control = "stop"
    if animate and m.prefs.motion = "standard"
        ' Start from the current scale so a fast key press retargets instead of jumping.
        n.interp.keyValue = [n.group.scale, [target, target]]
        if isFocused then n.anim.duration = 0.15 else n.anim.duration = 0.12
        n.anim.control = "start"
    else
        n.group.scale = [target, target]
    end if
end sub

sub moveTile(delta as integer)
    nextFocus = m.focus + delta
    if nextFocus < 0 or nextFocus >= m.tileNodes.Count() then return ' no wrap at the edges
    setTileFocus(m.focus, false, true)
    m.focus = nextFocus
    setTileFocus(m.focus, true, true)
    m.top.findNode("focusLabel").text = m.favs[m.focus].label
end sub

' ---------- pages ----------

sub showPage(kind as string)
    m.screen = "page"
    m.page = kind
    m.top.findNode("home").visible = false
    m.top.findNode("page").visible = true
    rows = m.top.findNode("rows")
    rows.removeChildrenIndex(rows.getChildCount(), 0)
    body = ""
    hint = "Back  Return"
    sub_ = ""

    if kind = "library"
        title = "Library"
        sub_ = "Only what you add. Nothing else."
        body = "No personal media added yet." + Chr(10) + Chr(10) + "Movies, Music and Photos will show here once you add your own files."
    else if kind = "apps" or kind = "music"
        if kind = "music"
            title = "Music"
            m.gridApps = musicApps()
        else
            title = "TV apps"
            m.gridApps = streamingApps()
        end if
        if m.gridPage <> kind then m.appIndex = 0
        m.gridPage = kind
        sub_ = "Pick an app. Back on the remote returns here."
        hint = "OK  Open     •     Back  Return"
        buildAppGrid()
    else if kind = "help"
        title = "Help"
        sub_ = "How PureTV works"
        body = "Open PureTV: Roku Home, then the PureTV tile." + Chr(10) + "Leave PureTV: press Home or Back on the remote." + Chr(10) + "Reinstall or remove: use the Roku developer page in Chrome on your Chromebook." + Chr(10) + "Streaming and music apps: open them from the TV apps and Music tiles."
    else
        title = "Settings"
        sub_ = "Make this television yours."
        hint = "OK  Change     •     Back  Return"
        buildSettingsRows()
    end if

    m.top.findNode("pageTitle").text = title
    m.top.findNode("pageSub").text = sub_
    m.top.findNode("pageBody").text = body
    m.top.findNode("pageBody").visible = (kind = "library" or kind = "help")
    m.top.findNode("pageHint").text = hint
    updateTabs()
end sub

function settingsRows() as object
    info = CreateObject("roDeviceInfo")
    os = info.GetOSVersion()
    device = info.GetModel() + "  •  OS " + os.major + "." + os.minor
    motion = "Standard"
    if m.prefs.motion = "reduced" then motion = "Reduced"
    return [
        { label: "Appearance", value: m.t.name, key: "theme" },
        { label: "Motion", value: motion, key: "motion" },
        { label: "Help", value: "Open", key: "help" },
        { label: "Device information", value: device, key: "" }
    ]
end function

sub buildSettingsRows()
    rows = m.top.findNode("rows")
    rows.removeChildrenIndex(rows.getChildCount(), 0)
    data = settingsRows()
    m.rowCount = data.Count()
    for i = 0 to data.Count() - 1
        g = rows.createChild("Group")
        g.translation = [0, i * 80]
        bg = g.createChild("Poster")
        bg.uri = "pkg:/images/row.png"
        bg.width = 1740
        bg.height = 64
        if i = m.row then bg.blendColor = m.t.selected else bg.blendColor = m.t.surface
        ring = g.createChild("Poster")
        ring.uri = "pkg:/images/row_ring.png"
        ring.width = 1740
        ring.height = 64
        ring.blendColor = m.t.focus
        ring.visible = (i = m.row)
        g.appendChild(rowLabel(data[i].label, 28, m.t.text, "font:BoldSystemFontFile"))
        g.appendChild(rowLabel(data[i].value, 1100, m.t.muted, "font:SystemFontFile"))
    end for
end sub

function rowLabel(text as string, x as integer, color as string, fontUri as string) as object
    lbl = CreateObject("roSGNode", "Label")
    lbl.text = text
    lbl.color = color
    lbl.translation = [x, 14]
    font = CreateObject("roSGNode", "Font")
    font.uri = fontUri
    font.size = 30
    lbl.font = font
    return lbl
end function

sub activateRow()
    key = settingsRows()[m.row].key
    if key = "theme"
        if m.prefs.theme = "midnight" then savePref("theme", "graphite") else savePref("theme", "midnight")
        applyTheme()
        buildSettingsRows()
    else if key = "motion"
        if m.prefs.motion = "standard" then savePref("motion", "reduced") else savePref("motion", "standard")
        buildSettingsRows()
    else if key = "help"
        m.fromSettings = true
        showPage("help")
    end if
end sub

sub buildAppGrid()
    rows = m.top.findNode("rows")
    rows.removeChildrenIndex(rows.getChildCount(), 0)
    apps = m.gridApps
    fs = CreateObject("roFileSystem")
    for i = 0 to apps.Count() - 1
        g = rows.createChild("Group")
        g.translation = [352 * (i mod 5), 40 + 232 * Int(i / 5)]
        ring = g.createChild("Poster")
        ring.uri = "pkg:/images/tile_ring.png"
        ring.width = 348
        ring.height = 208
        ring.translation = [-8, -8]
        ring.blendColor = m.t.focus
        ring.visible = (i = m.appIndex)
        face = g.createChild("Poster")
        face.uri = "pkg:/images/tile.png"
        face.width = 332
        face.height = 192
        if i = m.appIndex then face.blendColor = m.t.selected else face.blendColor = m.t.surface
        logo = "pkg:/images/app_" + apps[i][1] + ".png" ' made on the Chromebook by tools/tv.sh logos
        if fs.Exists(logo)
            pic = g.createChild("Poster")
            pic.uri = logo
            pic.width = 284
            pic.height = 160
            pic.translation = [24, 16]
            pic.loadDisplayMode = "scaleToFit"
        else
            lbl = rowLabel(apps[i][0], 28, m.t.text, "font:BoldSystemFontFile")
            lbl.translation = [28, 76]
            g.appendChild(lbl)
        end if
    end for
end sub

sub moveApp(delta as integer)
    nextIndex = m.appIndex + delta
    if nextIndex < 0 or nextIndex >= m.gridApps.Count() then return
    if (delta = 1 or delta = -1) and Int(nextIndex / 5) <> Int(m.appIndex / 5) then return ' stay in the row
    m.appIndex = nextIndex
    buildAppGrid()
end sub

' ---------- remote ----------

function onKeyEvent(key as string, press as boolean) as boolean
    if not press then return false

    if m.screen = "home"
        if key = "left"
            moveTile(-1)
            return true
        else if key = "right"
            moveTile(1)
            return true
        else if key = "OK"
            m.fromSettings = false
            showPage(m.favs[m.focus].action)
            return true
        end if
        return false ' Back at the root exits PureTV; Home always belongs to Roku
    end if

    if m.page = "settings"
        if key = "up" and m.row > 0
            m.row = m.row - 1
            buildSettingsRows()
            return true
        else if key = "down" and m.row < m.rowCount - 1
            m.row = m.row + 1
            buildSettingsRows()
            return true
        else if key = "OK"
            activateRow()
            return true
        end if
    end if

    if m.page = "apps" or m.page = "music"
        moves = { left: -1, right: 1, up: -5, down: 5 }
        if moves.DoesExist(key)
            moveApp(moves[key])
            return true
        else if key = "OK"
            m.launcher.appId = m.gridApps[m.appIndex][1]
            m.launcher.control = "STOP"
            m.launcher.control = "RUN"
            return true
        end if
    end if

    if key = "back"
        if m.page = "help" and m.fromSettings = true
            m.fromSettings = false
            showPage("settings")
        else
            showHome()
        end if
        return true
    end if
    return true ' swallow other keys on pages so nothing unexpected happens
end function
