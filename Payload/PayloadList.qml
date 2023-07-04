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
    id: root

    property var busType
    property var payloads: []

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
            saveJSONFile(path)
        }
        onRejected: {
            console.log("Canceled")
        }
    }

    // 导入文件
    FileDialog {
        id: deviceDialog
        title: "Please choose a file"
        nameFilters: ["json files (*.json)", "All files (*)"]
        onAccepted: {
            var path = String(deviceDialog.fileUrls).substring(8)
            readJSONFile(path)
        }
        onRejected: {
            console.log("Canceled")
        }
    }
    header: Rectangle {
        height: 32
        width: root.width
        color: "#8E8E8E"

        AwesomeIcon {
            id: save
            size: 20
            name: "save"
            color: "black"

            anchors.right: batchAdd.left
            anchors.rightMargin: 5
            anchors.verticalCenter: parent.verticalCenter

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
                addData()
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
                name: "minus"
                backgroundColor: rowDelegate.color
                iconColor: "black"

                onClicked: {
                    root.payloads.splice(root.currentIndex, 1)
                    root.model.remove(root.currentIndex, 1)
                }
            }
        }
    } // highlight end

    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true

        onPressed: {
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

    function createID() {
        const MAX = 99999999
        const MIN = 40000000

        while(true) {
            var num = Math.floor(Math.random() * (MIN - MAX)) + MAX
            var flag = false
            for (var i in root.payloads) {
                if (root.payloads[i].id === num) {
                    flag = true
                    break
                }
            }

            if (!flag) {
                return num
            }
        }
    }

    function saveJSONFile(path) {
        Excutor.query({
                          "command": "write",
                          content: Excutor.formatJSON(JSON.stringify(payloads)),
                          path: path
                      })
    }

    // 导入设备信息
    function readJSONFile(path) {
        if (path === "") {
            return
        }

        var data = Excutor.query({"payloads": path})
        for (var i in data) {
            var info = {
                "bus": data.bus,
                "bus_type": data.bus_type,
                "id": data.id,
                "name": data.name,
                "values": data.values
            }
            root.payloads.push(info)
            root.model.append({name: info.name})
        }
    }

    function addData() {
        var info = {
            "name": "载荷" + String(root.payloads.length),
            "id": String(createID()),
            "bus": 0,
            "bus_type": "udp",
            "values": []
        }
        root.payloads.push(info)
        root.model.append({"name": info.name})
    }
}
