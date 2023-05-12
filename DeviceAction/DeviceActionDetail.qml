/*
 * @Description:
 * @Version: 1.0
 * @Author: liyuanhao
 * @Date: 2023-05-09 19:05:47
 * @LastEditors: liyuanhao
 * @LastEditTime: 2023-05-09 19:05:47
 */


import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2

Item {
    id: root

    property int defaultHeight: 60

    property var _action : []

    signal itemChanged(string id, string value)

    height: defaultHeight

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
            text: "设备动作录入"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                // 折叠
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
            id: deviceIDCombox
            width: 130
            height: 25

            textRole: "type"

            model: gDevices

            onCurrentIndexChanged: {
                if (root._action) {
                    var nowDevice = gDevices[deviceIDCombox.currentIndex]
                    // 修改device_id 同时修改 device_bind_id
                    root._action.device_id = nowDevice.device_id
                    root._action.device_bind_icd = nowDevice.input_icd
                    root.itemChanged("device_id", nowDevice.device_id)
                    root.itemChanged("device_bind_icd", nowDevice.input_icd)
                    // console.log("修改后", JSON.stringify(root._action))
                }
            }
        }

        Label {
            text: "绑定ICD"
            height: 25
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        ComboBox {
            id: icdCombox
            width: 130
            height: 25
            enabled: {
                return count != 0
            }

            textRole: "name"

            model: {
                var icdInfo = []
                for (var i in _action.device_bind_icd) {
                    for (var j in gPayloads) {
                        if (String(_action.device_bind_icd[i]) === String(gPayloads[j].icd_id)) {
                            icdInfo.push(gPayloads[j])
                            break
                        }
                    }
                }
                return icdInfo
            }

            // textRole: "input_icd"
            onCurrentIndexChanged: {
                if (root._action) {
                    var nowICDId = _action.device_bind_icd[currentIndex]
                    root._action.icd_id = nowICDId
                    root.itemChanged("icd_id", nowICDId)
                    // console.log("发送修改icd信号", nowICDId)
                }
            }
        }

        Label {
            text: "动作名"
            height: 25
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        TextField {
            id: name
            width: 100
            height: 25
            onTextChanged: {
                if (root._action) {
                    root._action.name = text
                    root.itemChanged("name", text)
                }
            }
        }
    }

    function load(value) {
        _action = value

        var nowDeviceIDIndex = 0
        var nowICDIDIndex = 0
        // 获取device_id 下标
        for (var i in gDevices) {
            if (value.device_id === gDevices[i].device_id) {
                nowDeviceIDIndex = i
                break
            }
        }

        // 获取icd_id 下标
        for (var j in value.device_bind_icd) {
            if (value.icd_icd === value.device_bind_icd[j]) {
                nowICDIDIndex = j
                break
            }
        }

        name.text = value.name
        deviceIDCombox.currentIndex = nowDeviceIDIndex
        icdCombox.currentIndex = nowICDIDIndex

        console.log("DeviceActionDetail加载", JSON.stringify(value), "\n")

    }
}
