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
        description: "blabla describe"
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
        description: "blabla describe"
        placeholder: "/tmp/mpv-socket"
        defaultValue: "/tmp/mpv-socket"
    }
}
