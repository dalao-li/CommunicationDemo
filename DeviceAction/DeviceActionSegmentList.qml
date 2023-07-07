import QtQuick 2.5
import Qt.labs.settings 1.0
import QtQuick.Controls 1.4
import DesktopControls 0.1 as Desktop

import "../Button"

Item {
    id: root

    property var segments: []

    property var _device: devices[0]

    property var _bindInputICD: devices[0].input_icd[0]

    // TableView列名枚举
    property var _INPUT_ICD_INDEX_COLUMN: 0
    property var _OUTPUT_ICD_COLUMN: 1
    property var _OUTPUT_ICD_INDEX_COLUMN: 2
    property var _DIFFERENCE_COLUMN: 3
    property var _DESC_COLUMN: 4

    signal itemChanged(string id, string value)

    signal ouputICDChanged()

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

    // 表格内容
    TableView {
        id: table
        anchors {
            top: title.bottom
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        TableViewColumn { id: inIndexColumn; visible: true; role: "in_index"; title: "输入ICD中index"; width: 200 }
        TableViewColumn { id: bindOutputICDColumn; visible: true; role: "bind_output_icd"; title: "输出ICD"; width: 200 }
        TableViewColumn { id: outIndexColumn; visible: true; role: "out_index"; title: "输出ICD中index"; width: 200 }
        TableViewColumn { id: diffColumn; visible: true; role: "difference"; title: "difference"; width: 100}
        TableViewColumn { id: descColumn; visible: true; role: "desc"; title: "描述"; width: 200 }

        frameVisible: false

        itemDelegate: Item {
            Loader {
                anchors.fill: parent
                sourceComponent: loadCompoent(styleData.column)
            }

            property var currentRow: styleData.row
            property var currentColumn: styleData.column
            property var currentValue: styleData.value

            property var _IN_INDEX_INFO: {
                return getFieldInfo(_bindInputICD)
            }

            property var _OUTPUT_ICD_INFO: {
                return getOuputICDInfo(_device.output_icd)
            }

            property var _OUTPU_ICD_INDEX_INFO: {
                if (styleData.row < 0) {
                    return
                }
                var icd = table.model.get(styleData.row).bind_output_icd
                return getFieldInfo(icd)
            }

            Component {
                id: labelComponent
                Label {
                    id: label
                    anchors.fill: parent
                    // 设置居中
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    visible: !styleData.selected

                    text: {
                        if (!visible || styleData.row < 0) {
                            return ""
                        }

                        // input icd index列
                        if (styleData.column === _INPUT_ICD_INDEX_COLUMN) {
                            var icdIndex = Number(styleData.value)
                            if (icdIndex < 0 || icdIndex > _IN_INDEX_INFO.length) {
                                return ""
                            }
                            return _IN_INDEX_INFO[icdIndex].text
                        }

                        // ouput_icd
                        if (styleData.column === _OUTPUT_ICD_COLUMN) {
                            for (var i in _OUTPUT_ICD_INFO) {
                                if (_OUTPUT_ICD_INFO[i].value === styleData.value) {
                                    return _OUTPUT_ICD_INFO[i].text
                                }
                            }
                            return ""
                        }

                        if (styleData.column === _OUTPUT_ICD_INDEX_COLUMN) {
                            var outIndex = Number(styleData.value)
                            if (outIndex < 0 || outIndex > _OUTPU_ICD_INDEX_INFO.length) {
                                return ""
                            }
                            return _OUTPU_ICD_INDEX_INFO[Number(styleData.value)].text
                        }
                        return styleData.value
                    }
                }
            }

            Component {
                id: textComponent
                TextField {
                    id: field
                    anchors { fill: parent; margins: 1 }
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    visible: styleData.column === _DIFFERENCE_COLUMN && styleData.selected

                    text: { return styleData.value }

                    onTextChanged: {
                        if (!visible || styleData.row < 0) {
                            return
                        }
                        root.updateValue(styleData.row, styleData.column, field.text)
                    }
                } // TextField end
            }

            Component {
                id: inIndexComboxComponent
                // input_icd 中 index
                ComboBox {
                    id: inIndexBox
                    anchors { fill: parent; margins: 1 }

                    visible: styleData.selected && (styleData.column === _INPUT_ICD_INDEX_COLUMN)
                    textRole: "text"

                    property var curIndex: {
                        if (styleData.row < 0 || segments[styleData.row] === undefined) {
                            return -1
                        }
                        return Number(segments[styleData.row].in_index)
                    }

                    model: _IN_INDEX_INFO

                    onCurIndexChanged: {
                        currentIndex = curIndex
                    }

                    onActivated: {
                        if (!visible || styleData.row < 0) {
                            return
                        }
                        root.updateValue(styleData.row, styleData.column, String(currentIndex))
                    }
                }
            }

            Component {
                id: outputICDComboxComponent
                // output_icd
                ComboBox {
                    id: outputICDCombox
                    anchors {
                        fill: parent
                        margins: 1
                    }

                    textRole: "text"
                    visible: styleData.selected && (styleData.column === _OUTPUT_ICD_COLUMN)

                    property var curIndex: {
                        if (styleData.row < 0 || segments[styleData.row] === undefined) {
                            return -1
                        }

                        var icd = segments[styleData.row].bind_output_icd
                        for (var i in _OUTPUT_ICD_INFO) {
                            if (icd === _OUTPUT_ICD_INFO[i].value) {
                                return i
                            }
                        }
                        return -1
                    }

                    model: _OUTPUT_ICD_INFO

                    onCurIndexChanged: {
                        currentIndex = curIndex
                    }

                    onActivated: {
                        if (!visible || styleData.row < 0) {
                            return
                        }
                        root.updateValue(styleData.row, styleData.column, _OUTPUT_ICD_INFO[currentIndex].value)
                        ouputICDChanged()
                    }
                }
            }

            Component {
                id: outIndexComboxComponent
                // output_icd 中 index
                ComboBox {
                    id: outIndexCombox
                    anchors {
                        fill: parent
                        margins: 1
                    }
                    textRole: "text"
                    visible: (styleData.column === _OUTPUT_ICD_INDEX_COLUMN) && styleData.selected

                    property var curIndex: {
                        if (styleData.row < 0 || segments[styleData.row] === undefined) {
                            return -1
                        }
                        return Number(segments[styleData.row].out_index)
                    }

                    model: _OUTPU_ICD_INDEX_INFO

                    onCurIndexChanged: {
                        currentIndex = curIndex
                    }

                    onActivated: {
                        if (!visible || currentIndex < 0) {
                            return
                        }
                        root.updateValue(styleData.row, styleData.column, String(currentIndex))
                    }

                    Connections {
                        target: root
                        onOuputICDChanged: {
                            root.updateValue(styleData.row, styleData.column, String(-1))
                            outIndexCombox.currentIndex = -1
                        }
                    }
                }
            }

            Component {
                id: descTextComponent
                TextField {
                    id: descField
                    anchors {
                        fill: parent
                        margins: 1
                    }

                    visible: styleData.column === _DESC_COLUMN && styleData.selected

                    enabled: { return true }

                    text: { return styleData.value }

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    onTextChanged: {
                        if (!visible || styleData.row < 0) {
                            return
                        }
                        root.updateValue(styleData.row, styleData.column, descField.text)
                    }
                } // TextField end
            }

            function loadCompoent(column) {
                if (!styleData.selected) {
                    return labelComponent
                }

                if (column === _DIFFERENCE_COLUMN) {
                    return textComponent
                }

                if (column === _INPUT_ICD_INDEX_COLUMN) {
                    return inIndexComboxComponent
                }

                if (column === _OUTPUT_ICD_COLUMN) {
                    return outputICDComboxComponent
                }

                if (column === _OUTPUT_ICD_INDEX_COLUMN) {
                    return outIndexComboxComponent
                }

                if (styleData.column === _DESC_COLUMN) {
                    return descTextComponent
                }
            }
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

        table.model.clear()
        batchAdd.enabled = true

        _device = values.device
        _bindInputICD = values.actions.bind_input_icd

        segments = values.actions.keyList
        for (var i in segments) {
            table.model.append(segments[i])
        }
    }

    // 增加新行
    function addSegment(row) {
        var info = {
            //"index": String(row + 1),
            "in_index": "0",
            "out_index": "0",
            // 默认绑定设备的output_icd的第一个
            "bind_output_icd": _device.output_icd[0],
            "difference": "0",
            "desc": ""
        }

        root.segments.push(info)
        table.model.append(info)
    }

    function clear() {
        root.segments = []
        table.model.clear()
    }

    function updateBindInputICD(newInputICD) {
        _bindInputICD = newInputICD
    }

    function updateDevice(newDevice) {
        _device = newDevice
    }

    function getEnumdata(meaning) {
        segments[table.currentRow].keys = meaning
    }

    // 修改某行某列的值
    function updateValue(index, column, value) {
        if (index < 0 || column < 0) {
            return
        }

        var segment = root.segments[index]
        switch (column) {
        case _INPUT_ICD_INDEX_COLUMN:
            segment.in_index = value
            table.model.setProperty(index, "in_index", value)
            break
        case _OUTPUT_ICD_INDEX_COLUMN:
            segment.out_index = value
            table.model.setProperty(index, "out_index", value)
            break
        case _OUTPUT_ICD_COLUMN:
            segment.bind_output_icd = value
            table.model.setProperty(index, "bind_output_icd", value)
            break
        case _DIFFERENCE_COLUMN:
            segment.difference = value
            table.model.setProperty(index, "difference", value)
            break
        case _DESC_COLUMN:
            segment.desc = value
            table.model.setProperty(index, "desc", value)
            break
        }
        root.segments[index] = segment
    }

    // 根据ICD获取field
    function getFieldInfo(bindICD) {
        if (bindICD === undefined) {
            console.log("DeviceActionSegmentList, getFieleList, bindICD is undefined")
            return []
        }
        var payload = mainWindow.getPayLoads(bindICD)
        var info = []
        for (var i in payload.values) {
            info.push({
                          text: payload.values[i].name,
                          value: String(i)
                      })
        }
        return info
    }

    // 获取OutputICD中名称与id
    function getOuputICDInfo(outputICDList) {
        var info = []
        for (var i in outputICDList) {
            var payload = mainWindow.getPayLoads(outputICDList[i])
            info.push({
                          text: payload.name,
                          value: payload.id
                      })
        }
        return info
    }
}
