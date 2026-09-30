import QtQuick
import Quickshell.Io
import qs.Commons
import qs.Ui

BarIndicator {
  id: root

  // Cycles only through sound modes (device is picked in the panel)
  // 0=Off 1=Marshall 2=Dolby Atmos 3=Gaming 4=Bass Boost 5=Bass Beast
  // 6=Vocal 7=Vocal Clarity 8=Night Mode 9=Classical 10=Rock 11=JBL Loud
  // 12=Sennheiser 13=Sony 14=Bose Comfort 15=Harman 16=Cinema
  // 17=Party 18=Lo-Fi 19=Crystal Air 20=Focus
  property int mode: 0

  readonly property var modeData: [
    { icon: "󱜞", preset: "",              label: "Off"          },
    { icon: "󰋋", preset: "Marshall",      label: "Marshall"     },
    { icon: "󱡬", preset: "Dolby-Atmos",   label: "Dolby Atmos"  },
    { icon: "󰊗", preset: "Gaming",        label: "Gaming"       },
    { icon: "󱡫", preset: "Bass-Boost",    label: "Bass Boost"   },
    { icon: "󱡬", preset: "Bass-Beast",    label: "Bass Beast"   },
    { icon: "󱁐", preset: "Vocal",         label: "Vocal"        },
    { icon: "󰍬", preset: "Vocal-Clarity", label: "Vocal Clarity"},
    { icon: "󰖔", preset: "Night-Mode",    label: "Night Mode"   },
    { icon: "󰝚", preset: "Classical",     label: "Classical"    },
    { icon: "󰥭", preset: "Rock",          label: "Rock"         },
    { icon: "󰓃", preset: "JBL-Loud",      label: "JBL Loud"     },
    { icon: "󰋎", preset: "Sennheiser",    label: "Sennheiser"   },
    { icon: "󰏶", preset: "Sony",          label: "Sony"         },
    { icon: "󰋎", preset: "Bose-Comfort",  label: "Bose Comfort" },
    { icon: "󰝚", preset: "Harman",        label: "Harman"       },
    { icon: "󰎆", preset: "Cinema",        label: "Cinema"       },
    { icon: "󰲸", preset: "Party",         label: "Party"        },
    { icon: "󰕾", preset: "Lo-Fi",         label: "Lo-Fi"        },
    { icon: "󰟎", preset: "Crystal-Air",   label: "Crystal Air"  },
    { icon: "󰱞", preset: "Focus",         label: "Focus"        }
  ]

  readonly property int modeCount: modeData.length

  active: mode !== 0
  activeText:   modeData[mode].icon
  inactiveText: modeData[0].icon
  activeTooltipText:   modeData[mode].label + " — click to cycle"
  inactiveTooltipText: "Audio FX: Off — click to enable"

  readonly property string applyScript:
    Qt.resolvedUrl("../pr4xh4r.audio/apply-audio.py").toString().replace("file://", "")

  Process {
    id: proc
    property string cmd: ""
    command: ["bash", "-c", cmd]
  }

  function applyMode(m) {
    mode = m % modeCount
    var preset = modeData[mode].preset
    if (!preset) {
      proc.cmd = "easyeffects --bypass 1"
    } else {
      // Pass empty string for device so only mode is applied
      // (device compensation is preserved if set via the panel)
      proc.cmd = "python3 " + applyScript + " \"\" " + preset
    }
    proc.running = true
  }

  onPressed: function() {
    root.applyMode(root.mode + 1)
  }
}
