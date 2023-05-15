import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2

Item {
    id: root

    property var _status
    property int defaultHeight: 60

    height: defaultHeight

    signal itemChanged(string id, string value)

    Rectangle {
        id: title
        anchors {
            left: parent.left
            right: parent.right
        }
        height: 32
        color: "#e5e5e5"

        Label {
            anchors.centerIn: parent
            text: "设备状态录入"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (root.height === defaultHeight) {
                    root.height = title.height
                } else {
                    root.height = defaultHeight
                }
                flow.visible = !flow.visible
            }
        }
    } // title end

    Flow {
        id: flow
        anchors {
            topMargin: 3
            top: title.bottom
            bottom: parent.bottom
            left: parent.left
            leftMargin: 3
            right: parent.right
        }

        spacing: 15

        Label {
            text: "设备"
            height: 25
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        ComboBox {
            id: idCompox
            width: 130
            height: 25

            textRole: "type"

            model: devices

            onCurrentIndexChanged: {
                if (root._status) {
                    // 修改设备id
                    var device = devices[idCompox.currentIndex]

                    console.log("修改值", JSON.stringify(device))
                    root._status.device_id = device.device_id
                    root.itemChanged("device_id", device.device_id)
                }
            }
        }

        Label {
            text: "状态名"
            height: 25
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        TextField {
            id: typeNameField
            width: 100
            height: 25
            onTextChanged: {
                if (root._status) {
                    root._status.type_name = text
                    root.itemChanged("type_name", text)
                }
            }
        }

        // desc
        Label {
            id: descLabel
            text: "备注"
        }

        TextField {
            id: descField
            width: 300
            height: 25
            onTextChanged: {
                if (root._status) {
                    root._status.desc = text
                    root.itemChanged("desc", text)
                }
            }
        }
    }

    function load(value) {
        _status = value

        for (var i in devices) {
            if (value.device_id === devices[i].device_id) {
                idCompox.currentIndex = i
                break
            }
        }

        typeNameField.text = value.type_name
        descField.text = value.desc

    }
}
