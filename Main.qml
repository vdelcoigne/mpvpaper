import QtQuick
import Qt.labs.folderlistmodel
import qs.Common
import qs.Services
import qs.Widgets
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import qs.Modules.Plugins

PluginComponent {
    id: root

    readonly property string wallpapersFolder: pluginData.wallpapersFolder || "/home/lapin/Vidéos/AnimatedWallpapers"

    readonly property string currentWallpaper: pluginData.currentWallpaper || ""
    
    readonly property bool thumbCacheReady: pluginData.thumbCacheReady || true;
    
    readonly property string mpvSocket: pluginData.mpvSocket || "/tmp/mpv-socket"
    
    readonly property bool hardwareAcceleration: pluginData.hardwareAcceleration || false

    readonly property bool isMuted: pluginData.isMuted || false

    horizontalBarPill: Component {
        Row {
            spacing: Theme.spacingS

            DankIcon {
                name: "widgets"
                size: Theme.iconSize
                color: Theme.primary
                anchors.verticalCenter: parent.verticalCenter
            }

            StyledText {
                text: "mpv"
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }
        }
    }

    verticalBarPill: Component {
        Column {
            spacing: Theme.spacingXS

            DankIcon {
                name: "widgets"
                size: Theme.iconSize
                color: Theme.primary
                anchors.horizontalCenter: parent.horizontalCenter
            }
            
            StyledText {
                text: "mpv"
                font.pixelSize: Theme.fontSizeMedium
                color: Theme.surfaceText
                anchors.verticalCenter: parent.verticalCenter
            }

        }
    }

    popoutContent: Component {
        PopoutComponent {
            id: popoutColumn

            headerText: "Wallpaper selector"
            detailsText: "Click a wallpaper to select it"
            showCloseButton: false

            // StyledText {
            //     text: root.wallpapersFolder
            //     font.pixelSize: Theme.fontSizeSmall
            //     color: Theme.surfaceText
            //     anchors.horizontalCenter: parent.horizontalCenter
            // }
            Item {
                width: parent.width
                implicitHeight: root.popoutHeight - popoutColumn.headerHeight - popoutColumn.detailsHeight - Theme.spacingXL

                DankListView {
                    anchors.fill: parent
                    // cellWidth: 50
                    // cellHeight: 50
                    model:  wallpapersFolderModel
                    orientation: ListView.Vertical
                    delegate: Rectangle {
                        id: wallpaper
                        implicitWidth: ListView.view.width
                        height: 40
                        color: {
                            if (wallpaperMouse && wallpaperMouse.containsMouse) {
                                return Theme.surface
                            }
                            return "transparent"
                        }
                        required property string filePath
                        required property string fileName

                        StyledText {
                            text: fileName
                            font.pixelSize: Theme.fontSizeMedium
                            color: Theme.surfaceText
                            anchors.fill: parent
                            anchors.leftMargin: Theme.spacingM
                            anchors.rightMargin: Theme.spacingM
                            verticalAlignment: Text.AlignVCenter
                        }
                        MouseArea {
                            id: wallpaperMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor

                            onClicked: {
                                // Quickshell.execDetached(["sh", "-c", "echo -n '" + modelData + "' | wl-copy"])
                                ToastService.showInfo(fileName + " selected")
                                mpvpaper.currentWallpaper = filePath
                                popoutColumn.closePopout()
                            }
                        }
                    }

                    FolderListModel {
                        id: wallpapersFolderModel
                        folder: "file://" + root.wallpapersFolder
                        nameFilters: ["*.mp4", "*.avi", "*.mov"]
                        showDirs: false
                    }
                }
            }
        }
    }

    popoutWidth: 400
    popoutHeight: 500

    Mpvpaper {
        // Contains all the mpvpaper specific functionality
        id: mpvpaper
        // pluginApi: root.pluginApi

        active : true
        // active: root.active
        currentWallpaper: root.currentWallpaper
        hardwareAcceleration: root.hardwareAcceleration
        isMuted: root.isMuted
        // isPlaying: root.isPlaying
        mpvSocket: root.mpvSocket
        // profile: root.profile
        // fillMode: root.fillMode
        // volume: root.volume

        // thumbnails: thumbnails
        // innerService: innerService
    } 
}
