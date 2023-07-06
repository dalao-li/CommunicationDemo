import QtQuick 2.5
import Qt.labs.settings 1.0
import QtQuick.Controls 1.4
import DesktopControls 0.1 as Desktop

import "../Button"

Item {
    id: root

    property var segments: []

    property var keysList: []

    property var _device: devices[0]

    property var _bindInputICD: devices[0].input_icd[0]

    property var outputICDInfo: getOuputICDInfo()

    property var _IN_INDEX_COMBOBOX_MODEL: []
    property var _IN_INDEX_COMBOBOX_INDEX: []

    property var _OUTPUT_ICD_COMBOBOX_MODEL: []
    property var _OUTPUT_ICD_COMBOBOX_INDEX: []

    property var _OUT_INDEX_COMBOBOX_MODEL: []
    property var _OUT_INDEX_COMBOBOX_INDEX: []

    // 列名枚举
    property var _INPUT_ICD_INDEX_COLUMN: 0
    property var _OUTPUT_ICD_COLUMN: 1
    property var _OUTPUT_ICD_INDEX_COLUMN: 2
    property var _DIFFERENCE_COLUMN: 3
    property var _DESC_COLUMN: 4

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

        TableViewColumn {
            id: inIndexColumn
            visible: true
            role: "in_index"
            title: "输入ICD中index"
            width: 200
        }

        TableViewColumn {
            id: bindOutputICDColumn
            visible: true
            role: "bind_output_icd"
            title: "输出ICD"
            width: 200
        }

        TableViewColumn {
            id: outIndexColumn
            visible: true
            role: "out_index"
            title: "输出ICD中index"
            width: 200
        }

        TableViewColumn {
            id: diffColumn
            visible: true
            role: "difference"
            title: "difference"
            width: 100
        }

        TableViewColumn {
            id: descColumn
            visible: true
            role: "desc"
            title: "描述"
            width: 200
        }

        frameVisible: false

        // 如何绘制每一个单元格
        itemDelegate: Item {
            // 加载
            Loader {
                anchors.fill: parent
                sourceComponent: {
                    if (styleData.selected) {
                        if (styleData.column === _DIFFERENCE_COLUMN) {
                            return textComponent
                        }

                        if (styleData.column === _INPUT_ICD_INDEX_COLUMN) {
                            return inIndexComboxComponent
                        }

                        if (styleData.column === _OUTPUT_ICD_COLUMN) {
                            return outputICDComboxComponent
                        }

                        if (styleData.column === _OUTPUT_ICD_INDEX_COLUMN) {
                            return outIndexComboxComponent
                        }

                        if (styleData.column === _DESC_COLUMN) {
                            return descTextComponent
                        }
                    }

                    else {
                        return labelComponent
                    }
                }
            }

            Component {
                id: labelComponent
                Label {
                    id: label
                    anchors.fill: parent
                    visible: !styleData.selected

                    // 设置居中
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    property var select: styleData.value

                    text: {
                        if (!visible || styleData.row < 0) {
                            return ""
                        }

                        if (styleData.column === _INPUT_ICD_INDEX_COLUMN) {
                            for (var i in payloads) {
                                if (payloads[i].id === String(_bindInputICD)) {
                                    var values = payloads[i].values[Number(select)]
                                    if (values === undefined) {
                                        return ""
                                    }
                                    return values.name
                                }
                            }
                            return ""
                        }

                        if (styleData.column === _OUTPUT_ICD_COLUMN) {
                            for (var k in payloads) {
                                if (payloads[k].id === select) {
                                    return payloads[k].name
                                }
                            }
                            return ""
                        }

                        if (styleData.column === _OUTPUT_ICD_INDEX_COLUMN) {
                            for (var w in payloads) {
                                if (payloads[w].id === segments[styleData.row].bind_output_icd) {
                                    var value1 = payloads[w].values[Number(select)]
                                    if (value1 === undefined) {
                                        return ""
                                    }
                                    return value1.name
                                }
                            }
                            return ""
                        }
                        return select
                    }
                }
            }

            Component {
                id: textComponent
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
            }

            Component {
                id: inIndexComboxComponent
                // input_icd 中 index
                ComboBox {
                    id: inIndexBox
                    anchors {
                        fill: parent
                        margins: 1
                    }

                    visible: styleData.selected && (styleData.column === _INPUT_ICD_INDEX_COLUMN)
                    textRole: "text"

                    property var curIndex: {
                        // 这里是新增数据的情况, 超过传入长度时默认是0
                        if (styleData.row > _IN_INDEX_COMBOBOX_INDEX.length) {
                            return 0
                        }
                        // 获取该行在model里的下标
                        return Number(_IN_INDEX_COMBOBOX_INDEX[styleData.row])
                    }

                    model: _IN_INDEX_COMBOBOX_MODEL

                    onCurIndexChanged: {
                        currentIndex = curIndex
                    }

                    onCurrentIndexChanged: {
                        if (!visible || styleData.row < 0) {
                            return
                        }
                        root.setValue(styleData.row, styleData.column, String(currentIndex))
                    }
                }
            }

            Component {
                id: outputICDComboxComponent
                // output_icd
                ComboBox {
                    id: outputICDBox
                    anchors {
                        fill: parent
                        margins: 1
                    }

                    textRole: "text"
                    visible: styleData.selected && (styleData.column === _OUTPUT_ICD_COLUMN)

                    property var curIndex: {
                        // 这里是新增数据的情况, 超过传入长度时默认是0
                        if (styleData.row > _OUTPUT_ICD_COMBOBOX_INDEX.length) {
                            return 0
                        }

                        return Number(_OUTPUT_ICD_COMBOBOX_MODEL[styleData.row])
                    }

                    model: _OUTPUT_ICD_COMBOBOX_MODEL


                    onCurIndexChanged: {
                        currentIndex = curIndex
                    }

                    onCurrentIndexChanged: {
                        if (!visible || styleData.row === undefined) {
                            return
                        }
                        root.setValue(styleData.row, styleData.column, _OUTPUT_ICD_COMBOBOX_MODEL[currentIndex].value)
                    }
                }
            }

            Component {
                id: outIndexComboxComponent
                // output_icd 中 index
                ComboBox {
                    id: typeBox
                    anchors {
                        fill: parent
                        margins: 1
                    }
                    textRole: "text"
                    visible: (styleData.column === _OUTPUT_ICD_INDEX_COLUMN) && styleData.selected

                    property var fieldList: {
                        var outputICD = _OUTPUT_ICD_COMBOBOX_MODEL[styleData.row].value
                        return getFieldInfo(outputICD)
                    }


                    property var curIndex: {
                        if (styleData.row > _OUT_INDEX_COMBOBOX_INDEX.length) {
                            return 0
                        }
                        return Number(_OUT_INDEX_COMBOBOX_INDEX[styleData.row])
                    }

                    model: {
                        if (styleData.row > _OUT_INDEX_COMBOBOX_MODEL.length) {
                            return _OUT_INDEX_COMBOBOX_MODEL[0]
                        }
                        return _OUT_INDEX_COMBOBOX_MODEL[styleData.row]
                    }

                    onCurIndexChanged: {
                        currentIndex = curIndex
                    }

                    onCurrentIndexChanged: {
                        if (!visible || styleData.row === undefined || currentIndex < 0) {
                            return
                        }
                        root.setValue(styleData.row, styleData.column, String(currentIndex))
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

                    property var validColumn: styleData.column === _DESC_COLUMN

                    visible: validColumn && styleData.selected

                    enabled: {
                        return true
                    }

                    text: {
                        if (validColumn) {
                            return styleData.value
                        }
                        return qsTr("")
                    }

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    onTextChanged: {
                        if (!visible || styleData.row === undefined) {
                            return
                        }
                        root.setValue(styleData.row, styleData.column, descField.text)
                    }
                } // TextField end
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
    function load(values, inIndexComboBoxModel, inIndexComboBoxIndex, outputICDComboBoxModel, outputICDComboBoxIndex, outIndexComboBoxModel, outIndexComboBoxIndex) {
        // 输出ICD中index
        _IN_INDEX_COMBOBOX_MODEL = inIndexComboBoxModel
        _IN_INDEX_COMBOBOX_INDEX = inIndexComboBoxIndex

        // 输出ICD
        _OUTPUT_ICD_COMBOBOX_MODEL = outputICDComboBoxModel
        _OUTPUT_ICD_COMBOBOX_INDEX = outputICDComboBoxIndex


        // 输出ICD中index
        _OUT_INDEX_COMBOBOX_MODEL = outIndexComboBoxModel
        _OUT_INDEX_COMBOBOX_INDEX = outIndexComboBoxIndex


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
    function setValue(index, column, value) {
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
            console.log("DeviceActionSegmentList getFieleList, bindICD is undefined")
            return []
        }
        // icd中values
        var values = (()=>{
                          for (var i in payloads) {
                              if (String(bindICD) === String(payloads[i].id)) {
                                  return payloads[i].values
                              }
                          }
                          return []
                      })()

        var result = []
        for (var i in values) {
            var info = {
                text: values[i].name,
                value: String(i)
            }
            result.push(info)
        }
        return result
    }

    // 获取OutputICD中名称与id
    function getOuputICDInfo() {
        var result = []
        for (var i in _device.output_icd) {
            for (var j in payloads) {
                if (String(_device.output_icd[i]) === String(payloads[j].id)) {
                    var info = {
                        text: payloads[j].name,
                        value: payloads[j].id
                    }
                    result.push(info)
                }
            }
        }
        return result
    }

    function getInputICDInfo() {
        var icdList = []
        for (var i in _device.input_icd) {
            for (var j in payloads) {
                if (String(_device.input_icd[i]) === String(payloads[j].id)) {
                    var info = {
                        text: payloads[j].name,
                        value: payloads[j].id
                    }
                    icdList.push(info)
                }
            }
        }
        return icdList
    }
}
