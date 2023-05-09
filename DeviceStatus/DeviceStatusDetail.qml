import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2

Item {
    id: root

    property int defaultHeight: 60

    height: defaultHeight

    property var statusDetailValue

    // 修改信号
    signal itemChanged(string id, string value)

    // 标题
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

        // 点击折叠
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (root.height === defaultHeight) {
                    root.height = title.height
                } else {
                    root.height = defaultHeight
                }

                !flow.visible
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
            id: idList
            width: 130
            height: 25
            enabled: {
                return count != 0
            }

            textRole: "type"

            onCurrentIndexChanged: {
                if (root.statusDetailValue) {
                    var _id =  mainWindow.gDeviceInfoAndICD[currentIndex].id
                    root.statusDetailValue.device_id = _id
                    // console.log("修改信号发送", _id)
                    root.itemChanged("device_id", _id)
                }
            }
        }

        Binding {
            target: idList
            property: "model"
            value: mainWindow.gDeviceInfoAndICD
        }

        Label {
            text: "状态名"
            height: 25
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        TextField {
            id: typeName
            width: 100
            height: 25
            onTextChanged: {
                if (root.statusDetailValue) {
                    root.statusDetailValue.type_name = text
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
            id: descTextField
            width: 300
            height: 25
            onTextChanged: {
                if (root.statusDetailValue) {
                    root.statusDetailValue.desc = text
                    root.itemChanged("desc", text)
                }
            }
        }
    }


    function load(value) {
        console.log("DeviceStatusDetail 加载数据", JSON.stringify(value))
        statusDetailValue = value

        for (var i = 0; i < mainWindow.gDeviceInfoAndICD.length; ++i) {
            if (value.device_id === mainWindow.gDeviceInfoAndICD[i].id) {
                idList.currentIndex = i
                break
            }
        }

        typeName.text = value.type_name
        descTextField.text = value.desc

    }
}
