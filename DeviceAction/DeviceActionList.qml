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
                var info = {
                    "name": "动作" + String(root.actions.length),
                    "id": String(createID()),
                    "condition": [],
                    // 默认是选第一个设备
                    "device": devices[0],
                    // 默认绑首个ouput_icd
                    "bind_ouput_icd": devices[0].ouput_icd[0],

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
        // TODO 按设备划分, 同设备下的action放在一个actions里
        for (var i in data) {
            var res = {}
            var action = []

            // device_id
            var deviceID = data[i].device.device_id
            var ouputICD = data[i].bind_ouput_icd
            var name = data[i].name
            var condition = data[i].condition

            var resCondition = []
            // segment中的每一行数据
            // 分类规则为将同input_icd的分到一个{}里
            var temp = {}
            // "input_icd value" : [{"in_index": , "", "out_index": "...", "desc": "...", "difference": "..."], {...}}
            for (var j in condition) {
                var ouputICDIndex = condition[j].ouput_icd_index
                var inputICD = condition[j].input_icd
                var inputICDIndex = condition[j].input_icd_index
                var desc = condition[j].desc
                var difference = condition[j].difference

                // 如果这个input_icd已经存在, 就将数据存到它的值下
                if (temp.hasOwnProperty(inputICD)) {
                    temp[inputICD].push({"in_index": inputICDIndex, "out_index": ouputICDIndex, "desc": desc, "difference": difference})
                }
                else {
                    temp[inputICD] = []
                }
            }

            // 处理temp格式
            for (var k in temp) {
                var id = k
                var keys = temp[k]
                resCondition.push({"id": k, "keys": keys})
            }

            action.push({
                        "id": ouputICD, "name": name, "condition": resCondition

                        })

            dataList.push({"id": deviceID, "actions": action})
        }


        Excutor.query({"command": "write",
                          content: Excutor.formatJSON(JSON.stringify(dataList)),
                          path: path})
    }
}
