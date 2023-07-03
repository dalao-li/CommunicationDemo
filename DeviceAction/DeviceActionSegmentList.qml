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

    property var outputICDInfo: getOuputICDInfo()

    // 列名枚举
    //property var _INPUT_ICD_COLUMN: 0
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

//        TableViewColumn {
//            id: inICDColumn
//            visible: true
//            role: "bind_input_icd"
//            title: "输入ICD"
//            width: 160
//        }

        TableViewColumn {
            id: inIndexColumn
            visible: true
            role: "in_index"
            title: "输入ICD中index"
            width: 160
        }

        TableViewColumn {
            id: bindOutputICDColumn
            visible: true
            role: "bind_output_icd"
            title: "输出ICD"
            width: 160
        }

        TableViewColumn {
            id: outIndexColumn
            visible: true
            role: "out_index"
            title: "输出ICD中index"
            width: 160
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
            width: 100
        }

        frameVisible: false

        // 如何绘制每一个单元格
        itemDelegate: Item {
            Label {
                id: label
                anchors.fill: parent
                visible: !styleData.selected || [_INPUT_ICD_INDEX_COLUMN, _OUTPUT_ICD_INDEX_COLUMN, _OUTPUT_ICD_COLUMN, _DIFFERENCE_COLUMN, _DESC_COLUMN].includes(styleData.column)

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                property var select: styleData.value

                property var segment: {
                    if (styleData.row === undefined) {
                        return []
                    }
                    return segments[styleData.row]
                }

                text: {
                    if (!visible) {
                        return ""
                    }

                    if (styleData.column === _INPUT_ICD_INDEX_COLUMN) {
                        if (segment === [] || segment === undefined) {
                            return ""
                        }
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
                        if (segment === [] || segment === undefined) {
                            return ""
                        }
                        for (var k in payloads) {
                            if (payloads[k].id === select) {
                                return payloads[k].name
                            }
                        }
                        return ""
                    }

                    if (styleData.column === _OUTPUT_ICD_INDEX_COLUMN) {
                        if (segment === [] || segment === undefined) {
                            return ""
                        }
                        for (var w in payloads) {
                            if (payloads[w].id === segment.bind_output_icd) {
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

            // input_icd 中 index
            ComboBox {
                id: inIndexBox
                anchors {
                    fill: parent
                    margins: 1
                }

                visible: styleData.selected && (styleData.column === _INPUT_ICD_INDEX_COLUMN)
                textRole: "text"

                property var fieldList: getFieldInfo(_bindInputICD)

                property var curIndex: {
                    if (styleData.row && table.model.get(styleData.row)) {
                        var inIndex = table.model.get(styleData.row).in_index
                        if (inIndex === undefined) {
                            return -1
                        }
                        for(var i in fieldList){
                            if(String(inIndex) === String(fieldList[i].value)) {
                                return i
                            }
                        }
                    }
                    return -1
                }

                model: fieldList

                currentIndex: curIndex

                onCurIndexChanged: {
                    currentIndex = curIndex
                }

                onCurrentIndexChanged: {
                    if (!visible || styleData.row === undefined) {
                        return
                    }
                    root.setValue(styleData.row, styleData.column, String(currentIndex))
                }
            }

            // output_icd
            ComboBox {
                id: inputICDBox
                anchors {
                    fill: parent
                    margins: 1
                }

                textRole: "text"
                visible: styleData.selected && (styleData.column === _OUTPUT_ICD_COLUMN)

                property var curIndex: {
                    if (styleData.row === undefined || table.model.get(styleData.row) === undefined) {
                        return -1
                    }

                    var outputICD = String(table.model.get(styleData.row).bind_output_icd)
                    for (var i in outputICDInfo) {
                        if (outputICD === outputICDInfo[i].value) {
                            return i
                        }
                    }
                    return -1
                }

                model: outputICDInfo

                currentIndex: curIndex

                onCurIndexChanged: {
                    currentIndex = curIndex
                }

                onCurrentIndexChanged: {
                    if (!visible || styleData.row === undefined) {
                        return
                    }
                    root.setValue(styleData.row, styleData.column, outputICDInfo[currentIndex].value)
                }
            }

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
                    if (styleData.row === undefined || table.model.get(styleData.row) === undefined) {
                        return
                    }

                    return getFieldInfo(table.model.get(styleData.row).bind_output_icd)
                }

                property var curIndex: {
                    // 防止页面首次加载时错误
                    if (styleData.row === undefined || segments[styleData.row] === undefined || segments[styleData.row].out_index === undefined) {
                        return -1
                    }

                    var outIndex = String(table.model.get(styleData.row).out_index)
                    for(var i in fieldList){
                        if(outIndex === fieldList[i].value) {
                            return i
                        }
                    }
                    return -1
                }

                model: fieldList

                currentIndex: curIndex

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

        var condition = values.actions.condition[0]
        var ouputICDID = condition.id
        segments = condition.keys
        for (var i in segments) {
            segments[i].bind_output_icd = ouputICDID
            var info = {
                "in_index": segments[i].in_index,
                "out_index": segments[i].out_index,
                "bind_output_icd": ouputICDID,
                "difference": segments[i].difference,
                "desc": segments[i].desc
            }

            console.log("segments", JSON.stringify(segments))
            table.model.append(info)
        }
    }

    // 增加新行
    function addSegment(row) {
        // console.log("add", JSON.stringify(_device))
        var info = {
            "index": String(row + 1),
            "in_index": "0",
            "out_index": "0",
            // 默认绑定设备的output_icd的第一个
            "bind_output_icd": _device.output_icd[0],
            "difference": "0",
            "desc": ""
        }

        root.segments.splice(row + 1, 0, info)
        table.model.insert(row + 1, info)
    }

    function clear() {
        table.model.clear()
    }

    function updateBindInputICD(newInputICD) {
        _bindInputICD = newInputICD
    }

    function updateDevice(newDevice) {
        _device = newDevice
    }

    // 获取枚举
    function getEnumdata(meaning) {
        segments[table.currentRow].keys = meaning
    }

    // 修改某行某列的值
    function setValue(index, column, value) {
        // console.log("修改信号", index, column, value)
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
            segment.difference = Number(value)
            table.model.setProperty(index, "difference", Number(value))
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
