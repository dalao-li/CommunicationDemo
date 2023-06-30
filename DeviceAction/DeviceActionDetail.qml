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

    property var _action: {
        "device": devices[0],
        "bind_output_icd": devices[0].output_icd[0]
    }

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

        // device信息
        ComboBox {
            id: deviceIDCombox
            width: 130
            height: 25

            textRole: "type"

            model: devices

            onCurrentIndexChanged: {
                if (root._action) {
                    root._action.device = devices[currentIndex]
                    root.itemChanged("device", JSON.stringify(devices[currentIndex]))
                }
            }
        }

        // ouputICD信息
        Label {
            text: "绑定输出ICD"
            height: 25
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        ComboBox {
            id: icdCombox
            width: 130
            height: 25

            textRole: "text"

            property var icdList: {
                if (_action.device === undefined) {
                    return []
                }
                return getOuputICDList(_action.device.device_id)
            }

            property var curIndex: {
                for (var i in icdList) {
                    console.log("_action.bind_output_icd", _action.bind_output_icd, "icdList[i].value", icdList[i].value)
                    if (_action.bind_output_icd === icdList[i].value) {
                        return i
                    }
                }
                return -1
            }

            model: icdList

            currentIndex: curIndex

            onCurIndexChanged: {
                currentIndex = curIndex
            }

            onCurrentIndexChanged: {
                if (currentIndex < 0) {
                    return
                }

                if (root._action) {
                    root._action.bind_output_icd = payloads[currentIndex].id
                    root.itemChanged("bind_output_icd", payloads[currentIndex].id)
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
            width: 200
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
        name.text = value.name

        for (var i in devices) {
            if (value.device.device_id === devices[i].device_id) {
                deviceIDCombox.currentIndex = i
                break
            }
        }
    }

    function getOuputICDList(device_id) {
        if (_action === undefined || _action.device === undefined) {
            return []
        }

        var icd = []
        for (var i in devices) {
            if (devices[i].device_id === device_id) {
                var device =  devices[i]
                break
            }
        }

        // 遍历所有output_icd, 获取他们的名称
        for (var i in device.output_icd) {
            for (var j in payloads) {
                if (String(device.output_icd[i]) === String(payloads[j].id)) {
                    var info = {
                        text: payloads[j].name,
                        value: payloads[j].id
                    }
                    icd.push(info)
                }
            }
        }
        return icd
    }
}
