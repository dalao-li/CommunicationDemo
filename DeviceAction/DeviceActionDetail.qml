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
        "bind_input_icd": devices[0].input_icd[0]
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

            property var curIndex: {
                for (var i in devices) {
                    if (_action.device.device_id === devices[i].device_id) {
                        return i
                    }
                }
                return -1
            }

            currentIndex: curIndex

            onCurIndexChanged: {
                //console.log("action device currIndex = ", curIndex)
                currentIndex = curIndex
            }

            onCurrentIndexChanged: {
                if (currentIndex < 0) {
                    return
                }

                if (root._action) {
                    root._action.device = devices[currentIndex]
                    root.itemChanged("device", JSON.stringify(devices[currentIndex]))
                }
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
            width: 130
            height: 25

            textRole: "text"

            property var icdList: {
                if (_action === undefined) {
                    return []
                }

                if (_action.device === undefined) {
                    return []
                }
                return getInputICDList()
            }

            property var curIndex: {
                for (var i in icdList) {
                    if (_action.bind_input_icd === icdList[i].value) {
                        return i
                    }
                }
                return -1
            }

            model: icdList

            currentIndex: curIndex

            onCurIndexChanged: {
                //console.log("action icd currIndex = ", curIndex)
                currentIndex = curIndex
            }

            onCurrentIndexChanged: {
                if (currentIndex < 0) {
                    return
                }

                if (root._action) {
                    //console.log("当前action bind_input_icd", icdList[currentIndex].id)
                    root._action.bind_input_icd = icdList[currentIndex].id
                    root.itemChanged("bind_input_icd", icdList[currentIndex].id)
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
        //console.log("ActionDetail ", JSON.stringify(value))
        _action = value
        name.text = _action.name

        if (value.device === undefined) {
            return
        }

        for (var i in devices) {
            if (value.device.device_id === devices[i].device_id) {
                deviceIDCombox.currentIndex = i
                break
            }
        }
    }

    function getInputICDList() {
        if (_action === undefined || _action.device === undefined) {
            return []
        }

        var icdList = []
        for (var i in _action.device.input_icd) {
            for (var j in payloads) {
                if (String(_action.device.input_icd[i]) === String(payloads[j].id)) {
                    var info = {
                        text: payloads[j].name,
                        value: payloads[j].id
                    }
                    icdList.push(info)
                }
            }
        }
        return icdList
    }
}
