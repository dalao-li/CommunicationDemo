/*
 * @Description:
 * @Version: 1.0
 * @Author: liyuanhao
 * @Date: 2023-05-09 19:05:47
 * @LastEditors: Please set LastEditors
 * @LastEditTime: 2023-05-11 17:15:25
 */

import QtQuick 2.5
import DesktopControls 0.1
import QtQuick.Dialogs 1.2
import "../Button"


ListView {
    id: root
    focus: true
    implicitWidth: 200

    property var status : []

    model: ListModel {}

    FileDialog {
        id: newfileDialog
        title: "Please choose a file"

        selectExisting: false
        nameFilters: ["json files (*.json)", "All files (*)"]
        onAccepted: {
            var path = String(newfileDialog.fileUrls).substring(8)
            saveJSONFile(path)
        }
        onRejected: {
            console.log("Canceled")
        }
    }

    header: Rectangle {
        height: 32
        width: root.width
        color: "#8E8E8E"

        // 保存按钮
        AwesomeIcon {
            id: save
            anchors.verticalCenter: parent.verticalCenter
            size: 20
            name: "save"
            color: "black"

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    newfileDialog.open()
                }
            }
        }

        // 增加按钮
        BatchAddButton {
            id: batchAdd
            anchors {
                right: parent.right
                rightMargin: 8
                verticalCenter: parent.verticalCenter
            }

            onClicked: {
                var info = {
                    "type_name": "状态_" + String(root.status.length),
                    "desc": "",
                    "monitor_status": [],
                    // 默认是第一个设备
                    "device": devices[0]

                }
                root.status.push(info)
                root.model.append(info)
            }
        } // BatchAddButton end
    } // header end

    delegate: Label {
        x: 3
        height: 27
        width: root.width
        text: type_name
        color: "black"
    }

    highlight: Rectangle {
        id: rowDelegate
        color: Qt.darker(Theme.current.accent, 1.5)
        Row {
            spacing: 3
            anchors {
                right: parent.right
                rightMargin: 10
                verticalCenter: parent.verticalCenter
            }

            // 移除按钮
            AwesomeButton {
                id: remove
                backgroundColor: rowDelegate.color
                iconColor: "black"
                name: "minus"

                onClicked: {
                    root.status.splice(root.currentIndex, 1)
                    root.model.remove(root.currentIndex, 1)
                }
            }
        }
    } // highlight end

    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        onPressed: {
            // 实现高亮效果
            mouse.accepted = false
            var index = root.indexAt(mouse.x, mouse.y - headerItem.height)
            if (index > -1) {
                root.currentIndex = index
            }
        }
        onReleased: mouse.accepted = false
        onDoubleClicked: mouse.accepted = false
        onPressAndHold: mouse.accepted = false
    }

    // 导出
    function saveJSONFile(path) {
        var jsonData = []
        // 处理JSON
        for (var i in root.status) {
            var res = {}
            res["id"] = root.status[i].device.device_id
            res["type_name"] = root.status[i].type_name
            res["desc"] = root.status[i].desc
            res["monitor_status"] = root.status[i].monitor_status
            jsonData.push(res)
        }

        Excutor.query({"command": "write",
                          content: Excutor.formatJSON(JSON.stringify(jsonData)),
                          path: path})
    }
}
