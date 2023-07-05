/*
 * @Description:
 * @Version: 1.0
 * @Author: liyuanhao
 * @Date: 2023-05-09 19:05:47
 * @LastEditors: Please set LastEditors
 * @LastEditTime: 2023-06-29 16:18:02
 */

import QtQuick 2.5
import DesktopControls 0.1
import QtQuick.Dialogs 1.2

import "../Button"


ListView {
    id: root

    property var devices: []
    property var jsonFile

    focus: true
    implicitWidth: 200

    model: ListModel {}

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

    header: Rectangle {
        height: 32
        width: root.width
        color: "#8E8E8E"

        // 保存按钮
        AwesomeIcon {
            id: save
            anchors {
                verticalCenter: parent.verticalCenter
                right: batchAdd.left
                rightMargin: 5
            }

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
                addData()
            }
        } // BatchAddButton end

        Button {
            width: 80
            height: 32
            text: "设备导入"
            onClicked: {
                deviceDialog.open()
            }
        }
    } // header end

    delegate: Label {
        x: 3
        height: 27
        width: root.width
        text: type
        color: "black"
    }

    highlight: Rectangle {
        id: rowDelegate
        color: Qt.darker(Theme.current.accent, 1.5)
        Row {
            spacing: 3
            anchors {
                right: parent.right
                verticalCenter: parent.verticalCenter
                rightMargin: 10
            }

            // 移除按钮
            AwesomeButton {
                id: remove
                backgroundColor: rowDelegate.color
                iconColor: "black"
                name: "minus"
                onClicked: {
                    root.devices.splice(root.currentIndex, 1)
                    root.model.remove(root.currentIndex, 1)

                    mainWindow.signalUpdateDeviceInfo(devices)
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

    function addData() {
        var info = {
            "type": "设备_" + String(root.devices.length),
            "device_id": "device_" + String(createID()),
            "control_type": 0,
            "bus_type": 0,
            "ip": "",
            "send_port": "",
            "control_port": "",
            "rfm2g_id": "",
            "address": "",
            "input_icd": [],
            "output_icd": [],
        }
        root.devices.push(info)
        root.model.append({type: info.type})

        mainWindow.signalUpdateDeviceInfo(devices)
    }

    // 生成随机ID
    function createID() {
        const MAX = 65535
        const MIN = 0
        while(true) {
            var num = Math.floor(Math.random() * (MIN - MAX)) + MAX
            var flag = false
            for (var i in root.devices) {
                if (root.devices[i].device_id === num) {
                    flag = true
                    break
                }
            }

            if (!flag) {
                return num
            }
        }
    }

    // 导入设备信息
    function readJSONFile(path) {
        if (path === "") {
            return
        }

        jsonFile = Excutor.query({"read": path})

        var monitorDeviceType = jsonFile["monitor_device_type"]
        var deviceICDList = jsonFile["DeviceICDList"]

        for (var i in monitorDeviceType) {
            var device_id = monitorDeviceType[i].device_id
            var icdList = deviceICDList[device_id]
            var inputList = []
            var outputList = []
            for (var j in icdList) {
                if (icdList[j].type === "input") {
                    inputList.push(icdList[j].icd_id)
                }
                if (icdList[j].type === "output") {
                    outputList.push(icdList[j].icd_id)
                }
            }

            var info = {
                "type": monitorDeviceType[i].type,
                "device_id": device_id,
                "control_type": (()=> {
                                     if (monitorDeviceType[i].control_type === "controlled") {
                                         return 0
                                     }
                                     return 1
                                 })(),
                "bus_type": (()=> {
                                 if (monitorDeviceType[i].bus_type === "udp") {
                                     return 0
                                 }
                                 return 1
                             })(),
                "ip": monitorDeviceType[i].ip,
                "send_port": monitorDeviceType[i].send_port,
                "control_port": monitorDeviceType[i].control_port,
                "rfm2g_id": monitorDeviceType[i].rfm2g_id,
                "address": monitorDeviceType[i].address,
                // 附加信息
                "input_icd": inputList,
                "output_icd": outputList,
            }
            root.devices.push(info)
            root.model.append({type: info.type})
        }
        mainWindow.signalUpdateDeviceInfo(devices)
    }

    // 存储文件
    function saveJSONFile(path) {
        var monitorDeviceType = []
        for (var i in root.devices) {
            var info = {
                "type": root.devices[i].type,
                "device_id": root.devices[i].device_id,
                "control_type": (()=> {
                                     if (root.devices[i].control_type === 0) {
                                         return "controlled"
                                     }
                                     return "uncontrolled"
                                 })(),
                "bus_type": (()=> {
                                 if (root.devices[i].bus_type === 0) {
                                     return "udp"
                                 }
                                 return "反射内存"
                             })(),
                "ip": root.devices[i].ip,
                "send_port": root.devices[i].send_port,
                "control_port": root.devices[i].control_port,
                "rfm2g_id": root.devices[i].rfm2g_id,
                "address": root.devices[i].address
            }
            monitorDeviceType.push(info)
        }

        // 如果前期未导入JSON
        if (jsonFile === undefined) {
            jsonFile = {}
        }

        jsonFile["monitor_device_type"] = monitorDeviceType

        var deviceICDList = {}
        // 增加设置ICD信息
        for (var j in root.devices) {
            var bindICD = []
            // 处理input icd
            for (var x in root.devices[j].input_icd) {
                bindICD.push({"icd_id": root.devices[j].input_icd[x], "type": "input"})
            }
            for (var y in root.devices[j].output_icd) {
                bindICD.push({"icd_id": root.devices[j].output_icd[y], "type": "output"})
            }
            deviceICDList[root.devices[j].device_id] = bindICD
        }

        jsonFile["DeviceICDList"] = deviceICDList

        Excutor.query({"command": "write",
                          content: Excutor.formatJSON(JSON.stringify(jsonFile)),
                          path: path})
    }
}
