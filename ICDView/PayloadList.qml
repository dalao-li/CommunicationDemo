import QtQuick 2.5
import DesktopControls 0.1
import QtQuick.Dialogs 1.2

ListView {
    id: root

    property var busType
    property var payloads

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
            savePayloadsInfo(path)
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
                var info = {
                    "name": "载荷" + String(root.payloads.length),
                    "id": "icd_" + String(generateId()),
                    "bus": 0,
                    "bus_type": "udp",
                    "values": []
                }
                root.payloads.push(info)

                // 将信息添加入model
                root.model.append({"name": info.name})

                gICDInfoList.push({"name": info.name, "icd_id": info.id})
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

                    gICDInfoList.splice(root.currentIndex, 1)

                    // sExcutor.query({"command":"remove_payload", "index":root.currentIndex })
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
        for (var i=0; i < root.payloads.length; ++i) {
            if (root.payloads[i].id === id) {
                return true
            }

            return false
        }
    }

    // 生成ID
    function generateId() {
        var i = root.payloads.length
        while(i++) {
            if (!contains(String(i))) {
                return i
            }
        }
    }

    function savePayload( path ){
        console.log("root.payloads---"+JSON.stringify(root.payloads))
        Excutor.query({"command":"write",
                           content:Excutor.formatJSON(JSON.stringify(root.payloads)),
                           path:path})
    }

    function savePayloadsInfo(path) {
        console.log(JSON.stringify(payloads))
        Excutor.query({"command": "write",
                          content: Excutor.formatJSON(JSON.stringify(payloads)),
                          path: path})
    }
}
