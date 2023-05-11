/*
 * @Description:
 * @Version: 1.0
 * @Author: liyuanhao
 * @Date: 2023-05-09 19:05:47
 * @LastEditors: Please set LastEditors
 * @LastEditTime: 2023-05-10 14:52:15
 */

import QtQuick 2.5
import Qt.labs.settings 1.0
import QtQuick.Controls 1.4
import DesktopControls 0.1 as Desktop

import "../Button"

Item {
    id: root

    property var segments: []
    property var _canUseICD : []
    property var _deviceID

    property int _TYPE_ID_COLUMN: 0
    property var _BIND_ICD_COLUMN: 1
    property var _FIELD_INDEX_COLUMN: 2
    property var _TYPE_COLUMN: 3
    property var _TYPE_NAME_COLUMN: 4
    property var _STATUS_TYPE_COLUMN: 5
    property var _DESC_COLUMN: 6
    property var _STATUS_LIST_COLUMN: 7

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
            text: "状态信息"
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
            TextField {
                id: field
                anchors {
                    fill: parent
                    margins: 1
                }

                property var validColumn: [_TYPE_ID_COLUMN, _TYPE_COLUMN, _TYPE_NAME_COLUMN, _DESC_COLUMN].includes(styleData.column)

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

            // 绑定ICD
            ComboBox {
                id: typeBox
                anchors {
                    fill: parent
                    margins: 1
                }

                property var validColumn: styleData.column === _BIND_ICD_COLUMN

                visible: validColumn && styleData.selected

                textRole: "name"

                currentIndex: validColumn ? Number(styleData.value) : 0

                onCurrentIndexChanged: {
                    if (!visible) {
                        return
                    }
                    root.setValue(styleData.row, styleData.column, String(gICDInfo[currentIndex].icd_id))
                }

                model: {
                    var icdNameList = []
                    for (var i in _canUseICD) {
                        for (var j in gICDInfo) {
                            if (String(_canUseICD[i]) === String(gICDInfo[j].icd_id)) {
                                icdNameList.push(gICDInfo[j])
                                break
                            }
                        }
                    }
                    return icdNameList
                }
            }

            // 大小
            SpinBox {
                anchors {
                    fill: parent
                    margins: 1
                }

                property var validColumn: styleData.column === _FIELD_INDEX_COLUMN || styleData.column === _STATUS_TYPE_COLUMN

                visible: styleData.selected && validColumn

                value: validColumn ? Number(styleData.value) : 0

                maximumValue: 128
                minimumValue: styleData.column === 1 ? 0 : 1

                onValueChanged: {
                    if (!visible) {
                        return
                    }
                    root.setValue(styleData.row, styleData.column, value)
                }
            }

            Button {
                id: enumBtn
                text: qsTr("添加状态")
                anchors {
                    fill: parent
                    margins: 1
                }

                visible: (styleData.column === _STATUS_LIST_COLUMN) && styleData.selected

                onClicked: {
                    var component = Qt.createComponent("DeviceStatusEnumData.qml")
                    if (component.status === Component.Error) {
                        console.debug("Error:"+ component.errorString())
                        return
                    }
                    if (component.status === Component.Ready) {
                        var win = component.createObject()
                        win.show()
                        win.rootPage = root

                        if (segments[styleData.row].status_list) {
                            win.setEunmInfos(segments[styleData.row].status_list)
                        }
                    }
                }
            }

            Label {
                id: label
                anchors.fill: parent
                visible: !styleData.selected

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                text: {
                    if (!visible) {
                        return ""
                    }
                    if (styleData.column === _TYPE_NAME_COLUMN || styleData.column === _DESC_COLUMN) {
                        return String(styleData.value)

                    }
                    return String(JSON.stringify(styleData.value))
                }
            }
        } // itemDelegate end

        TableViewColumn {
            id: typeID
            visible: table.columsVisible[0]
            role: "type_id"
            title: "ID"
            width: 160
        }

        TableViewColumn {
            id: bindICD
            visible: table.columsVisible[1]
            role: "bind_icd"
            title: "绑定ICD"
            width: 80
        }

        TableViewColumn {
            id: fieldIndex
            visible: table.columsVisible[2]
            role: "field_index"
            title: "field_index"
            width: 80
        }

        TableViewColumn {
            id: type
            visible: table.columsVisible[3]
            role: "type"
            title: "类型"
            width: 100
        }

        TableViewColumn {
            id: typeName
            visible: table.columsVisible[4]
            role: "type_name"
            title: "类别名"
            width: 100
        }

        TableViewColumn {
            id: statusType
            visible: table.columsVisible[5]
            role: "status_type"
            title: "status_type"
            width: 80
        }

        TableViewColumn {
            id: desc
            visible: table.columsVisible[6]
            role: "desc"
            title: "描述"
            width: 80
        }

        TableViewColumn {
            id: statusList
            visible: table.columsVisible[7]
            role: "statusList"
            title: "状态列表"
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


    // 增加新行
    function addSegment(row) {
        var info = {
            "type_id": row + 1,
            "bind_icd": "",
            "field_index": 0,
            "type": row + 1,
            "type_name": "状态" + String(row + 1),
            "status_type": 0,
            "desc": "",
            "status_list": []
        }

        root.segments.splice(row + 1, 0, info)
        table.model.insert(row + 1, info)
    }

    function getEnumdata(meaning) {
        segments[table.currentRow].status_list = meaning
    }

    // 加载列表数据
    function load(values) {
        _deviceID = values.device_id
        for (var i in gDeviceBindInfo) {
            if (values.device_id === gDeviceBindInfo[i].id) {
                _canUseICD = gDeviceBindInfo[i].input_icd
                break
            }
        }

        batchAdd.enabled = true

        segments = values.monitor_status

        table.model.clear()
        for (var i in segments) {
            table.model.append({
                                   "type_id": segments[i].type_id,
                                   "bind_icd": segments[i].bind_icd,
                                   "field_index": segments[i].field_index,
                                   "type": segments[i].type,
                                   "type_name": segments[i].type_name,
                                   "status_type": segments[i].status_type,
                                   "desc": segments[i].desc,
                                   "status_list": segments[i].status_list,
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
        case _TYPE_ID_COLUMN:
            segment.type_id = value
            table.model.setProperty(index, "type_id", value)
            break
        case _BIND_ICD_COLUMN:
            segment.bind_icd = value
            table.model.setProperty(index, "bind_icd", String(value))
            break
        case _FIELD_INDEX_COLUMN:
            segment.field_index = value
            table.model.setProperty(index, "field_index", value)
            break
        case _TYPE_COLUMN:
            segment.type = value
            table.model.setProperty(index, "type", value)
            break
        case _TYPE_NAME_COLUMN:
            segment.type_name = value
            table.model.setProperty(index, "type_name", value)
            break
        case _STATUS_TYPE_COLUMN:
            segment.status_type = value
            table.model.setProperty(index, "status_type", value)
            break
        case _DESC_COLUMN:
            segment.desc = value
            table.model.setProperty(index, "desc", value)
            break
        case _STATUS_LIST_COLUMN:
            segment.status_list = value
            table.model.setProperty(index, "status_list", value)
            break
        }
        root.segments[index] = segment
    }
}
