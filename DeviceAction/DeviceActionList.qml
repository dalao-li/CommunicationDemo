/*
 * @Description:
 * @Version: 1.0
 * @Author: liyuanhao
 * @Date: 2023-05-09 19:05:47
 * @LastEditors: Please set LastEditors
 * @LastEditTime: 2023-05-10 14:52:15
 */


import QtQuick 2.5
import DesktopControls 0.1
import QtQuick.Dialogs 1.2
import "../Button"


ListView {
    property var actions : []

    id: root
    focus: true
    implicitWidth: 200

    model: ListModel {}

    // 另存为文件
    FileDialog {
        id: newfileDialog
        title: "Please choose a file"

        selectExisting: false
        nameFilters: ["json files (*.json)", "All files (*)"]
        onAccepted: {
            var path = String(newfileDialog.fileUrls).substring(8)
            saveActionInfo(path)
        }
        onRejected: {
            console.log("Canceled")
        }
    }

    // 表头部分
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
            anchors.right: batchAdd.left
            anchors.rightMargin: 5

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
                // 默认是选第一个设备, 选择第一个icd
                var defaultInfo = gDevices[0]
                var info = {
                    "name": "动作" + String(root.actions.length),
                    "id": String(createID()),
                    "condition": [],
                    "device_id": defaultInfo.device_id,
                    "icd_id": defaultInfo.input_icd[0],
                    "device_bind_icd": defaultInfo.input_icd
                }
                root.actions.push(info)
                root.model.append(info)
            }
        } // BatchAddButton end
    } // header end

    delegate: Label {
        x: 3
        height: 27
        width: root.width
        text: name
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
                    root.actions.splice(root.currentIndex, 1)
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
            if(index > -1) {
                root.currentIndex = index
            }
        }
        onReleased: mouse.accepted = false
        onDoubleClicked: mouse.accepted = false
        onPressAndHold: mouse.accepted = false
    }

    // 生成随机ID
    function createID() {
        const MAX = 65535
        const MIN = 0
        while(true) {
            var num = Math.floor(Math.random() * (MIN - MAX)) + MAX
            var flag = false
            for (var i in root.actions) {
                if (root.actions[i].id === num) {
                    flag = true
                    break
                }
            }

            if (!flag) {
                return num
            }
        }
    }

    // TODO
    // 导出
    function saveActionInfo(path) {
        var data = root.actions
        var dataList = []
        // 处理JSON


        Excutor.query({"command": "write",
                          content: Excutor.formatJSON(JSON.stringify(dataList)),
                          path: path})
    }
}
