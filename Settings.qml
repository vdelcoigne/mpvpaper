import QtQuick
import qs.Common
import qs.Modules.Plugins
import qs.Widgets

PluginSettings {
    id: root
    pluginId: "mpvpaper"

    StyledText {
        width: parent.width
        text: "Mpvpaper plugin settings"
        font.pixelSize: Theme.fontSizeLarge
        font.weight: Font.Bold
        color: Theme.surfaceText
    }

    StyledText {
        width: parent.width
        text: "Configuration"
        font.pixelSize: Theme.fontSizeSmall
        color: Theme.surfaceVariantText
        wrapMode: Text.WordWrap
    }

    StringSetting {
        settingKey: "wallpapersFolder"
        label: "Wallpapers Folder"
        description: "The folder that contains all the wallpapers."
        placeholder: "~/Pictures/Wallpapers"
        defaultValue: "~/Pictures/Wallpapers"
    }
    
     ToggleSetting {
        settingKey: "active"
        label: I18n.tr("Active")
        defaultValue: true
    }
    
    ToggleSetting {
        settingKey: "hardwareAcceleration"
        label: I18n.tr("HardwareAcceleration")
        description: "Enable hardware acceleration for mpv."
        defaultValue: false
    }
    
    ToggleSetting {
        settingKey: "mute"
        label: I18n.tr("Mute")
        defaultValue: true
    }
    
    StringSetting {
        settingKey: "mpvSocket"
        label: "Mpv socket"
        description: "The mpvpaper socket that the plugin will connect to."
        placeholder: "Example: /tmp/mpv-socket"
        defaultValue: "/tmp/mpv-socket"
    }
}
