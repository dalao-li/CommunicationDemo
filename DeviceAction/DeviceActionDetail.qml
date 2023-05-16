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

    property var _action : []

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

        // device信息
        ComboBox {
            id: deviceIDCombox
            width: 130
            height: 25

            //textRole: "type"

            model: {
                var res = []
                for (var i in devices) {
                    res.push(devices[i].type)
                }
                return res
            }

            onCurrentIndexChanged: {
                if (root._action) {
                    root._action.device = currentIndex
                    root.itemChanged("device", currentIndex)
                }
            }
        }

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
            enabled: {
                return count != 0
            }

            //textRole: "name"

            model: {
                var res = []
                var ouputICD = devices[_action.device].ouput_icd
                for (var i in ouputICD) {
                    for (var j in payloads) {
                        if (String(ouputICD[i]) === String(payloads[j].id)) {
                            res.push(payloads[j].name)
                        }
                    }
                }
                return res
            }

            onCurrentIndexChanged: {
                if (root._action) {
                    root._action.bind_ouput_icd = currentIndex
                    root.itemChanged("bind_ouput_icd", currentIndex)
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


        name.text = value.name
        deviceIDCombox.currentIndex = value.device
        icdCombox.currentIndex = value.bind_ouput_icd
    }
}
