import QtQuick 2.5
import Qt.labs.settings 1.0
import QtQuick.Controls 1.4
import DesktopControls 0.1 as Desktop

import "../Button"

Item {
    id: root

    signal itemChanged(string id, string value)

    property var segments

    property var __NAME_COLUMN: 0
    property var __OFFSET_COLUMN: 1
    property var __SIZE_COLUMN: 2
    property var __TYPE_COLUMN: 3
    property var __MASK_COLUMN: 4
    property var __ORDER_COLUMN: 5
    property var __DIM_COLUMN: 6
    property var __AMP_COLUMN: 7
    property var __BITSTART_COLUMN: 8
    property var __BIT_LENGTH_COLUMN: 9
    property var __DESC_COLUMN: 10
    property var __MEANING_COLUMN: 11

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
            TextField {
                id: field
                anchors {
                    fill: parent
                    margins: 1
                }

                // property var validColumn: styleData.column === __NAME_COLUMN || styleData.column === __MASK_COLUMN || styleData.column === DESC_COLUMN

                property var validColumn: [__NAME_COLUMN, __MASK_COLUMN, __DESC_COLUMN].includes(styleData.column)

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
                    root.setValue(styleData.row, styleData.column, field.text)
                }
            } // TextField end

            ComboBox {
                id: typeBox
                anchors {
                    fill: parent
                    margins: 1
                }

                property var validColumn: styleData.column === __TYPE_COLUMN || styleData.column === __ORDER_COLUMN

                visible: validColumn && styleData.selected

                model: {
                    if (styleData.column === __TYPE_COLUMN) {
                        return ["无符号整数", "单精度浮点", "双精度浮点", "字符串", "枚举", "有符号整数", "字符", "ASCII", "UNICODE"]
                    }

                    if (styleData.column === __ORDER_COLUMN) {
                        return ["小端", "大端"]
                    }
                    return []
                }

                currentIndex: validColumn ? Number(styleData.value) : 0

                onCurrentIndexChanged: {
                    if (!visible) {
                        return
                    }
                    root.setValue(styleData.row, styleData.column, typeBox.currentIndex)
                }
            }

            // 大小
            SpinBox {
                anchors {
                    fill: parent
                    margins: 1
                }

                property var validColumn: styleData.column === __OFFSET_COLUMN || styleData.column === __SIZE_COLUMN

                visible: styleData.selected && validColumn

                enabled: {
                    return styleData.selected && !(segments[styleData.row].type === 1 || segments[styleData.row].type === 2 || segments[styleData.row].type === 6)
                }

                value: validColumn ? Number(styleData.value) : 0

                maximumValue: 128
                minimumValue: styleData.column === 1 ? 0 : 1

                onValueChanged: {
                    if (!visible) {
                        return
                    }

                    root.setValue(styleData.row, styleData.column, value)

                    if (styleData.column === 2) {
                        root.setValue(styleData.row, 4, getMask(value))
                        root.setValue(styleData.row, 9, value * 8)
                    }
                    root.updateOffset(styleData.row)
                }
            }

            SpinBox {
                anchors {
                    fill: parent
                    margins: 1
                }

                property var validColumn: styleData.column === 6 || styleData.column === 7

                visible: styleData.selected && validColumn

                value: validColumn ? Number(styleData.value) : 0

                maximumValue: 999999
                minimumValue: 0

                onValueChanged: {
                    if (!visible) {
                        return
                    }
                    root.setValue(styleData.row, styleData.column, value)
                }
            }

            Button {
                id: enumBtn
                text: qsTr("枚举")
                anchors {
                    fill: parent
                    margins: 1
                }

                property var validColumn: styleData.column === 11

                visible: validColumn && styleData.selected && (segments[styleData.row].type === 4)

                onClicked: { 
                    var component = Qt.createComponent("SetEnumData.qml")
                    // console.debug("Error:"+ component.errorString() )
                    if (component.status === Component.Ready) {
                        var win = component.createObject()
                        win.show()
                        win.rootPage = root

                        if (segments[styleData.row].meaning) {
                            //存在枚举值
                            console.log("存在枚举", JSON.stringify(segments[styleData.row].meaning))
                            win.setEunmInfos(segments[styleData.row].meaning)
                        }
                    }
                }
            }

            Label {
                id: label
                anchors.fill: parent
                visible: !styleData.selected || styleData.column === __BITSTART_COLUMN || styleData.column === __BIT_LENGTH_COLUMN

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                text: {
                    if (!visible) {
                        return ""
                    }

                    if (styleData.column === __NAME_COLUMN || styleData.column === __DESC_COLUMN) {
                        return String(styleData.value)

                    }

                    if (styleData.column === __TYPE_COLUMN) {
                        var dts = ["无符号整数", "单精度浮点", "双精度浮点", "字符串", "枚举", "有符号整数", "字符", "ASCII", "UNICODE"]
                        return dts[Number(styleData.value)]
                    }

                    if (styleData.column === __ORDER_COLUMN) {
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
                        //root.itemChanged()
                    }
                }
            }
        } // end of rowDelegate
    } // end of TableView


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
            "btnvisible": false
        }
        root.segments.splice(row + 1, 0, info)

        table.model.insert(row + 1, info)

        root.updateOffset(row + 1)
    }

    // 修改偏移量值
    function updateOffset(startRow) {
        var count = table.model.count
        var row = startRow + 1

        for (; row < count; row++) {
            var preInfo = table.model.get(row - 1)
            var offset = Number(preInfo.offset) + Number(preInfo.size)
            root.setValue(row, 1, offset)
        }
    }

    function getMask(N) {
        var ff = "0x"
        for (var i = 0; i < N; i++) {
            ff += "ff"
        }
        return ff
    }

    function getEnumdata(meaning) {
        // 修改枚举JSON值为 {枚举值:枚举名}
        console.log("保存枚举", JSON.stringify(meaning))
        segments[table.currentRow].meaning = meaning
    }

    // 加载列表数据
    function load(values) {
        batchAdd.enabled = true

        table.model.clear()

        segments = values
        for (var i in values) {
            table.model.append({
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

    // 修改某行某列的值
    function setValue(index, column, value) {
        if (index < 0 || column < 0) {
            return
        }

        var segment = root.segments[index]
        switch (column) {
        // name
        case 0:
            segment.name = value
            table.model.setProperty(index, "name", value)
            break
        // offset
        case 1:
            segment.offset = Number(value)
            table.model.setProperty(index, "offset", Number(value))
            break
        // size
        case 2:
            segment.size = Number(value)
            table.model.setProperty(index, "size", Number(value))
            break
        // int型、enum型、uint型、char型需要设置掩码
        case 3:
            //type
            segment.type = Number(value)

            table.model.setProperty(index, "type", Number(value))
            // 修改mask
            if (segment.type === 0 || segment.type === 4 || segment.type === 5 || segment.type === 6) {
                segment.mask = getMask(segment.size)
            } else {
                segment.mask = ""
            }

            table.model.setProperty(index, "mask", segment.mask)

            // 修改size
            if (segment.type === 1) {
                segment.size = 4
                //SpinBox.enabled = true
            }
            if (segment.type === 2) {
                segment.size = 8
                //SpinBox.enabled = false
            }
            if (segment.type === 6) {
                segment.size = 1
                //SpinBox.enabled = false
            }
            table.model.setProperty(index, "size", segment.size)
            break
        // mask
        case 4:
            if (segment.type === 0 || segment.type === 4 || segment.type === 5 || segment.type === 6) {
                segment.mask = value
                table.model.setProperty(index, "mask", value)
            }
            break
        case 5:
            //order
            segment.order = Number(value)
            table.model.setProperty(index, "order", Number(value))
            break
        case 6:
            //dim
            segment.dim = Number(value)
            table.model.setProperty(index, "dim", Number(value))
            break
        case 7:
            //amp
            segment.amp = Number(value)
            table.model.setProperty(index, "amp", Number(value))
            break
        case 8:
            //bit_start
            table.model.setProperty(index, "bit_start", Number(value))
            break
        case 9:
            //bit_length
            table.model.setProperty(index, "bit_length", Number(value))
            break
        case 10:
            //desc
            segment.desc = value
            table.model.setProperty(index, "desc", value)
            break
        case 11:
            // meaning
            if (segment.type === 4) {
                segment.meaning = value
                table.model.setProperty(index, "meaning", value)
                break
            }
        }
        // console.log('-->', JSON.stringify(segment))
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
