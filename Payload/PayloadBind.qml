import QtQuick 2.5
import QtQuick.Controls 1.4

import QtQuick.Layouts 1.1
import QtQuick.Window 2.0

TableView {
    id: root

    property string strType: ""

    frameVisible: false
    implicitWidth: 300
    implicitHeight: 100
    signal itemChanged(int index, var value)

    itemDelegate: Label {
        text: styleData.value
        horizontalAlignment: Text.AlignHCenter
    }

    model: ListModel{}

    TableViewColumn {
        id: frameName
        title: "工程值名称"
        role: "name"
        width: 200
    }

    TableViewColumn {
        id: payloadName
        title: "值"
        role: "value"
        width: 80
    }
}
