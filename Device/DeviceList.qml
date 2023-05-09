import QtQuick 2.5
import DesktopControls 0.1
import QtQuick.Dialogs 1.2

import "../Button"

ListView {
    id: root

    property var devices: []

    property var devicesJSON

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
            importDevice(path)
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
            saveDeviceInfo(path)
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
                // 一次增加的数量
                var max = 0
                // console.log("==========>", index)
                switch (index) {
                case -1:
                    max = 1
                    break;
                case 0: //5
                    max = 5
                    break;
                case 1: //10
                    max = 10
                    break;
                case 2: //20
                    max = 20
                    break;
                }
                for (var i=0; i<max; ++i) {
                    var info = {
                        "type": "设备_" + String(root.devices.length),
                        "device_id": "device_" + String(generateId()),
                        "control_type": 0,
                        "bus_type": 0,
                        "ip": "",
                        "send_port": "",
                        "control_port": "",
                        "rfm2g_id": "",
                        "address": "",
                        "input_icd": [],
                        "ouput_icd": [],
                    }
                    root.devices.push(info)
                    // 将信息添加入model
                    root.model.append(info)

                    mainWindow.gDeviceInfoAndICD.push({"type": info.type, "id": info.device_id, "input_icd":[]})
                }
            }
        } // BatchAddButton end

        // 导入按钮
        Button {
            width: 80
            height: 32
            text: "导入"
            onClicked: {
                deviceDialog.open()
            } // onClicked end
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

                    mainWindow.gDeviceInfoAndICD.splice(root.currentIndex, 1)
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

    function contains(id) {
        for (var i=0; i<root.devices.length; ++i) {
            if (root.devices[i].device_id === id) {
                return true
            }
            return false
        }
    }

    function generateId() {
        var i = root.devices.length;
        for (;;) {
            if (!contains(String(i))) return i
            ++i;
        }
    }

    // 导入设备信息
    function importDevice(path) {
        if (path === "") {
            return
        }

        // 读取JSON
        devicesJSON = Excutor.query({"read": path})

        deviceMonitorSettingJSON = devicesJSON

        var data = devicesJSON["monitor_device_type"]

        // console.log(JSON.stringify(data))
        for (var i in data) {
            var info = {
                "type": data[i].type,
                "device_id": data[i].device_id,
                "control_type": (()=> {
                                     if (data[i].control_type === "controlled") {
                                         return 0
                                     }
                                     return 1
                                 })(),
                "bus_type": (()=> {
                                 if (data[i].bus_type === "udp") {
                                     return 0
                                 }
                                 return 1
                             })(),
                "ip": data[i].ip,
                "send_port": data[i].send_port,
                "control_port": data[i].control_port,
                "rfm2g_id": data[i].rfm2g_id,
                "address": data[i].address,
                "input_icd": [],
                "ouput_icd": [],
            }

            // 将设备名与id写入全局device列表
            mainWindow.gDeviceInfoAndICD.push({"type": data[i].type, "id": data[i].device_id, "input_icd": []})

            root.devices.push(info)
            // 将信息添加入model
            root.model.append(info)
        }
    }

    function saveDeviceInfo(path) {
        var data = root.devices
        var dataList = []
        // 处理JSON
        for (var i in data) {
            var info = {
                "type": data[i].type,
                "device_id": data[i].device_id,
                "control_type": (()=> {
                                     if (data[i].control_type === 0) {
                                         return "controlled"
                                     }
                                     return "uncontrolled"
                                 })(),
                "bus_type": (()=> {
                                 if (data[i].bus_type === 0) {
                                     return "udp"
                                 }
                                 return "反射内存"
                             })(),
                "ip": data[i].ip,
                "send_port": data[i].send_port,
                "control_port": data[i].control_port,
                "rfm2g_id": data[i].rfm2g_id,
                "address": data[i].address
            }
            dataList.push(info)
        }

        devicesJSON["monitor_device_type"] = dataList

        var res = {}
        // 增加设置ICD信息
        for (var j in data) {
            var device_id = data[j].device_id
            var inputICDList = data[j].input_icd
            var ouputICDList = data[j].ouput_icd

            var deviceICD = []
            // 处理input icd
            for (var a in inputICDList) {
                deviceICD.push({"icd_id": inputICDList[a], "type": "input"})
            }
            for (var b in ouputICDList) {
                deviceICD.push({"icd_id": ouputICDList[b], "type": "ouput"})
            }
            res[device_id] = deviceICD
        }

        //console.log("------------->", JSON.stringify(res))

        devicesJSON["DeviceICDList"] = res

        Excutor.query({"command": "write",
                          content: Excutor.formatJSON(JSON.stringify(devicesJSON)),
                          path: path})
    }
}
