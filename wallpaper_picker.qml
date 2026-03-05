import Qt.labs.folderlistmodel
import QtQuick
import QtQuick.Layouts
import QtQuick.Window
import Quickshell
import Quickshell.Io

FloatingWindow {
    id: window

    // -------------------------------------------------------------------------
    // PROPERTIES
    // -------------------------------------------------------------------------
    readonly property string homeDir: "file://" + Quickshell.env("HOME")
    readonly property string srcDir: homeDir + "/Vidéos/AnimatedWallpapers"
    readonly property string thumbDir: srcDir + "/.thumbnails"
    // MPVPAPER Command Template (OPTIMIZED)
    // -l auto: Fixes layer issues
    // --hwdec=auto: Forces GPU usage (Fixes lag)
    // --no-audio: Prevents audio processing (Saves CPU)
    readonly property string mpvCommand: "pkill mpvpaper; mpvpaper -o 'loop --hwdec=auto --no-audio' '*' '%1' & sleep 0.5; " + Quickshell.env("HOME") + "/.config/eww/bar/launch_bar.sh --force-open"
    // List of available swww transitions to randomize from
    readonly property var transitions: ["grow", "outer", "any", "wipe", "wave", "pixel", "center"]
    readonly property int itemWidth: 300
    readonly property int itemHeight: 420
    readonly property int borderWidth: 3
    readonly property int spacing: 0
    readonly property real skewFactor: -0.35

    // -------------------------------------------------------------------------
    // WINDOW CONFIG
    // -------------------------------------------------------------------------
    title: "wallpaper-picker"
    implicitWidth: 1920
    implicitHeight: 400
    color: "transparent"

    Shortcut {
        sequence: "Escape"
        onActivated: Qt.quit()
    }
    Shortcut { sequence: "H"; onActivated: view.decrementCurrentIndex() }
    Shortcut { sequence: "L"; onActivated: view.incrementCurrentIndex() }
    // -------------------------------------------------------------------------
    // CONTENT
    // -------------------------------------------------------------------------
    ListView {
        //anchors.verticalCenter: parent.verticalCenter

        id: view

        // --- NEW: Snap to active wallpaper on load ---
        property bool initialFocusSet: false

        anchors.fill: parent
        anchors.margins: 0
        spacing: window.spacing
        orientation: ListView.Horizontal
        clip: false
        highlightRangeMode: ListView.StrictlyEnforceRange
        preferredHighlightBegin: (width / 2) - (window.itemWidth / 2)
        preferredHighlightEnd: (width / 2) + (window.itemWidth / 2)
        // --- SPEED SETTINGS ---
        highlightMoveDuration: 300
        focus: true
        onCountChanged: {
            if (!initialFocusSet && count > 0) {
                var idx = parseInt(Quickshell.env("WALLPAPER_INDEX") || "0");
                // Only jump if the index exists in the current count
                if (count > idx) {
                    currentIndex = idx;
                    positionViewAtIndex(idx, ListView.Center);
                    initialFocusSet = true;
                }
            }
        }
        Keys.onReturnPressed: {
            if (currentItem)
                currentItem.pickWallpaper();

        }

        Socket {
            id: mpvSocket

            // Envoyer une commande
            function sendCommand(cmd) {
                console.log(cmd);
                mpvSocket.write(JSON.stringify(cmd) + "\n");
                mpvSocket.flush();
            }

            path: "/tmp/mpv-socket"
            connected: true
        }

        model: FolderListModel {
            id: folderModel

            folder: window.thumbDir
            nameFilters: ["*.bmp", "*.jpg", "*.jpeg", "*.png", "*.webp", "*.gif", "*.mp4", "*.mkv", "*.mov", "*.webm"]
            showDirs: false
            sortField: FolderListModel.Name
        }

        delegate: Item {
            id: delegateRoot

            readonly property bool isCurrent: ListView.isCurrentItem
            readonly property bool isVideo: fileName.startsWith("000_")

            function pickWallpaper() {
                let cleanName = fileName;
                if (cleanName.endsWith(".bmp"))
                    cleanName = cleanName.slice(0, -4);

                const originalFile = window.srcDir + "/" + cleanName;
                //mpvSocket.sendCommand({ command: ["load_file", "/home/lapin/Vidéos/AnimatedWallpapers/cherry-blossom-meadow-spring-breeze.mp4"] })

                //console.log("pick");
                Quickshell.execDetached(["/home/lapin/Vidéos/AnimatedWallpapers/wallpaper_change.sh", originalFile]);
                Qt.quit();
                /*if (isVideo) {
                     const finalCmd = window.mpvCommand.arg(originalFile)
                     Quickshell.execDetached(["bash", "-c", finalCmd])
                } else {
                     const randomTransition = window.transitions[Math.floor(Math.random() * window.transitions.length)]
                     const finalCmd = window.swwwCommand.arg(originalFile).arg(randomTransition)
                     Quickshell.execDetached(["bash", "-c", "pkill mpvpaper; " + finalCmd])
                }


                */
            }

            width: window.itemWidth
            height: window.itemHeight
            z: isCurrent ? 10 : 1

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    view.currentIndex = index;
                    delegateRoot.pickWallpaper();
                }
            }

            // PARALLELOGRAM CONTAINER
            Item {
                anchors.centerIn: parent
                width: parent.width
                height: parent.height
                scale: delegateRoot.isCurrent ? 1.15 : 0.95
                opacity: delegateRoot.isCurrent ? 1 : 0.6

                // 1. DYNAMIC BORDER (Background Layer)
                Image {
                    anchors.fill: parent
                    source: fileUrl
                    sourceSize: Qt.size(1, 1)
                    fillMode: Image.Stretch
                    visible: true
                }

                // 2. THE IMAGE (Inset Layer)
                Item {
                    anchors.fill: parent
                    anchors.margins: window.borderWidth
                    clip: true

                    Rectangle {
                        anchors.fill: parent
                        color: "black"
                    }

                    Image {
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: -35
                        width: parent.width + (parent.height * Math.abs(window.skewFactor)) + 50
                        height: parent.height
                        fillMode: Image.PreserveAspectCrop
                        source: fileUrl

                        transform: Matrix4x4 {
                            property real s: -window.skewFactor

                            matrix: Qt.matrix4x4(1, s, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
                        }

                    }

                    // 3. VIDEO INDICATOR (Top Right, Subtle)
                    Rectangle {
                        visible: delegateRoot.isVideo
                        anchors.top: parent.top
                        anchors.right: parent.right
                        anchors.margins: 10
                        width: 32
                        height: 32
                        radius: 6
                        color: "#60000000" // Subtle semi-transparent black

                        Canvas {
                            anchors.fill: parent
                            anchors.margins: 8
                            onPaint: {
                                var ctx = getContext("2d");
                                ctx.fillStyle = "#EEFFFFFF";
                                ctx.beginPath();
                                ctx.moveTo(4, 0);
                                ctx.lineTo(14, 8);
                                ctx.lineTo(4, 16);
                                ctx.closePath();
                                ctx.fill();
                            }
                        }

                        transform: Matrix4x4 {
                            property real s: -window.skewFactor

                            matrix: Qt.matrix4x4(1, s, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
                        }

                    }

                }

                Behavior on scale {
                    NumberAnimation {
                        duration: 500
                        easing.type: Easing.OutBack
                    }

                }

                Behavior on opacity {
                    NumberAnimation {
                        duration: 500
                    }

                }

                transform: Matrix4x4 {
                    property real s: window.skewFactor

                    matrix: Qt.matrix4x4(1, s, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
                }

            }

        }

    }

}
