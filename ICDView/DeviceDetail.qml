import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import Qt.labs.settings 1.0
import DesktopControls 0.1 as Desktop


Item {
    id: root

    property int defaultHeight: 60
    property var device

    // 修改信号
    signal itemChanged(string id, string value)

    property var _INPUT_ICD_COLUMN: 0
    property var _INPUT_ICD_NAME_COLUMN: 1
    property var _OUPUT_ICD_COLUMN: 2
    property var _OUPUT_ICD_NAME_COLUMN: 3
    property var _ICD_ID_COLUMN: 4

    // 标题
    Rectangle {
        id: title
        anchors {
            left: parent.left
            right: parent.right
        }
        height: 32
        color: "#e5e5e5"

        Label {
            anchors.centerIn: parent
            text: "设备信息录入"
        }

        // 点击折叠
        MouseArea {
            anchors.fill: parent
            onClicked: {
                if (root.height === defaultHeight) {
                    root.height = title.height
                } else {
                    root.height = defaultHeight
                }

                !flow.visible
            }
        }
    } // title end

    Grid {
        id: infoList
        anchors {
            left: parent.left
            leftMargin: 10
            top: title.bottom
            topMargin: 10
        }

        // 每行两列
        columns: 2
        // 15行
        rowSpacing: 15
        columnSpacing: 20

        // 外部输入设备名称
        Label {
            text: "设备名称"
            horizontalAlignment: Text.AlignLeft
            verticalAlignment: Text.AlignVCenter
        }

        TextField {
            id: type
            width: 300
            height: 25
            onTextChanged: {
                if (root.device) {
                    root.device.type = text
                    root.itemChanged("type", text)

                    // 修改gDeviceInfoAndICD中的值
                    for (var i in mainWindow.gDeviceInfoAndICD) {
                        if (mainWindow.gDeviceInfoAndICD[i].id === root.device.device_id) {
                            mainWindow.gDeviceInfoAndICD[i].type = text
                            break
                        }
                    }
                }
            }
        }

        // 根据设备名称生成ID
        Label {
            text: "设备ID"
        }

        TextField {
            id: deviceID
            width: 300
            height: 25
            onTextChanged: {
                if (root.device) {

                    // 修改gDeviceInfoAndICD中的值
                    for (var i in mainWindow.gDeviceInfoAndICD) {
                        if (mainWindow.gDeviceInfoAndICD[i].id === root.device.device_id) {
                            mainWindow.gDeviceInfoAndICD[i].id = text
                            break
                        }
                    }

                    root.device.device_id = text
                    root.itemChanged("device_id", text)
                }
            }

        }

        // 选择是否被控
        Label {
            text: "是否被控"
        }

        ComboBox {
            id: isControl
            width: 300
            height: 25
            model: ["是", "否"]
            onCurrentIndexChanged: {
                if (root.device) {
                    root.device.control_type = currentIndex
                    root.itemChanged("control_type", currentIndex)
                }
            }
        }

        //
        Label {
            text: "bus_type"
        }

        ComboBox {
            id: busType
            width: 300
            height: 25
            model: ["UDP", "反射内存卡"]

            onCurrentTextChanged: {
                // ip sendport
                if (currentIndex === 0) {
                    ipLabel.visible = true
                    sendPortLabel.visible = true
                    ipInput.visible = true
                    sendPortInput.visible = true

                    rfm2gLabel.visible = false
                    addressLabel.visible = false
                    rfm2gInput.visible = false
                    addressInput.visible = false
                }

                // rfm2g address
                if (currentIndex === 1) {
                    ipLabel.visible = false
                    sendPortLabel.visible = false
                    ipInput.visible = false
                    sendPortInput.visible = false

                    rfm2gLabel.visible = true
                    addressLabel.visible = true
                    rfm2gInput.visible = true
                    addressInput.visible = true
                }

                if (root.device) {
                    root.device.bus_type = currentIndex
                    root.itemChanged("bus_type", currentIndex)
                }
            }
        }

        // IP
        Label {
            id: ipLabel
            text: "IP"
        }

        TextField {
            id: ipInput
            width: 300
            height: 25
            onTextChanged: {
                if (root.device) {
                    root.device.ip = text
                    root.itemChanged("ip", text)
                }
            }
        }

        // send port
        Label {
            id: sendPortLabel
            text: "SendPort"
        }

        TextField {
            id: sendPortInput
            width: 300
            height: 25
            onTextChanged: {
                if (root.device) {
                    root.device.send_port = text
                    root.itemChanged("send_port", text)
                }
            }
        }

        // rfm2g
        Label {
            id: rfm2gLabel
            text: "rfm2g"
            visible: false
        }

        TextField {
            id: rfm2gInput
            visible: false
            width: 300
            height: 25
            onTextChanged: {
                if (root.device) {
                    root.device.rfm2g_id = text
                    root.itemChanged("rfm2g_id", text)
                }
            }
        }

        // address
        Label {
            id: addressLabel
            visible: false
            text: "address"
        }

        TextField {
            id: addressInput
            visible: false
            width: 300
            height: 25
            onTextChanged: {
                if (root.device) {
                    root.device.address = text
                    root.itemChanged("address", text)
                }
            }
        }
    } // Grid end


    // 表头
    Rectangle {
        id: icdTitle
        anchors {
            left: parent.left
            right: parent.right
            top: infoList.bottom
            topMargin: 10
        }

        color: "#8E8E8E"

        height: 32

        Label {
            anchors.centerIn: parent
            text: "ICD选择"
        }
    } // Rectangle end

    // 除表头之外的表格内容
    TableView {
        id: table
        anchors {
            top: icdTitle.bottom
            // bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        frameVisible: false

        // 如何绘制每一个单元格
        itemDelegate: Item {
            Label {
                id: field
                anchors {
                    fill: parent
                    margins: 1
                }

                property var validColumn: [_INPUT_ICD_NAME_COLUMN, _OUPUT_ICD_NAME_COLUMN, _ICD_ID_COLUMN].includes(styleData.column)

                visible: validColumn

                text: {
                    if (validColumn) {
                        return styleData.value
                    }
                    return ""
                }

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            } // TextField end

            CheckBox {
                id: inputCheck
                anchors {
                    fill: parent
                    margins: 1
                }

                checked: {
                    //console.log("输入选择," ,table.model.get(styleData.row).isOuputCheck)
                    return table.model.get(styleData.row).isInputCheck
                }

                property var validColumn: [_INPUT_ICD_COLUMN].includes(styleData.column)

                visible: validColumn

                onCheckedChanged: {
                    if (root.device) {
                        // 如果是勾选
                        var icdID = table.model.get(styleData.row).icdValue
                        if (checked) {
                            root.device.input_icd.push(icdID)
                            root.itemChanged("icd_info", JSON.stringify({"opeator": "add", "type": "input", "icd_id": icdID}))
                        }

                        if (!checked) {
                            var newList = []
                            for (var i = 0; i < root.device.input_icd.length; ++i) {
                                if (root.device.input_icd[i] !== icdID) {
                                    newList.push(root.device.input_icd[i])
                                }
                            }
                            root.device.input_icd = newList
                            root.itemChanged("icd_info", JSON.stringify({"opeator": "del", "type": "input", "icd_id": icdID}))
                        }

                        // 修改gDeviceInfoAndICD中的值
                        for (var i in mainWindow.gDeviceInfoAndICD) {
                            if (mainWindow.gDeviceInfoAndICD[i].id === root.device.device_id) {
                                mainWindow.gDeviceInfoAndICD[i].input_icd = root.device.input_icd
                                break
                            }
                        }
                    }
                }
            }

            CheckBox {
                id: ouputCheck
                anchors {
                    fill: parent
                    margins: 1
                }

                property var validColumn: [_OUPUT_ICD_COLUMN].includes(styleData.column)

                visible: validColumn

                checked: {
                    //console.log("输出选择," ,table.model.get(styleData.row).isOuputCheck)
                    return table.model.get(styleData.row).isOuputCheck
                }

                onCheckedChanged: {
                    if (root.device) {
                        // 如果是勾选
                        var icdID = table.model.get(styleData.row).icdValue
                        if (checked) {
                            if (styleData.column === _OUPUT_ICD_COLUMN) {
                                root.device.ouput_icd.push(icdID)
                                root.itemChanged("icd_info", JSON.stringify({"opeator": "add", "type": "ouput", "icd_id": icdID}))
                            }
                        }

                        if (!checked) {
                            var newList = []
                            for (var i = 0; i < root.device.ouput_icd.length; ++i) {
                                if (root.device.ouput_icd[i] !== icdID) {
                                    newList.push(root.device.ouput_icd[i])
                                }
                            }
                            root.device.ouput_icd = newList
                            root.itemChanged("icd_info", JSON.stringify({"opeator": "del", "type": "ouput", "icd_id": icdID}))
                        }
                    }
                }
            }
        } // itemDelegate end

        TableViewColumn {
            id: isInput
            visible: table.columsVisible[0]
            role: "isInput"
            title: "输入选择"
            width: 160
        }

        TableViewColumn {
            id: inputICD
            visible: table.columsVisible[1]
            role: "inputICDName"
            title: "ICD名称"
            width: 80
        }

        TableViewColumn {
            id: isOuput
            visible: table.columsVisible[2]
            role: "isOuput"
            title: "输出选择"
            width: 80
        }

        TableViewColumn {
            id: ouputICDName
            visible: table.columsVisible[3]
            role: "ouputICDName"
            title: "ICD名称"
            width: 100
        }

        TableViewColumn {
            id: icdValue
            visible: table.columsVisible[4]
            role: "icdValue"
            title: "ICD id"
            width: 80
        }

        model: ListModel {}

        // 行背景
        rowDelegate: Item {
            height: 25

            Rectangle {
                height: styleData.selected ? 25 : 1
                width: parent.width
                anchors.bottom: parent.bottom

                color: Qt.darker(Desktop.Theme.current.accent, 1.5)

                visible: styleData.selected
            }

            Rectangle {
                height: 1
                width: parent.width
                anchors.bottom: parent.bottom

                color: Qt.darker(Desktop.Theme.current.accent, 1.5)

                border.color: Desktop.Theme.current.section
            }
        } // end of rowDelegate
        //        }
    } // end of TableView

    function load(value) {
        // console.log("===>", JSON.stringify(value))
        device = value

        type.text = value.type
        deviceID.text = value.device_id

        isControl.currentIndex = value.control_type
        busType.currentIndex = value.bus_type

        ipInput.text = value.ip
        sendPortInput.text = value.send_port

        rfm2gInput.text = value.rfm2g_id
        addressInput.text = value.address

        table.model.clear()
        for (var i in mainWindow.gICDInfoList) {
            var nowLineICDId = mainWindow.gICDInfoList[i].icd_id
            var nowLineICDName = mainWindow.gICDInfoList[i].name
            var d = {
                "isInputCheck": (()=> {
                                   for (var j in value.input_icd) {
                                       if (value.input_icd[j] === nowLineICDId) {
                                           return true
                                       }
                                   }
                                   return false
                               })(),
                "inputICDName": nowLineICDName,
                "isOuputCheck": (()=> {
                                   for (var j in value.ouput_icd) {
                                       if (value.ouput_icd[j] === nowLineICDId) {
                                           return true
                                       }
                                   }
                                   return false
                               })(),
                "ouputICDName": nowLineICDName,
                "icdValue": nowLineICDId,
            }
            table.model.append(d)
        }
    }
}
