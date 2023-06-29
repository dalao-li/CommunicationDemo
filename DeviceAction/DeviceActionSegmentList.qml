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

    property var _OUPUT_ICD_INDEX_COLUMN: 0
    property var _INPUT_ICD_COLUMN: 1
    property var _INPUT_ICD_INDEX_COLUMN: 2
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

        frameVisible: false

        // 如何绘制每一个单元格
        itemDelegate: Item {

            // ouput_icd
            property var ouputICDList: getOuputICDList()

            // input_icd
            property var inputICDList: getInputICDList()

            // ouput_icd index
            property var ouputICDFieldList: {
                if (styleData.row === undefined || segments[styleData.row] === undefined || segments[styleData.row].ouput_icd_index === undefined) {
                    return []
                }
                return getFieldList(_bindOuputICD)
            }

            // input_icd index
            property var inputICDFieldList: {
                if (styleData.row === undefined || segments[styleData.row] === undefined || segments[styleData.row].input_icd_index === undefined) {
                    return []
                }
                return getFieldList(table.model.get(styleData.row).bind_input_icd)
            }

            Label {
                id: label
                anchors.fill: parent
                visible: !styleData.selected && [_OUPUT_ICD_INDEX_COLUMN, _INPUT_ICD_COLUMN, _INPUT_ICD_INDEX_COLUMN, _DIFFERENCE_COLUMN, _DESC_COLUMN].includes(styleData.column)

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

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

                    if (styleData.column === _OUPUT_ICD_INDEX_COLUMN) {
                        if (segment === [] || segment === undefined) {
                            return ""
                        }

                        for (var j in payloads) {
                            if (payloads[j].id === String(_bindOuputICD)) {
                                var value = payloads[j].values[styleData.value]
                                if (value === undefined) {
                                    return ""
                                }
                                return value.name
                            }
                        }
                    }

                    if (styleData.column === _INPUT_ICD_COLUMN) {
                        if (segment === [] || segment === undefined) {
                            return ""
                        }
                        for (var i in payloads) {
                            if (payloads[i].id === styleData.value) {
                                return payloads[i].name
                            }
                        }
                    }

                    if (styleData.column === _INPUT_ICD_INDEX_COLUMN) {
                        if (segment === [] || segment === undefined) {
                            return ""
                        }
                        for (var k in payloads) {
                            if (payloads[k].id === String(segment.bind_input_icd)) {
                                var values = payloads[k].values[styleData.value]
                                if (values === undefined) {
                                    return ""
                                }
                                return values.name
                            }
                        }
                    }

                    if (styleData.column === _DESC_COLUMN) {
                        return styleData.value
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

                visible: (styleData.column === _OUPUT_ICD_INDEX_COLUMN) && styleData.selected

                property var curIndex: {
                    // 防止页面首次加载时错误
                    if (styleData.row === undefined || segments[styleData.row] === undefined || segments[styleData.row].ouput_icd_index === undefined) {
                        return -1
                    }

                    for(var i in ouputICDFieldList){
                        if(String(segments[styleData.row].ouput_icd_index) === String(ouputICDFieldList[i].value)) {
                            return i
                        }
                    }
                    return -1
                }

                model: ouputICDFieldList

                currentIndex: curIndex

                onCurIndexChanged: {
                    currentIndex = curIndex
                }

                onCurrentIndexChanged: {
                    if (!visible || styleData.row === undefined || currentIndex < 0) {
                        return
                    }
                    //console.log("发送ouput index修改", currentIndex)
                    root.setValue(styleData.row, styleData.column, currentIndex)
                    //console.log("发送完修改信号", JSON.stringify(segments))
                }
            }

            // input_icd
            ComboBox {
                id: inputICDBox
                anchors {
                    fill: parent
                    margins: 1
                }

                visible: (styleData.column === _INPUT_ICD_COLUMN) && styleData.selected

                property var curIndex: {
                    for (var i in inputICDList) {
                        if (styleData.value === inputICDList[i].value) {
                            return i
                        }
                    }
                    return -1
                }

                model: inputICDList

                currentIndex: curIndex

                onCurIndexChanged: {
                    currentIndex = curIndex
                }

                onCurrentIndexChanged: {
                    if (!visible || styleData.row === undefined) {
                        return
                    }
                    root.setValue(styleData.row, styleData.column, payloads[currentIndex].id)
                }
            }

            // input_icd 中 index
            ComboBox {
                id: inputICDIndexBox
                anchors {
                    fill: parent
                    margins: 1
                }

                visible: (styleData.column === _INPUT_ICD_INDEX_COLUMN) && styleData.selected

                model: inputICDFieldList

                property var curIndex: {
                    for(var i in inputICDFieldList){
                        if(String(segments[styleData.row].input_icd_index) === String(inputICDFieldList[i].value)) {
                            return i
                        }
                    }
                    return -1
                }

                currentIndex: curIndex

                onCurIndexChanged: {
                    currentIndex = curIndex
                }

                onCurrentIndexChanged: {
                    if (!visible || styleData.row === undefined) {
                        return
                    }
                    root.setValue(styleData.row, styleData.column, currentIndex)
                }
            }

            TextField {
                id: descField
                anchors {
                    fill: parent
                    margins: 1
                }

                property var validColumn:  styleData.column === _DESC_COLUMN

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
        } // itemDelegate end

        TableViewColumn {
            id: ouputICDIndexCol
            visible: true
            role: "ouput_icd_index"
            title: "输出ICD中index"
            width: 160
        }

        TableViewColumn {
            id: inputICDCol
            visible: true
            role: "bind_input_icd"
            title: "输入ICD"
            width: 160
        }

        TableViewColumn {
            id: inputICDIndexCol
            visible: true
            role: "input_icd_index"
            title: "输入ICD中index"
            width: 160
        }

        TableViewColumn {
            id: differenceCol
            visible: true
            role: "difference"
            title: "difference"
            width: 100
        }

        TableViewColumn {
            id: descCol
            visible: true
            role: "desc"
            title: "描述"
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
        segments = values.condition

        _device = values.device
        _bindOuputICD = values.bind_ouput_icd

        batchAdd.enabled = true

        table.model.clear()
        for (var i in segments) {
            table.model.append({
                                   "index": segments[i].index,
                                   "ouput_icd_index": segments[i].ouput_icd_index,
                                   "bind_input_icd": segments[i].bind_input_icd,
                                   "input_icd_index": segments[i].input_icd_index,
                                   "difference": segments[i].difference,
                                   "desc": segments[i].desc
                               })
        }
    }

    // 增加新行
    function addSegment(row) {
        // console.log("add", JSON.stringify(_device))
        var info = {
            "index": String(row + 1),
            "ouput_icd_index": "0",
            // 默认绑定设备的input_icd的第一个
            "bind_input_icd": _device.input_icd[0],
            "input_icd_index": "0",
            "difference": 0,
            "desc": "",
            "ouputFieldList": getFieldList()
        }

        root.segments.splice(row + 1, 0, info)
        table.model.insert(row + 1, info)
    }

    function clear() {
        table.model.clear()
    }

    function updateBindOuputICD(newOuputICD) {
        _bindOuputICD = newOuputICD
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
        case _OUPUT_ICD_INDEX_COLUMN:
            segment.ouput_icd_index = String(value)
            table.model.setProperty(index, "ouput_icd_index", String(value))
            break

        case _INPUT_ICD_COLUMN:
            segment.bind_input_icd = String(value)
            table.model.setProperty(index, "bind_input_icd", String(value))

            // 同步修改input icd index
            break
        case _INPUT_ICD_INDEX_COLUMN:
            segment.input_icd_index = String(value)
            table.model.setProperty(index, "input_icd_index", String(value))
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
    function getFieldList(bind_icd) {
        var res = []
        for (var i in payloads) {
            if (String(bind_icd) === String(payloads[i].id)) {
                for (var j in payloads[i].values) {
                    var info = {
                        text: payloads[i].values[j].name,
                        value: payloads[i].values[j].index
                    }
                    res.push(info)
                }
            }
        }
        return res
    }

    function getInputICDList() {
        var icd = []
        // 遍历所有input_icd,获取他们的名称
        for (var i in _device.input_icd) {
            for (var j in payloads) {
                if (String(_device.input_icd[i]) === String(payloads[j].id)) {
                    var info = {
                        text: payloads[j].name,
                        value: payloads[j].id
                    }
                    icd.push(info)
                }
            }
        }
        return icd
    }

    function getOuputICDList() {
        var icd = []
        // 遍历所有ouput,获取他们的名称
        for (var i in _device.ouput_icd) {
            for (var j in payloads) {
                if (String(_device.ouput_icd[i]) === String(payloads[j].id)) {
                    var info = {
                        text: payloads[j].name,
                        value: payloads[j].id
                    }
                    icd.push(info)
                }
            }
        }
        return icd
    }
}
