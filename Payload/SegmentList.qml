/*
 * @Description:
 * @Version: 1.0
 * @Author: liyuanhao
 * @Date: 2023-05-09 19:05:47
 * @LastEditors: Please set LastEditors
 * @LastEditTime: 2023-05-11 17:33:00
 */


import QtQuick 2.5
import Qt.labs.settings 1.0
import QtQuick.Controls 1.4
import DesktopControls 0.1 as Desktop

import "../Button"

Item {
    id: root

    property var segments: []

    // 列名枚举
    property var _NAME_COLUMN: 0
    property var _OFFSET_COLUMN: 1
    property var _SIZE_COLUMN: 2
    property var _TYPE_COLUMN: 3
    property var _MASK_COLUMN: 4
    property var _ORDER_COLUMN: 5
    property var _DIM_COLUMN: 6
    property var _AMP_COLUMN: 7
    property var _BITSTART_COLUMN: 8
    property var _BIT_LENGTH_COLUMN: 9
    property var _DESC_COLUMN: 10
    property var _MEANING_COLUMN: 11

    property var _INDEX_COLUMN: 12

    // 数据类型枚举
    // "无符号整数", "单精度浮点", "双精度浮点", "字符串", "枚举", "有符号整数", "字符", "ASCII", "UNICODE"
    property var _UINT_TYPE: 0
    property var _FLOAT_TYPE: 1
    property var _DOUBLE_TYPE: 2
    property var _STR_TYPE: 3
    property var _ENUM_TYPE: 4
    property var _INT_TYPE: 5
    property var _CHAR_TYPE: 6
    property var _ASCII_TYPE: 7
    property var _UNICODE: 8

    signal itemChanged(string id, string value)

    // 表头
    Rectangle {
        id: title

        color: "#8E8E8E"

        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        height: 32

        Label {
            anchors.centerIn: parent
            text: "字段"
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
                enabled: false
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
                id: indexLabel
                anchors {
                    fill: parent
                    margins: 1
                }

                visible: true

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            TextField {
                id: field
                anchors {
                    fill: parent
                    margins: 1
                }

                property var validColumn: [_NAME_COLUMN, _MASK_COLUMN, _DESC_COLUMN].includes(styleData.column)

                visible: validColumn && styleData.selected

                text: {
                    if (validColumn) {
                        return styleData.value
                    }
                    return ""
                }

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                onTextChanged: {
                    if (!visible) {
                        return
                    }
                    root.updateValue(styleData.row, styleData.column, field.text)
                }
            } // TextField end

            ComboBox {
                id: typeBox
                anchors {
                    fill: parent
                    margins: 1
                }

                property var validColumn: styleData.column === _TYPE_COLUMN || styleData.column === _ORDER_COLUMN

                visible: validColumn && styleData.selected

                model: {
                    if (styleData.column === _TYPE_COLUMN) {
                        return ["无符号整数", "单精度浮点", "双精度浮点", "字符串", "枚举", "有符号整数", "字符", "ASCII", "UNICODE"]
                    }

                    if (styleData.column === _ORDER_COLUMN) {
                        return ["小端", "大端"]
                    }
                    return []
                }

                currentIndex: validColumn ? Number(styleData.value) : 0

                onCurrentIndexChanged: {
                    if (!visible) {
                        return
                    }
                    root.updateValue(styleData.row, styleData.column, typeBox.currentIndex)
                }
            }

            // 大小
            SpinBox {
                anchors {
                    fill: parent
                    margins: 1
                }

                property var validColumn: styleData.column === _OFFSET_COLUMN || styleData.column === _SIZE_COLUMN

                visible: styleData.selected && validColumn

                // enabled: styleData.selected && ![_UINT_TYPE, _DOUBLE_TYPE, _CHAR_TYPE].includes(segments[styleData.row].type)
                enabled: true

                value: validColumn ? Number(styleData.value) : 0

                maximumValue: 128
                minimumValue: styleData.column === 1 ? 0 : 1

                onValueChanged: {
                    if (!visible) {
                        return
                    }

                    root.updateValue(styleData.row, styleData.column, value)

                    if (styleData.column === _SIZE_COLUMN) {
                        root.updateValue(styleData.row, 4, getMask(value))
                        root.updateValue(styleData.row, 9, value * 8)
                    }
                    root.updateOffset(styleData.row)
                }
            }

            SpinBox {
                anchors {
                    fill: parent
                    margins: 1
                }

                property var validColumn: styleData.column === _DIM_COLUMN || styleData.column === _AMP_COLUMN

                visible: styleData.selected && validColumn

                value: validColumn ? Number(styleData.value) : 0

                maximumValue: 999999
                minimumValue: 0

                onValueChanged: {
                    if (!visible) {
                        return
                    }
                    root.updateValue(styleData.row, styleData.column, value)
                }
            }

            Button {
                id: enumBtn
                text: qsTr("枚举")
                anchors {
                    fill: parent
                    margins: 1
                }

                property var flag: {
                    return styleData.selected && styleData.column === _MEANING_COLUMN && (segments[styleData.row].type === _ENUM_TYPE)
                }

                visible: flag

                onClicked: {
                    var component = Qt.createComponent("SetEnumData.qml")
                    // console.debug("Error:"+ component.errorString() )
                    if (component.status === Component.Ready) {
                        var windows = component.createObject()
                        windows.show()
                        windows.rootPage = root

                        if (segments[styleData.row].meaning) {
                            // console.log("存在枚举", JSON.stringify(segments[styleData.row].meaning))
                            windows.setEunmInfos(segments[styleData.row].meaning)
                        }
                    }
                }
            }

            Label {
                id: label
                anchors.fill: parent
                visible: !styleData.selected || [_BITSTART_COLUMN, _BIT_LENGTH_COLUMN].includes(styleData.column)

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                text: {
                    if (!visible) {
                        return ""
                    }

                    if (styleData.column === _NAME_COLUMN || styleData.column === _DESC_COLUMN) {
                        return String(styleData.value)
                    }

                    if (styleData.column === _TYPE_COLUMN) {
                        var dts = ["无符号整数", "单精度浮点", "双精度浮点", "字符串", "枚举", "有符号整数", "字符", "ASCII", "UNICODE"]
                        return dts[Number(styleData.value)]
                    }

                    if (styleData.column === _ORDER_COLUMN) {
                        return Number(styleData.value) === 0 ? "小端" : "大端"
                    }

                    return String(JSON.stringify(styleData.value))
                }
            }
        } // itemDelegate end

        property var columsVisible: {
            var apppath = Excutor.query({ "apppath": "" })
            var config = Excutor.query({ "read": apppath + "/config/persistence.soft" })
            return config.payload_editor.segments
        }

        TableViewColumn {
            id: nameCol
            visible: table.columsVisible[0]
            role: "name"
            title: "名称"
            width: 160
        }

        TableViewColumn {
            id: offsetCol
            visible: table.columsVisible[1]
            role: "offset"
            title: "偏移"
            width: 80
        }

        TableViewColumn {
            id: sizeCol
            visible: table.columsVisible[2]
            role: "size"
            title: "大小"
            width: 80
        }

        TableViewColumn {
            id: typeCol
            visible: table.columsVisible[3]
            role: "type"
            title: "类型"
            width: 100
        }

        TableViewColumn {
            id: maskCol
            visible: table.columsVisible[4]
            role: "mask"
            title: "掩码"
            width: 100
        }

        TableViewColumn {
            id: orderCol
            visible: table.columsVisible[5]
            role: "order"
            title: "大/小端"
            width: 80
        }

        TableViewColumn {
            id: dimCol
            visible: table.columsVisible[6]
            role: "dim"
            title: "量纲"
            width: 80
        }

        TableViewColumn {
            id: ampCol
            visible: table.columsVisible[7]
            role: "amp"
            title: "幅值"
            width: 80
        }

        TableViewColumn {
            id: bitstartCol
            visible: table.columsVisible[8] && 0
            role: "bitstart"
            title: "bitstart"
            width: 80
        }

        TableViewColumn {
            id: bitlengthCol
            visible: table.columsVisible[9] && 0
            role: "bitlength"
            title: "bitlength"
            width: 80
        }

        TableViewColumn {
            id: descCol
            visible: table.columsVisible[10]
            role: "desc"
            title: "描述"
            width: 250
        }

        TableViewColumn {
            id: enumdataCol
            visible: table.columsVisible[11]
            role: "meaning"
            title: "枚举值"
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
        batchAdd.enabled = true

        table.model.clear()
        // 按共享传递
        segments = values
        for (var i in values) {
            table.model.append({
                                   "index": values[i].index,
                                   "name": values[i].name,
                                   "offset": values[i].offset,
                                   "size": values[i].size,
                                   "mask": values[i].mask,
                                   "order": values[i].order,
                                   "type": values[i].type,
                                   "desc": values[i].desc,
                                   "dim": values[i].dim,
                                   "amp": values[i].amp,
                                   "meaning": values[i].meaning
                               })
        }
    }

    // 增加新行
    function addSegment(row) {
        if (row === -1) {
            var offset = 0
        } else {
            var preInfo = table.model.get(row)
            // 获取当前行偏移值
            offset = Number(preInfo.offset) + Number(preInfo.size)
        }

        var info = {
            "name": "工程值" + String(row + 1),
            "offset": offset,
            "size": 4,
            "mask": getMask(4),
            "order": 0,
            "type": 0,
            "desc": "描述",
            "dim": 1,
            "amp": 0,
            "meaning": {},
            "index": String(row + 1),
        }
        root.segments.splice(row + 1, 0, info)
        table.model.insert(row + 1, info)

        root.updateOffset(row + 1)
    }

    // 修改偏移量值
    function updateOffset(startRow) {
        for (var row = startRow + 1; row < table.model.count; row++) {
            var preInfo = table.model.get(row - 1)
            var offset = Number(preInfo.offset) + Number(preInfo.size)
            root.updateValue(row, 1, offset)
        }
    }

    function getMask(num) {
        var res = "0x"
        for (var i = 0; i < num; i++) {
            res += "ff"
        }
        return res
    }

    function getEnumdata(meaning) {
        segments[table.currentRow].meaning = meaning
    }

    // 修改某行某列的值
    function updateValue(index, column, value) {
        if (index < 0 || column < 0) {
            return
        }

        var segment = root.segments[index]
        switch (column) {
            // name
        case _NAME_COLUMN:
            segment.name = value
            table.model.setProperty(index, "name", value)
            break
            // offset
        case _OFFSET_COLUMN:
            segment.offset = Number(value)
            table.model.setProperty(index, "offset", Number(value))
            break
            // size
        case _SIZE_COLUMN:
            segment.size = Number(value)
            table.model.setProperty(index, "size", Number(value))
            break
            // int型、enum型、uint型、char型需要设置掩码
        case _TYPE_COLUMN:
            //type
            segment.type = Number(value)

            table.model.setProperty(index, "type", Number(value))
            // 修改mask
            if ([_UINT_TYPE, _ENUM_TYPE, _INT_TYPE, _CHAR_TYPE].includes(segment.type)) {
                segment.mask = getMask(segment.size)
            } else {
                segment.mask = ""
            }

            table.model.setProperty(index, "mask", segment.mask)

            // 修改size
            if (segment.type === _FLOAT_TYPE) {
                segment.size = 4
                //SpinBox.enabled = true
            }
            if (segment.type === _DOUBLE_TYPE) {
                segment.size = 8
                //SpinBox.enabled = false
            }
            if (segment.type === _CHAR_TYPE) {
                segment.size = 1
                //SpinBox.enabled = false
            }
            table.model.setProperty(index, "size", segment.size)
            break
        case _MASK_COLUMN:
            if ([_UINT_TYPE, _ENUM_TYPE, _INT_TYPE, _CHAR_TYPE].includes(segment.type)) {
                segment.mask = value
                table.model.setProperty(index, "mask", value)
            }
            break
        case _ORDER_COLUMN:
            //order
            segment.order = Number(value)
            table.model.setProperty(index, "order", Number(value))
            break
        case _DIM_COLUMN:
            //dim
            segment.dim = Number(value)
            table.model.setProperty(index, "dim", Number(value))
            break
        case _AMP_COLUMN:
            //amp
            segment.amp = Number(value)
            table.model.setProperty(index, "amp", Number(value))
            break
        case _BITSTART_COLUMN:
            //bit_start
            table.model.setProperty(index, "bit_start", Number(value))
            break
        case _BIT_LENGTH_COLUMN:
            //bit_length
            table.model.setProperty(index, "bit_length", Number(value))
            break
        case _DESC_COLUMN:
            //desc
            segment.desc = value
            table.model.setProperty(index, "desc", value)
            break
        case _MEANING_COLUMN:
            // meaning
            if (segment.type === _ENUM_TYPE) {
                segment.meaning = value
                table.model.setProperty(index, "meaning", value)
                break
            }
        }
        root.segments[index] = segment
    }

    function persist(index, state) {
        var apppath = Excutor.query({ "apppath": "" })

        var file = apppath + "/config/persistence.soft"

        var config = Excutor.query({"read": file })
        config.payload_editor.segments[index] = state

        Excutor.query({
                          "command": "write",
                          "path": file,
                          "content": Framework.formatJSON(JSON.stringify(config))
                      })
    }
}
