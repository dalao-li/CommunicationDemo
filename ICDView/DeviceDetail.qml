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
            // enabled: false

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

                property var validColumn: [_INPUT_ICD_NAME_COLUMN, _OUPUT_ICD_NAME_COLUMN].includes(styleData.column)

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
                id: checkBox
                anchors {
                    fill: parent
                    margins: 1
                }

                checked: false

                property var validColumn: [_INPUT_ICD_COLUMN, _OUPUT_ICD_COLUMN].includes(styleData.column)

                visible: validColumn

                onCheckedChanged: {
                    console.log("行:", styleData.row, "列:", styleData.column, "check", checked)
                    if (root.device) {
                        // 如果是勾选
                        if (checked) {
                            // 判断是input 还是 ouput
                            if (styleData.column === _INPUT_ICD_COLUMN) {
                                root.device.input_icd.push(table.model[styleData.row].inputICD)
                                root.itemChanged("icd_info", {"opeator": "add", "type":"input", "icd_id": table.model[styleData.row].inputICD})
                            }

                            if (styleData.column === _OUPUT_ICD_COLUMN) {
                                root.device.input_icd.push(table.model[styleData.row].ouputICD)
                                root.itemChanged("icd_info", {"opeator": "add", "type":"ouput", "icd_id": table.model[styleData.row].ouputICD})
                            }

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
            id: input
            visible: false
            role: "inputICD"
            title: "输入选择"
            width: 160
        }

        TableViewColumn {
            id: ouput
            visible: false
            role: "ouputICD"
            title: "ICD名称"
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


//        Binding {
//            target: table
//            property: "model"
//            value: mainWindow.gICDInfoList
//        }
    } // end of TableView


    function load(value) {
        console.log("===>", JSON.stringify(value))
        device = value

        type.text = value.type
        deviceID.text = value.device_id

        isControl.currentIndex = value.control_type
        busType.currentIndex = value.bus_type

        ipInput.text = value.ip
        sendPortInput.text = value.send_port

        rfm2gInput.text = value.rfm2g_id
        addressInput.text = value.address

        for (var i in mainWindow.gICDInfoList) {
            // console.log("---------->", JSON.stringify(mainWindow.gICDInfoList[i]))
            table.model.append({
                                   // "isInput": false,
                                   "inputICDName": mainWindow.gICDInfoList[i].name,
                                   // "isOuput": false,
                                   "ouputICDName": mainWindow.gICDInfoList[i].name,

                                   "inputICD": mainWindow.gICDInfoList[i].icd_icd,
                                   "ouputICD": mainWindow.gICDInfoList[i].icd_icd
                               })
        }
    }
}
