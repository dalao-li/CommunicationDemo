/*
 * @Description:
 * @Version: 1.0
 * @Author: liyuanhao
 * @Date: 2023-05-09 19:05:47
 * @LastEditors: Please set LastEditors
 * @LastEditTime: 2023-05-11 17:33:00
 */


import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2
import Qt.labs.settings 1.0
import DesktopControls 0.1 as Desktop


Item {
    id: root

    property int defaultHeight: 60
    property var _device

    // 列名枚举
    property var _INPUT_ICD_COLUMN: 0
    property var _OUPUT_ICD_COLUMN: 1
    property var _ICD_NAME_COLUMN: 2
    property var _ICD_ID_COLUMN: 3

    signal itemChanged(string id, string value)

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
    } // title end

    Grid {
        id: infoList
        anchors {
            left: parent.left
            leftMargin: 10
            top: title.bottom
            topMargin: 10
        }

        columns: 2
        rowSpacing: 15
        columnSpacing: 20

        // devicd type
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
                if (root._device) {
                    root._device.type = text
                    root.itemChanged("type", text)

                    root._device.type = text
                    root.itemChanged("type", text)
                }
            }
        }

        // device_id
        Label {
            text: "设备ID"
        }

        TextField {
            id: deviceID
            width: 300
            height: 25
            onTextChanged: {
                if (root._device) {
                    root._device.device_id = text
                    root.itemChanged("device_id", text)
                }
            }

        }

        // control type
        Label {
            text: "是否被控"
        }

        ComboBox {
            id: controlCombox
            width: 300
            height: 25

            model: ["是", "否"]

            onCurrentIndexChanged: {
                if (root._device) {
                    root._device.control_type = currentIndex
                    root.itemChanged("control_type", currentIndex)
                }
            }
        }

        // bus type
        Label {
            text: "bus_type"
        }

        ComboBox {
            id: busTypeCombox
            width: 300
            height: 25
            model: ["UDP", "反射内存卡"]

            onCurrentTextChanged: {
                // ip sendport
                if (currentIndex === 0) {
                    ipLabel.visible = true
                    sendPortLabel.visible = true
                    ipField.visible = true
                    sendPortField.visible = true

                    rfm2gLabel.visible = false
                    addressLabel.visible = false
                    rfm2gField.visible = false
                    addressField.visible = false
                }

                // rfm2g address
                if (currentIndex === 1) {
                    ipLabel.visible = false
                    sendPortLabel.visible = false
                    ipField.visible = false
                    sendPortField.visible = false

                    rfm2gLabel.visible = true
                    addressLabel.visible = true
                    rfm2gField.visible = true
                    addressField.visible = true
                }

                if (root._device) {
                    root._device.bus_type = currentIndex
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
            id: ipField
            width: 300
            height: 25
            onTextChanged: {
                if (root._device) {
                    root._device.ip = text
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
            id: sendPortField
            width: 300
            height: 25
            onTextChanged: {
                if (root._device) {
                    root._device.send_port = text
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
            id: rfm2gField
            visible: false
            width: 300
            height: 25
            onTextChanged: {
                if (root._device) {
                    root._device.rfm2g_id = text
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
            id: addressField
            visible: false
            width: 300
            height: 25
            onTextChanged: {
                if (root._device) {
                    root._device.address = text
                    root.itemChanged("address", text)
                }
            }
        }
    } // Grid end

    Rectangle {
        id: icdLabel
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

    TableView {
        id: table
        anchors {
            top: icdLabel.bottom
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

                property var validColumn: [_ICD_NAME_COLUMN, _ICD_ID_COLUMN].includes(styleData.column)

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

            // input icd 选择
            CheckBox {
                id: inputCheck
                anchors {
                    fill: parent
                    margins: 1
                }

                checked: styleData.value

                visible: styleData.column === _INPUT_ICD_COLUMN

                onClicked: {
                    if (root._device) {
                        // 勾选
                        var updateValue = {}
                        var nowICD = table.model.get(styleData.row).icdValue
                        if (checkedState === Qt.Checked) {
                            root._device.input_icd.push(nowICD)
                            updateValue = {"opeator": "add", "type": "input", "icd_id":nowICD}

                        }

                        // 取消
                        else {
                            var newList = []
                            for (var i = 0; i < root._device.input_icd.length; ++i) {
                                if (root._device.input_icd[i] !== nowICD) {
                                    newList.push(root._device.input_icd[i])
                                }
                            }
                            root._device.input_icd = newList
                            updateValue = {"opeator": "del", "type": "input", "icd_id": nowICD}
                        }

                        root.itemChanged("icd_info", JSON.stringify(updateValue))
                    }
                }
            } // CheckBox end

            // ouput icd选择
            CheckBox {
                id: ouputCheck
                anchors {
                    fill: parent
                    margins: 1
                }

                visible: styleData.column === _OUPUT_ICD_COLUMN

                checked: styleData.value

                onClicked: {
                    if (root._device) {
                        var nowICD = table.model.get(styleData.row).icdValue
                        var updateValue = {}
                        // 勾选
                        if (checkedState === Qt.Checked) {
                            if (styleData.column === _OUPUT_ICD_COLUMN) {
                                root._device.ouput_icd.push(nowICD)
                                updateValue = {"opeator": "add", "type": "ouput", "icd_id": nowICD}
                            }
                        }
                        // 取消
                        else {
                            var newList = []
                            for (var i = 0; i < root._device.ouput_icd.length; ++i) {
                                if (root._device.ouput_icd[i] !== nowICD) {
                                    newList.push(root._device.ouput_icd[i])
                                }
                            }
                            root._device.ouput_icd = newList
                            updateValue = {"opeator": "del", "type": "ouput", "icd_id": nowICD}
                        }
                        root.itemChanged("icd_info", JSON.stringify(updateValue))
                    }
                }
            }
        } // itemDelegate end

        TableViewColumn {
            id: isInput
            visible: true
            role: "isInput"
            title: "输入选择"
            width: 160
        }

        TableViewColumn {
            id: isOuput
            visible: true
            role: "isOuput"
            title: "输出选择"
            width: 80
        }

        TableViewColumn {
            id: icdName
            visible: true
            role: "icdName"
            title: "ICD名称"
            width: 100
        }

        TableViewColumn {
            id: icdValue
            visible: true
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
    } // end of TableView

    // 加载函数
    function load(value) {
        _device = value

        type.text = value.type
        deviceID.text = value.device_id

        controlCombox.currentIndex = value.control_type
        busTypeCombox.currentIndex = value.bus_type

        ipField.text = value.ip
        sendPortField.text = value.send_port

        rfm2gField.text = value.rfm2g_id
        addressField.text = value.address

        table.model.clear()
        // 查询当前所有icd
        for (var i in payloads) {
            var d = {
                // 判断该行input icd 是否已经被选择
                "isInput": (()=> {
                                for (var j in value.input_icd) {
                                    if (value.input_icd[j] === payloads[i].id) {
                                        return true
                                    }
                                }
                                return false
                            })(),
                // 判断该行ouput icd 是否已经被选择
                "isOuput": (()=> {
                                for (var j in value.ouput_icd) {
                                    if (value.ouput_icd[j] === payloads[i].id) {
                                        return true
                                    }
                                }
                                return false
                            })(),
                "icdName": payloads[i].name,
                "icdValue": String(payloads[i].id),
            }
            table.model.append(d)
        }
    }
}
