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
    property var deviceAction
    property var canUseICD : []

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

            textRole: "type"

            onCurrentIndexChanged: {
                if (root.deviceAction) {
                    var _id =  mainWindow.gDeviceBindList[idList.currentIndex].id
                    root.deviceAction.device_id = _id
                    root.itemChanged("device_id", _id)
                }
            }
        }

        Binding {
            target: idList
            property: "model"
            value: mainWindow.gDeviceBindList
        }

        Label {
            text: "绑定ICD"
            height: 25
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        ComboBox {
            id: icdList
            width: 130
            height: 25
            enabled: {
                return count != 0
            }

            textRole: "name"

            model: {
                var icdNameList = []
                for (var i in canUseICD) {
                    for (var j in gICDList) {
                        if (String(canUseICD[i]) === String(gICDList[j].icd_id)) {
                            icdNameList.push(gICDList[j])
                            break
                        }
                    }
                }
                return icdNameList
            }

            // textRole: "input_icd"
            onCurrentIndexChanged: {
                if (root.deviceAction) {
                    var deviceInfo = gDeviceBindList[idList.currentIndex]
                    var nowICDId = deviceInfo.input_icd[currentIndex]
                    root.deviceAction.icd_id = nowICDId
                    root.itemChanged("icd_id", nowICDId)
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
                if (root.deviceAction) {
                    root.deviceAction.name = text
                    root.itemChanged("name", text)
                }
            }
        }
    }

    function load(value) {
        var deviceInfo = mainWindow.gDeviceBindList

        var nowDeviceIDIndex = 0
        var nowICDIDIndex = 0
        // 修改device_id
        for (var i = 0; i < deviceInfo.length; ++i) {
            if (value.device_id === deviceInfo[i].id) {
                nowDeviceIDIndex = i

                canUseICD = deviceInfo[i].input_icd
                // 修改icd_id
                for (var j = 0; j < deviceInfo[i].input_icd.length; ++j) {
                    if (value.icd_icd === deviceInfo[i].input_icd[j]) {
                        nowICDIDIndex = j
                        break
                    }
                }
            }
        }


        deviceAction = value

        name.text = value.name
        idList.currentIndex = nowDeviceIDIndex
        icdList.currentIndex = nowICDIDIndex

    }
}
