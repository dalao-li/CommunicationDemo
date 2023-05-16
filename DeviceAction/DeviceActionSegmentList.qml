import QtQuick 2.5
import Qt.labs.settings 1.0
import QtQuick.Controls 1.4
import DesktopControls 0.1 as Desktop

import "../Button"

Item {
    id: root

    property var segments: []

    property var _device

    property var _bindOuputICD

    property var _TYPE_ID_COLUMN: 0
    property var _OUPUT_ICD_INDEX_COLUMN: 1
    property var _INPUT_ICD_COLUMN: 2
    property var _INPUT_ICD_INDEX_COLUMN: 3
    property var _DIFFERENCE_COLUMN: 4
    property var _KEYS_COLUMN: 5

    signal itemChanged(string id, string value)

    // 表头
    Rectangle {
        id: title
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        color: "#8E8E8E"

        height: 32

        Label {
            anchors.centerIn: parent
            text: "动作信息"
        }

        // 右上角增加按钮
        Row {
            anchors {
                verticalCenter: parent.verticalCenter
                right: parent.right
                rightMargin: 10
            }

            BatchAddButton {
                id: batchAdd
                enabled: true
                anchors.verticalCenter: parent.verticalCenter
                onClicked: {
                    addSegment(table.rowCount - 1)
                }
            }
        }
    } // Rectangle end

    // 除表头之外的表格内容
    TableView {
        id: table
        anchors {
            top: title.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        frameVisible: false

        // 如何绘制每一个单元格
        itemDelegate: Item {
            Label {
                id: label
                anchors.fill: parent
                visible: !styleData.selected || [_TYPE_ID_COLUMN, _OUPUT_ICD_INDEX_COLUMN, _INPUT_ICD_COLUMN, _INPUT_ICD_INDEX_COLUMN].includes(styleData.column)

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                text: {
                    if (!visible) {
                        return ""
                    }

                    if (styleData.column === _TYPE_ID_COLUMN) {
                        return String(styleData.value)

                    }

                    if (styleData.column === _OUPUT_ICD_INDEX_COLUMN) {
                        var paload = payloads[_bindOuputICD]
                        return paload.values[segments[styleData.row].ouput_icd_index].name
                    }

                    if (styleData.column === _INPUT_ICD_COLUMN) {
                        return payloads[segments[styleData.row].bind_input_icd].name
                    }

                    if (styleData.column === _INPUT_ICD_INDEX_COLUMN) {
                        var values = payloads[segments[styleData.row].bind_input_icd].values
                        return values[segments[styleData.row].input_icd_index].name
                    }

                    return Number(styleData.value)
                }
            }

            TextField {
                id: field
                anchors {
                    fill: parent
                    margins: 1
                }

                property var validColumn: styleData.column === _DIFFERENCE_COLUMN

                visible: validColumn && styleData.selected

                text: {
                    if (validColumn) {
                        return styleData.value
                    }
                    return qsTr("")
                }

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                onTextChanged: {
                    if (!visible) {
                        return
                    }
                    root.setValue(styleData.row, styleData.column, field.text)
                }
            } // TextField end

            // ouput_icd 中 index
            ComboBox {
                id: typeBox
                anchors {
                    fill: parent
                    margins: 1
                }

                property var validColumn: styleData.column === _OUPUT_ICD_INDEX_COLUMN

                visible: validColumn && styleData.selected

                currentIndex: validColumn ? Number(styleData.value) : 0

                onCurrentIndexChanged: {
                    if (!visible) {
                        return
                    }
                    root.setValue(styleData.row, styleData.column, currentIndex)
                }

                model: {
                    var res = []
                    for (var i in payloads[_bindOuputICD].values) {
                        res.push(payloads[_bindOuputICD].values[i].name)
                    }
                    return res
                }
            }

            // input_icd
            ComboBox {
                id: inputICDBox
                anchors {
                    fill: parent
                    margins: 1
                }



                property var validColumn: styleData.column === _INPUT_ICD_COLUMN

                visible: validColumn && styleData.selected

                currentIndex: validColumn ? Number(styleData.value) : 0

                onCurrentIndexChanged: {
                    if (!visible) {
                        return
                    }
                    root.setValue(styleData.row, styleData.column, currentIndex)
                }

                model: {
                    var res = []
                    var device = devices[_device]
                    for (var m in device.input_icd) {
                        for (var n in payloads) {
                            if (device.input_icd[m] === payloads[n].id) {
                                res.push(payloads[n].name)
                            }
                        }
                    }
                    return res
                }
            }

            // input_icd 中 index
            ComboBox {
                id: inputICDIndexBox
                anchors {
                    fill: parent
                    margins: 1
                }

                property var validColumn: styleData.column === _INPUT_ICD_INDEX_COLUMN

                visible: validColumn && styleData.selected

                currentIndex: validColumn ? Number(styleData.value) : 0

                onCurrentIndexChanged: {
                    if (!visible) {
                        return
                    }
                    root.setValue(styleData.row, styleData.column, currentIndex)
                }

                model: {
                    var res = []
                    var payload = payloads[segments[styleData.row].bind_input_icd]
                    for (var j in payload.values) {
                        res.push(payload.values[j].name)
                    }
                    return res
                }
            }

            // 添加condition
            Button {
                id: enumBtn
                text: qsTr("添加Keys")
                anchors {
                    fill: parent
                    margins: 1
                }

                visible: styleData.column === _KEYS_COLUMN && styleData.selected

                onClicked: {
                    var component = Qt.createComponent("DeviceActionEnumData.qml")
                    if (component.status === Component.Error) {
                        console.debug("Error:"+ component.errorString())
                        return
                    }
                    if (component.status === Component.Ready) {
                        var win = component.createObject()
                        win.show()
                        win.rootPage = root

                        // 存在枚举值
                        if (segments[styleData.row].condition) {
                            win.setEunmInfos(segments[styleData.row].condition)
                        }
                    }
                }
            }
        } // itemDelegate end

        TableViewColumn {
            id: typeIDCol
            visible: table.columsVisible[_TYPE_ID_COLUMN]
            role: "index"
            title: "TypeID"
            width: 100
        }

        TableViewColumn {
            id: ouputICDIndexCol
            visible: table.columsVisible[_OUPUT_ICD_INDEX_COLUMN]
            role: "ouput_icd_index"
            title: "输出ICD中index"
            width: 160
        }

        TableViewColumn {
            id: inputICDCol
            visible: table.columsVisible[_INPUT_ICD_COLUMN]
            role: "bind_input_icd"
            title: "输入ICD"
            width: 160
        }

        TableViewColumn {
            id: inputICDIndexCol
            visible: table.columsVisible[_INPUT_ICD_INDEX_COLUMN]
            role: "input_icd_index"
            title: "输入ICD中index"
            width: 160
        }

        TableViewColumn {
            id: differenceCol
            visible: table.columsVisible[_DIFFERENCE_COLUMN]
            role: "difference"
            title: "difference"
            width: 100
        }

        TableViewColumn {
            id: keysColumn
            visible: table.columsVisible[_KEYS_COLUMN]
            role: ""
            title: "keys"
            width: 100
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

            Row {
                spacing: 3
                visible: styleData.selected

                anchors.verticalCenter: parent.verticalCenter
                x: table.width - 55

                // 每一行最后的两个加减按钮
                IconButton {
                    id: add
                    name: "plus"
                    color: "black"
                    onClicked: {
                        addSegment(table.currentRow)
                    }
                }

                IconButton {
                    id: remove
                    name: "minus"
                    color: "black"
                    onClicked: {
                        root.segments.splice(table.currentRow, 1)
                        table.model.remove(table.currentRow, 1)
                    }
                }
            }
        } // end of rowDelegate
    } // end of TableView


    // 加载列表数据
    function load(values) {
        _device = values.device
        _bindOuputICD = values.bind_ouput_icd
        segments = values.condition

        batchAdd.enabled = true

        table.model.clear()
        for (var i in segments) {
            table.model.append({
                                   "index": segments[i].index,
                                   "ouput_icd_index": segments[i].ouput_icd_index,
                                   "bind_input_icd": segments[i].bind_input_icd,
                                   "input_icd_index": segments[i].input_icd_index,
                                   "difference": segments[i].difference,
                                   "keys": segments[i].keys
                               })
        }
    }

    // 增加新行
    function addSegment(row) {
        var info = {
            "index": String(row + 1),
            "ouput_icd_index": 0,
            "bind_input_icd": 0,
            "input_icd_index": 0,
            "difference": 0,
            "keys": []
        }

        root.segments.splice(row + 1, 0, info)
        table.model.insert(row + 1, info)
    }

    // 获取枚举
    function getEnumdata(meaning) {
        segments[table.currentRow].condition = meaning
    }

    // 修改某行某列的值
    function setValue(index, column, value) {
        // console.log("修改信号", index, column, value)
        if (index < 0 || column < 0) {
            return
        }

        var segment = root.segments[index]
        switch (column) {
        case _OUPUT_ICD_INDEX_COLUMN:
            segment.ouput_icd_index = Number(value)
            table.model.setProperty(index, "ouput_icd_index", Number(value))
            break

        case _INPUT_ICD_COLUMN:
            segment.bind_input_icd = Number(value)
            table.model.setProperty(index, "bind_input_icd", Number(value))
            break
        case _INPUT_ICD_INDEX_COLUMN:
            segment.input_icd_index = Number(value)
            table.model.setProperty(index, "input_icd_index", Number(value))
           break

        case _DIFFERENCE_COLUMN:
            segment.difference = Number(value)
            table.model.setProperty(index, "difference", Number(value))
            break

        }
        root.segments[index] = segment
        // console.log("修改完后", JSON.stringify(segments))
    }
}
