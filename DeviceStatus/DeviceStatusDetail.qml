import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2

Item {
    id: root

    // ComboBox组件取值
    property var _DEVICE_INFO: []

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

            textRole: "text"

            model: _DEVICE_INFO

            property var curIndex: {
                if (!_status) {
                    return -1
                }

                for (var i in _DEVICE_INFO) {
                    if (_status.device.device_id === _DEVICE_INFO[i].value) {
                        return i
                    }
                }

                return -1
            }

            onCurIndexChanged: {
                currentIndex = curIndex
            }

            onActivated: {
                if (!root._status) {
                    return
                }

                var newID = _DEVICE_INFO[currentIndex].value
                root._status.device = mainWindow.getDevices(newID)
                root.itemChanged("device", JSON.stringify(root._status.device))
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
                if (!root._status) {
                    return
                }
                root._status.type_name = text
                root.itemChanged("type_name", text)
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
                if (!root._status) {
                    return
                }
                root._status.desc = text
                root.itemChanged("desc", text)
            }
        }
    }

    Component.onCompleted: {
        mainWindow.signalUpdateDeviceInfo.connect(function(deviceList) {
            _DEVICE_INFO = getDeiveInfo(deviceList)
        })
    }

    function load(value) {
        _status = value
        _DEVICE_INFO = getDeiveInfo(mainWindow.getAllDevices())

        //console.log("_DEVICE_INFO = ", JSON.stringify(_DEVICE_INFO))

        typeNameField.text = value.type_name
        descField.text = value.desc
    }

    function clear() {
        deviceComboBox.currentIndex = 0
        typeNameField.text = ""
        descField.text = ""
    }

    function getDeiveInfo(deviceList) {
        var info = []
        for (var i in deviceList) {
            info.push({
                          text: deviceList[i].type,
                          value: deviceList[i].device_id
                      })
        }
        return info
    }

}
