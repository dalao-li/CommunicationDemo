/*
 * @Description:
 * @Version: 1.0
 * @Author: liyuanhao
 * @Date: 2023-05-09 19:05:47
 * @LastEditors: liyuanhao
 * @LastEditTime: 2023-07-09 19:05:47
 */


import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2

Item {
    id: root

    property var _action

    // ComboBox组件取值
    property var _DEVICE_INFO: []
    property var _INPUT_ICD_INFO: []

    property int defaultHeight: 60

    signal itemChanged(string id, string value)

    signal deviceChange()

    height: defaultHeight

    Rectangle {
        id: title
        anchors { left: parent.left; right: parent.right }
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
            topMargin: 3;
            top: title.bottom;
            bottom: parent.bottom
            left: parent.left; leftMargin: 3
            right: parent.right
        }

        spacing: 15

        // 设备信息
        Label { text: "设备"; height: 25; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter}
        ComboBox {
            id: deviceCombox
            width: 200; height: 25

            textRole: "text"

            model: _DEVICE_INFO

            property var curIndex: {
                if (_action === undefined || _DEVICE_INFO.length === 0) {
                    return -1
                }

                var deviceID = root._action.device.device_id
                for (var i in _DEVICE_INFO) {
                    if (_DEVICE_INFO[i].value === deviceID) {
                        return i
                    }
                }
                return -1
            }

            onCurIndexChanged: {
                currentIndex = curIndex
            }

            onActivated: {
                if (!root._action) {
                    return
                }
                var newID = _DEVICE_INFO[currentIndex].value
                root._action.device = mainWindow.getDevices(newID)
                root.itemChanged("device", JSON.stringify(root._action.device))

                deviceChange()
            }
        }

        // input ICD信息
        Label { text: "绑定输入ICD"; height: 25; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter }
        ComboBox {
            id: inputICDCombox
            width: 200; height: 25

            textRole: "text"

            model: _INPUT_ICD_INFO

            property var curIndex: {
                if (_action === undefined || _INPUT_ICD_INFO.length === 0) {
                    return -1
                }

                for (var i in _INPUT_ICD_INFO) {
                    if (_INPUT_ICD_INFO[i].value === _action.actions.bind_input_icd) {
                        return i
                    }
                }
                return -1
            }

            onCurIndexChanged: {
                currentIndex = curIndex
            }

            onActivated: {
                if (!root._action || currentIndex < 0) {
                    return
                }
                var nowICD = _INPUT_ICD_INFO[currentIndex].value
                root._action.actions.bind_input_icd = nowICD
                root.itemChanged("bind_input_icd", nowICD)
            }

            Connections {
                target: root
                onDeviceChange: {
                    inputICDCombox.currentIndex = 0
                    _INPUT_ICD_INFO = getInputICDInfo(root._action.device.input_icd)

                    root.itemChanged("bind_input_icd", _INPUT_ICD_INFO[0].value)
                }
            }
        }

        Label { text: "动作名"; height: 25; horizontalAlignment: Text.AlignHCenter; verticalAlignment: Text.AlignVCenter}
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

    Component.onCompleted: {
        mainWindow.signalUpdateDeviceInfo.connect(function(deviceList) {
            _DEVICE_INFO = getDeiveInfo(deviceList)
        })
    }

    function load(value) {
        _action = value

        _DEVICE_INFO = getDeiveInfo(mainWindow.getAllDevices())
        _INPUT_ICD_INFO = getInputICDInfo(root._action.device.input_icd)

        name.text = _action.actions.name
    }

    function getInputICDInfo(inputICDList) {
        var info = []
        for (var i in inputICDList) {
            var icd = inputICDList[i]
            var payload = mainWindow.getPayLoads(icd)
            info.push({
                          text: payload.name,
                          value: payload.id
                      })
        }
        return info
    }

    function clear() {
        deviceCombox.currentIndex = 0
        inputICDCombox.currentIndex = 0

        name.text = ""
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
