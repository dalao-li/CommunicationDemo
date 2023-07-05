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


Column {
    id: root
    width: 1000
    height: 1500
    spacing: 4;

    property int defaultHeight: 60
    property var _device

    // 列名枚举
    property var _INPUT_ICD_COLUMN: 0
    property var _OUTPUT_ICD_COLUMN: 1
    property var _ICD_NAME_COLUMN: 2
    property var _ICD_ID_COLUMN: 3

    signal itemChanged(string id, string value)

    // 标题
    Rectangle {
        id: title
        width: parent.width
        height: 32
        color: "#e5e5e5"

        Label {
            anchors.centerIn: parent
            text: "设备信息录入"
        }
    } // title end

    Grid {
        id: infoList
        width: parent.width
        height: 250

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
                if (!root._device) {
                    return
                }
                root._device.device_id = text
                root.itemChanged("device_id", text)
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
                if (!root._device) {
                    return
                }
                root._device.control_type = currentIndex
                root.itemChanged("control_type", currentIndex)
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
                    setBusType(true)
                }

                // rfm2g address
                if (currentIndex === 1) {
                    setBusType(false)
                }

                if (!root._device) {
                    return
                }
                root._device.bus_type = currentIndex
                root.itemChanged("bus_type", currentIndex)
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
                if (!root._device) {
                    return
                }
                root._device.ip = text
                root.itemChanged("ip", text)
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
                if (!root._device) {
                    return
                }
                root._device.send_port = text
                root.itemChanged("send_port", text)
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
                if (!root._device) {
                    return
                }
                root._device.rfm2g_id = text
                root.itemChanged("rfm2g_id", text)
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
                if (!root._device) {
                    return
                }
                root._device.address = text
                root.itemChanged("address", text)
            }
        }
    } // Grid end

    Rectangle {
        id: icdLabel
        width: parent.width
        height: 32

        color: "#8E8E8E"

        Label {
            anchors.centerIn: parent
            text: "ICD选择"
        }
    } // Rectangle end

    // 选择表格
    TableView {
        id: table
        width: parent.width
        height: 800

        frameVisible: false

        TableViewColumn {
            id: isInput
            visible: true
            role: "isInput"
            title: "输入选择"
            width: 200
        }

        TableViewColumn {
            id: isOutput
            visible: true
            role: "isOutput"
            title: "输出选择"
            width: 200
        }

        TableViewColumn {
            id: icdName
            visible: true
            role: "icdName"
            title: "ICD名称"
            width: 200
        }

        TableViewColumn {
            id: icdValue
            visible: true
            role: "icdValue"
            title: "ICD ID"
            width: 200
        }

        model: ListModel {}

        // 如何绘制每一个单元格
        itemDelegate: Item {
            Loader {
                anchors.fill: parent
                sourceComponent: {
                    if([_ICD_NAME_COLUMN, _ICD_ID_COLUMN].includes(styleData.column)) {
                        return labelComponent
                    }

                    if(styleData.column === _INPUT_ICD_COLUMN) {
                        return inputCheckComponent
                    }

                    if(styleData.column === _OUTPUT_ICD_COLUMN) {
                        return outputCheckComponent
                    }
                }
            }

            Component {
                id: labelComponent
                Label {
                    id: field
                    anchors {
                        fill: parent
                        margins: 1
                    }
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    visible: [_ICD_NAME_COLUMN, _ICD_ID_COLUMN].includes(styleData.column)

                    text: {
                        if (visible) {
                            return styleData.value
                        }
                        return ""
                    }
                }
            }

            Component {
                id: inputCheckComponent
                // input icd 选择
                CheckBox {
                    id: inputCheck
                    anchors {
                        fill: parent
                        margins: 1
                    }

                    visible: styleData.column === _INPUT_ICD_COLUMN

                    property var select: styleData.value

                    onSelectChanged: {
                        checked = select
                    }

                    onClicked: {
                        if (!root._device) {
                            return
                        }
                        var nowICD = table.model.get(styleData.row).icdValue
                        // 勾选
                        if (checkedState === Qt.Checked) {
                            root._device.input_icd.push(nowICD)
                        }
                        // 取消
                        else {
                            for (var i in root._device.input_icd) {
                                if (root._device.input_icd[i] === nowICD) {
                                    root._device.input_icd.splice(i, 1)
                                    break
                                }
                            }
                        }
                        root.itemChanged("input_icd", JSON.stringify({"icd": root._device.input_icd}))
                    }
                } // CheckBox end
            }
            Component {
                id: outputCheckComponent
                // ouput icd选择
                CheckBox {
                    id: ouputCheck
                    anchors {
                        fill: parent
                        margins: 1
                    }

                    implicitWidth: 20;
                    implicitHeight: 20;

                    visible: styleData.column === _OUTPUT_ICD_COLUMN

                    property var select: styleData.value

                    onSelectChanged: {
                        checked = select
                    }
                    onClicked: {
                        if (!root._device) {
                            return
                        }
                        var nowICD = table.model.get(styleData.row).icdValue
                        // 勾选
                        if (checkedState === Qt.Checked) {
                            root._device.output_icd.push(nowICD)
                        }
                        // 取消
                        else {
                            for (var i in root._device.output_icd) {
                                if (root._device.output_icd[i] === nowICD) {
                                    root._device.output_icd.splice(i, 1)
                                    break
                                }
                            }
                        }
                        root.itemChanged("output", JSON.stringify({"icd": root._device.output_icd}))
                    }
                }
            }
        } // itemDelegate end

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
        if (value === {} || value === undefined) {
            return
        }

        _device = value

        type.text = _device.type
        deviceID.text = _device.device_id

        controlCombox.currentIndex = _device.control_type
        busTypeCombox.currentIndex = _device.bus_type

        ipField.text = _device.ip
        sendPortField.text = _device.send_port

        rfm2gField.text = _device.rfm2g_id
        addressField.text = _device.address

        table.model.clear()


        // 选择表格
        for (var i in payloads) {
            table.model.append({
                                   // 判断该input icd 是否被选择
                                   "isInput": _device.input_icd.includes(payloads[i].id),
                                   // 判断该ouput icd 是否被选择
                                   "isOutput": _device.output_icd.includes(payloads[i].id),
                                   "icdName": payloads[i].name,
                                   "icdValue": String(payloads[i].id),
                               })
            //console.log("table", JSON.stringify(table.model.get(i)))
        }
    }

    function clear() {
        type.text = ""
        deviceID.text = ""

        table.model.clear()
    }

    // 设置UDP与反射内存卡
    function setBusType(flag) {
        ipLabel.visible = flag
        sendPortLabel.visible = flag
        ipField.visible = flag
        sendPortField.visible = flag

        rfm2gLabel.visible = !flag
        addressLabel.visible = !flag
        rfm2gField.visible = !flag
        addressField.visible = !flag
    }
}
