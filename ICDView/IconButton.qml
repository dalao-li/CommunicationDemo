import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import DesktopControls 0.1

AwesomeIcon {
    id: root
    size: 20
    color: "black"
    name: "plus"
    signal clicked()

    MouseArea {
        anchors.fill: parent
        onClicked: root.clicked()
    }
}
