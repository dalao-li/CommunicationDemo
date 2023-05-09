import QtQuick 2.5
import DesktopControls 0.1
import QtQuick.Dialogs 1.2
import "../Button"


ListView {
    property var status : []

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
            saveDeviceInfo(path)
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
                    //var full = Excutor.query({"apppath": ""})+"/config/icd.payloads"
                    newfileDialog.open()
                    //root.savePayload(path)
                }
            }
        }

        // 增加按钮
        BatchAddButton {
            id: batchAdd
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                var info = {
                    "type_name": "状态" + String(root.status.length),
                    "desc": "",
                    "monitor_status": [],
                    "device_id": mainWindow.gDeviceInfoAndICD[0].id
                }
                root.status.push(info)

                // 将信息添加入model
                root.model.append({"type_name": info.type_name})
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
            if( index > -1 ) {
                root.currentIndex = index
            }
        }
        onReleased: mouse.accepted = false
        onDoubleClicked: mouse.accepted = false
        onPressAndHold: mouse.accepted = false
    }

    // 用于生成ID
    function contains(id) {
        for (var i = 0; i < root.status.length; ++i) {
            if (root.status[i].type_id === id) {
                return true
            }

            return false
        }
    }

    // 生成ID
    function generateId() {
        var i = root.status.length
        while(i++) {
            if (!contains(i)) {
                return i
            }
        }
    }

    function generateTypeID() {
        return root.status.length + 1
    }

    // 导出
    function saveDeviceInfo(path) {
        var data = root.status
        var dataList = []
        // 处理JSON
        for (var i in data) {
            var res = {}
            res["id"] = data[i].device_id
            res["type_name"] = data[i].type_name
            res["desc"] = data[i].desc
            res["monitor_status"] = data[i].monitor_status
            dataList.push(res)
        }

        Excutor.query({"command": "write",
                          content: Excutor.formatJSON(JSON.stringify(dataList)),
                          path: path})
    }
}
