import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2

Item {
    id: root

    property int defaultHeight: 60

    height: defaultHeight

    property var _status
    property var _device

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

        // 选择设备
        Label {
            text: "设备"
            height: 25
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        ComboBox {
            id: deviceComboBox
            width: 200
            height: 25

            textRole: "type"

            model: ListModel {
                Component.onCompleted: {
                    // 加载原始数据
                    for (var i in devices) {
                        deviceComboBox.model.append(devices[i])
                    }
                    // 用于更新数据
                    mainWindow.updateDeviceSignal.connect(function(deviceList) {
                        deviceComboBox.model.clear()
                        deviceComboBox.model.append(deviceList)
                    })
                }
            }

            property var curIndex: {
                for (var i in devices) {
                    if (_status.device.device_id === devices[i].device_id) {
                        return i
                    }
                }
                return -1
            }

            onCurIndexChanged: {
                currentIndex = curIndex
            }

            onCurrentIndexChanged: {
                if (root._status) {
                    var newDevice = devices[deviceComboBox.currentIndex]
                    root._status.device = newDevice
                    root.itemChanged("device", JSON.stringify(newDevice))
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
            width: 200
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
        typeNameField.text = value.type_name
        descField.text = value.desc
    }

    function clear() {
        deviceComboBox.currentIndex = 0
        typeNameField.text = ""
        descField.text = ""
    }
}
