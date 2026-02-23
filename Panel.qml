import Qt.labs.folderlistmodel
import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io

Item {
    id: root
    
    readonly property var geometryPlaceholder: panelContainer
    readonly property bool allowAttach: true

    property real contentPreferredWidth: 1000 * Style.uiScaleRatio
    property real contentPreferredHeight: 700 * Style.uiScaleRatio

    readonly property bool thumbCacheReady: false

    readonly property string wallpapersFolder: 
        pluginApi.pluginSettings.wallpapersFolder || 
        "~/Vidéos/AnimatedWallpapers"

    readonly property string currentWallpaper: 
        pluginApi.pluginSettings.currentWallpaper || 
        ""

    anchors.fill: parent

    Rectangle {
        id: panelContainer
        anchors.fill: parent
        color: "transparent"

        ColumnLayout {
            anchors {
                fill: parent
                margins: Style.marginL
            }
            spacing: Style.marginL

            // Wallpapers folder content
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true

                color: Color.mSurfaceVariant;
                radius: Style.iRadiusS;

                ColumnLayout {
                    anchors.fill: parent
                    visible: !root.thumbCacheReady
                    spacing: Style.marginS

                    StyledText {
                        text: "Loading..."
                        Layout.alignment: Qt.AlignHCenter | Qt.AlignVCenter
                        pointSize: Style.fontSizeL
                        font.weight: Font.Bold
                    }
                }

                ColumnLayout {
                    anchors.fill: parent
                    visible: root.thumbCacheReady
                    spacing: Style.marginS

                    DankGridView {
                        id: gridView
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        Layout.margins: Style.marginXXS

                        property int columns: Math.max(1, Math.floor(availableWidth / 300));
                        property int itemSize: Math.floor(availableWidth / columns)

                        cellWidth: itemSize
                        // For now all wallpapers are shown in a 16:9 ratio
                        cellHeight: Math.floor(itemSize * (9/16))

                        model: wallpapersFolderModel.status == FolderListModel.Ready && root.thumbCacheReady ? wallpapersFolderModel : 0

                        // Wallpaper
                        delegate: Item {
                            id: wallpaper
                            required property int index
                            width: gridView.cellWidth
                            height: gridView.cellHeight

                            readonly property var path: wallpapersFolderModel.get(index, "filePath");

                            NImageRounded {
                                id: wallpaperImage
                                anchors {
                                    fill: parent
                                    margins: Style.marginXXS
                                }

                                radius: Style.iRadiusXS

                                borderWidth: root.thumbCacheReady && root.currentWallpaper == wallpapersFolderModel.get(index, "filePath") ? Style.borderM : 0
                                borderColor: Color.mPrimary;

                                imagePath: root.thumbCacheReady ? pluginApi.mainInstance.getThumbUrl(wallpaper.path) : "";
                                fallbackIcon: "alert-circle"

                                MouseArea {
                                    id: mouseArea
                                    anchors.fill: parent

                                    acceptedButtons: Qt.LeftButton
                                    cursorShape: Qt.PointingHandCursor
                                    hoverEnabled: true;

                                    onClicked: {
                                        // if(!pluginApi?.mainInstance) {
                                        //     Logger.d("mpvpaper", "Can't change background because pluginApi or main instance doesn't exist!");
                                        //     return;
                                        // }

                                        // pluginApi.mainInstance.setWallpaper(wallpaper.path);
                                    }

                                    onEntered: TooltipService.show(wallpaperImage, wallpaper.path, "auto", 100);
                                    onExited: TooltipService.hideImmediately();
                                }
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
}
