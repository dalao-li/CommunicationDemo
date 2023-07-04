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

    // 导入文件
    FileDialog {
        id: actionDialog
        title: "Please choose a file"
        nameFilters: ["json files (*.json)", "All files (*)"]
        onAccepted: {
            var path = String(actionDialog.fileUrls).substring(8)
            readJSONFile(path)
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
                    //"id": String(createID()),

                    // 默认是选第一个设备
                    "device": devices[0],
                    "actions": {
                        "name": "动作" + String(root.actions.length),
                        // 默认绑首个input_icd
                        "bind_input_icd": devices[0].input_icd[0],
                        "condition": [
                            {
                                "id": devices[0].output_icd[0],
                                "keys": []
                            }
                        ],
                    }
                }
                root.actions.push(info)
                root.model.append({name: info.actions.name})
            }
        } // BatchAddButton end

        Button {
            width: 120
            height: 32
            text: "设备动作导入"
            onClicked: {
                actionDialog.open()
            } // onClicked end
        }
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

    // 导入设备动作信息
    function readJSONFile(path) {
        if (path === "") {
            return
        }

        var data = Excutor.query({"read": path})
        for (var i in data) {
            var device_id = data[i].id
            var actions = data[i].actions
            var info = {
                "name": actions[0].name,
                "bind_input_icd": actions[0].id,
                "condition": actions[0].condition,
            }

            var resData = {
                "device": (()=>{
                               for (var k in devices) {
                                   if (devices[k].device_id === device_id) {
                                       return devices[k]
                                   }
                               }
                           })(),
                "actions": info
            }

            root.actions.push(resData)
            root.model.append({"name": resData.actions.name})
        }
    }

    // 导出
    function saveActionInfo(path) {
        var data = root.actions
        var dataList = []
        // 处理JSON
        // TODO 按设备划分, 同设备下的action放在一个actions里
        for (var i in data) {
            console.log("data = ", JSON.stringify(data))
            var deviceID = data[i].device.device_id

            var actionList = []
            var actions = data[i].actions

            var inputICD = actions.bind_input_icd
            var name = actions.name

            var condList = []
            var condition = actions.condition
            for (var j in condition) {
                var outputICD = condition[j].id
                var keyList = []
                var keys = condition[j].keys
                for (var k in keys) {
                    keyList.push({
                                     "desc": keys[k].desc,
                                     "difference": keys[k].difference,
                                     "in_index": keys[k].in_index,
                                     "out_index": keys[k].out_index,
                                 })
                }

                condList.push({"id": condition[j].id, "keys": keyList})
            }
            actionList.push({"name": name, "id": inputICD, "condition": condList})

            dataList.push({
                              "id": deviceID,
                              "actions": actionList
                          })
        }


        Excutor.query({"command": "write",
                          content: Excutor.formatJSON(JSON.stringify(dataList)),
                          path: path})
    }
}
