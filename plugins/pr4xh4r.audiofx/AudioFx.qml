import QtQuick
import QtQuick.Layouts
import Quickshell.Io
import qs.Commons
import qs.Ui

BarIndicator {
    id: root

    // Modes: 0=Off, 1=Marshall, 2=Dolby-Atmos, 3=Harman,
    //        4=Sony-Clear, 5=Bose-Comfort, 6=JBL-Loud,
    //        7=Bass-Beast, 8=Vocal-Clarity, 9=Lo-Fi, 10=Crystal-Air
    property int mode: 0

    readonly property var modes: [
        { id: 0,  label: "Off",               preset: "",                icon: "󱜞", color: "#8E8E93", tip: "No processing" },
        { id: 1,  label: "Marshall",           preset: "Marshall",        icon: "󰋋", color: "#FF9500", tip: "Warm bass · Punchy mids" },
        { id: 2,  label: "Dolby Atmos",        preset: "Dolby-Atmos",     icon: "󱡬", color: "#0A84FF", tip: "Wide · Immersive · Spatial" },
        { id: 3,  label: "Harman",             preset: "Harman",          icon: "󰓃", color: "#30D158", tip: "Science-backed · Most preferred" },
        { id: 4,  label: "Sony Clear",         preset: "Sony-Clear",      icon: "󰋋", color: "#64D2FF", tip: "Deep bass · Crystal vocals" },
        { id: 5,  label: "Bose Comfort",       preset: "Bose-Comfort",    icon: "󰋋", color: "#BF5AF2", tip: "Balanced · Zero fatigue" },
        { id: 6,  label: "JBL Loud",           preset: "JBL-Loud",        icon: "󰓃", color: "#FF3B30", tip: "V-shaped · Energetic · Party" },
        { id: 7,  label: "Bass Beast",         preset: "Bass-Beast",      icon: "󰓃", color: "#FF2D55", tip: "Sub-heavy · Psychoacoustic bass" },
        { id: 8,  label: "Vocal Clarity",      preset: "Vocal-Clarity",   icon: "󰍬", color: "#34C759", tip: "Podcast · Clear speech" },
        { id: 9,  label: "Lo-Fi",              preset: "Lo-Fi",           icon: "󰥔", color: "#FFD60A", tip: "Vintage · Tape warmth" },
        { id: 10, label: "Crystal Air",        preset: "Crystal-Air",     icon: "󰜟", color: "#5AC8FA", tip: "Airy · Detailed · Open" }
    ]

    readonly property var currentMode: modes[mode] || modes[0]

    active: mode !== 0
    activeText:   currentMode.icon
    inactiveText: modes[0].icon
    activeTooltipText:   currentMode.label + " — " + currentMode.tip + " (click to cycle)"
    inactiveTooltipText: "Audio FX: Off — click to enable " + modes[1].label

    Process {
        id: proc
        property string cmd: ""
        command: ["bash", "-c", cmd]
    }

    function applyMode(m) {
        mode = ((m % modes.length) + modes.length) % modes.length
        var target = modes[mode]
        if (mode === 0) {
            proc.cmd = "easyeffects --bypass 1"
        } else {
            proc.cmd = "easyeffects --bypass 0 && easyeffects --load-preset " + target.preset
        }
        proc.running = true
    }

    onPressed: function() {
        root.applyMode(root.mode + 1)
    }
}
