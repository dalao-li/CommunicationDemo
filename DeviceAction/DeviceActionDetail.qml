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

    property var _action/*: {
        "device": devices[0],
        "actions": {
            "bind_input_icd": devices[0].input_icd[0]
        }
    }*/

    property var _DEVICE_COMBOBOX_MODEL: []
    property var _DEVICE_COMBOBOX_CURRENTINDEX: -1

    property var _INPUTICD_COMBOBOX_MODEL: []
    property var _INPUTICD_COMBOBOX_CURRENTINDEX: -1

    property int defaultHeight: 60

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

        // 设备信息
        ComboBox {
            id: deviceComboBox
            width: 200
            height: 25

            textRole: "text"

            model: _DEVICE_COMBOBOX_MODEL

            property var curIndex: _DEVICE_COMBOBOX_CURRENTINDEX

            onCurIndexChanged: {
                currentIndex = curIndex
            }

            onCurrentIndexChanged: {
                if (!root._action) {
                    return
                }

                var deviceID = _DEVICE_COMBOBOX_MODEL[currentIndex].value
                root._action.device = getDevices(deviceID)
                root.itemChanged("device", JSON.stringify(root._action.device))

                // 更新input combobox
                _INPUTICD_COMBOBOX_MODEL = getInputICDInfo()
                _INPUTICD_COMBOBOX_CURRENTINDEX = 0
                icdCombox.currentIndex = 0
                root.itemChanged("bind_input_icd", _INPUTICD_COMBOBOX_MODEL[0].value)
            }
        }

        // input ICD信息
        Label {
            text: "绑定输入ICD"
            height: 25
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        ComboBox {
            id: icdCombox
            width: 200
            height: 25

            textRole: "text"

            model: _INPUTICD_COMBOBOX_MODEL

            property var curIndex: _INPUTICD_COMBOBOX_CURRENTINDEX

            onCurIndexChanged: {
                currentIndex = curIndex
            }

            onCurrentIndexChanged: {
                if (!root._action || currentIndex < 0) {
                    return
                }

                root._action.actions.bind_input_icd = _INPUTICD_COMBOBOX_MODEL[currentIndex].value
                root.itemChanged("bind_input_icd", _INPUTICD_COMBOBOX_MODEL[currentIndex].value)
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
            width: 200
            height: 25
            onTextChanged: {
                if (!root._action) {
                    return
                }
                root._action.actions.name = text
                root.itemChanged("name", text)
            }
        }
    }

    function load(value, deviceInfoList, deviceIndex, inputICDInfoList, intputICDIndex) {
        _action = value

        // 配置ComBoBox
        _DEVICE_COMBOBOX_MODEL = deviceInfoList
        _DEVICE_COMBOBOX_CURRENTINDEX = deviceIndex

        _INPUTICD_COMBOBOX_MODEL = inputICDInfoList
        _INPUTICD_COMBOBOX_CURRENTINDEX = intputICDIndex

        name.text = _action.actions.name
    }

    function getInputICDInfo() {
        if (_action === undefined || _action.device === undefined) {
            return []
        }

        var info = []
        for (var i in root._action.device.input_icd) {
            for (var j in payloads) {
                if (String(root._action.device.input_icd[i]) === String(payloads[j].id)) {
                    info.push({
                                  text: payloads[j].name,
                                  value: payloads[j].id
                              })
                }
            }
        }
        return info
    }

    function clear() {
        _DEVICE_COMBOBOX_MODEL = []
        _INPUTICD_COMBOBOX_MODEL = []

        deviceComboBox.currentIndex = 0
        icdCombox.currentIndex = 0

        name.text = ""
    }
}
