import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4

import DesktopControls 0.1

Item {
    id: root
    clip: true
    width: 25
    height: 18
    signal clicked(int index)

    property var model: ["5个", "10个", "20个"]

    AwesomeIcon {
        id: add
        anchors {
            verticalCenter: parent.verticalCenter
        }
        size: 20
        name: "plus"
        color: "black"

        MouseArea {
            anchors.fill: parent
            onClicked: {
                root.clicked(-1)
            }
        }
    }

    property int itemHeight: 20

    Menu {
        id: menu

        Repeater {
            id: repeat
            model: root.model
            MenuItem {
                id: item

                onTriggered: {
                    root.clicked(index)
                    console.log(index)
                }
            }
        }
    }
}
