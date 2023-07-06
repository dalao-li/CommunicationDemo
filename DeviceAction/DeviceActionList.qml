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
                addData()
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

    function addData() {
        var info = {
            // 默认是选第一个设备
            "device": devices[0],
            "actions": {
                "name": "动作" + String(root.actions.length),
                // 默认绑首个input_icd
                "bind_input_icd": devices[0].input_icd[0],
                "keyList": [],
            }
        }
        root.actions.push(info)
        root.model.append({name: info.actions.name})
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

            for (var j in actions) {
                var condition = actions[j].condition
                var keyList = []

                for (var k in condition) {
                    var keys = condition[k].keys
                    var outputICD = condition[k].id
                    for (var m in keys) {
                        keyList.push({
                                         "bind_output_icd": outputICD,
                                         "in_index": keys[m].in_index,
                                         "out_index": keys[m].out_index,
                                         "difference": keys[m].difference,
                                         "desc": keys[m].desc

                                     })
                    }
                }

                var info = {
                    "name": actions[j].name,
                    "bind_input_icd": actions[j].id,
                    "keyList": keyList,
                }

                var resData = {
                    "device": mainWindow.getDevices(device_id),
                    "actions": info
                }

                root.actions.push(resData)
                root.model.append({"name": resData.actions.name})
            }


        }
    }

    // 导出
    function saveActionInfo(path) {
        var data = root.actions
        console.log("root.actions = ", JSON.stringify(root.actions))
        var dataList = []
        // TODO 按设备划分, 同设备下的action放在一个actions里
        for (var i in data) {
            var deviceID = data[i].device.device_id

            var actionList = []
            var actions = data[i].actions
            var inputICD = actions.bind_input_icd
            var name = actions.name
            var keyList = actions.keyList

            var condition = []
            var v = {}
            for (var j in keyList) {
                var id = keyList[j].bind_output_icd
                console.log("id = ", id)
                if (v.hasOwnProperty(id)) {
                    v[id].push({
                                        "in_index": keyList[j].in_index,
                                        "out_index": keyList[j].out_index,
                                        "difference": keyList[j].difference,
                                        "desc": keyList[j].desc
                                    })
                }
                else {
                    v[id] = []
                }
            }
            console.log("v", JSON.stringify(v))

            for (var k in v) {
                condition.push({
                                   "id": k,
                                   "keys": v[k]
                               })
            }


            actionList.push({
                                "id": inputICD,
                                "name": name,
                                "condition": condition
                            })
        }

        dataList.push({
                          "id": deviceID,
                          "actions": actionList
                      })




        Excutor.query({"command": "write",
                          content: Excutor.formatJSON(JSON.stringify(dataList)),
                          path: path})
    }
}
