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
    property var _device

    property var _BIND_ICD_COLUMN: 0
    property var _FIELD_INDEX_COLUMN: 1
    property var _TYPE_NAME_COLUMN: 2
    property var _STATUS_TYPE_COLUMN: 3
    property var _DESC_COLUMN: 4
    property var _STATUS_LIST_COLUMN: 5

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

            property var icdList: getICDList()

            property var fieldList: {
                if (styleData.row === undefined || segments[styleData.row] === undefined || segments[styleData.row].bind_icd === undefined) {
                    return []
                }
                console.log("styleData.row", styleData.row, "segments[styleData.row].bind_icd", JSON.stringify(segments[styleData.row].bind_icd))
                return getFieldList(table.model.get(styleData.row).bind_icd)
            }

            Label {
                id: label
                anchors.fill: parent
                visible: !styleData.selected && [_BIND_ICD_COLUMN, _FIELD_INDEX_COLUMN, _TYPE_NAME_COLUMN, _DESC_COLUMN, _STATUS_TYPE_COLUMN].includes(styleData.column)

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

                    // console.log("styleData.row", styleData.row, "data", JSON.stringify(segments[styleData.row]))

                    if (styleData.column === _TYPE_NAME_COLUMN || styleData.column === _DESC_COLUMN || styleData.column === _STATUS_TYPE_COLUMN) {
                        return String(styleData.value)
                    }

                    if (styleData.column === _BIND_ICD_COLUMN) {
                        if (segment === [] || segment === undefined) {
                            return ""
                        }

                        for (var i in payloads) {
                            if (payloads[i].id === styleData.value) {
                                return payloads[i].name
                            }
                        }
                    }

                    if (styleData.column === _FIELD_INDEX_COLUMN) {
                        if (segment === [] || segment === undefined) {
                            return ""
                        }

                        for (var j in payloads) {
                            if (payloads[j].id === String(segment.bind_icd)) {
                                // console.log("styleData.value", segment.field_index)
                                // console.log("--->", payloads[j].values[segment.field_index].name)
                                return payloads[j].values[styleData.value].name
                            }
                        }
                    }

                    return String(JSON.stringify(styleData.value))
                }
            }

            TextField {
                id: field
                anchors {
                    fill: parent
                    margins: 1
                }

                property var validColumn: [_TYPE_NAME_COLUMN, _DESC_COLUMN].includes(styleData.column)

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
                    root.setValue(styleData.row, styleData.column, field.text)
                }
            } // TextField end

            // 绑定的ICD
            ComboBox {
                id: typeBox
                anchors {
                    fill: parent
                    margins: 1
                }

                textRole: "text"

                visible: styleData.column === _BIND_ICD_COLUMN && styleData.selected

                property var curIndex: {
                    for (var i in icdList) {
                        if (styleData.value === icdList[i].value) {
                            return i
                        }
                    }
                    return -1
                }

                model: icdList

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

            // ICD下的工程index
            ComboBox {
                id: fieldCombox
                anchors {
                    fill: parent
                    margins: 1
                }

                textRole: "text"

                visible: styleData.column === _FIELD_INDEX_COLUMN && styleData.selected

                property var curIndex: {
                    // console.log("===>", JSON.stringify(fieldList))
                    for(var i in fieldList){
                        if(String(segments[styleData.row].field_index) === String(fieldList[i].value)) {
                            return i
                        }
                    }
                    return -1
                }

                model: fieldList

                currentIndex: curIndex

                onCurIndexChanged: {
                    // console.log("component_bindDevice curIndex : "+curIndex)
                    currentIndex = curIndex
                }

                onCurrentIndexChanged: {
                    //console.log("触发切换信号")
                    //console.log("当前currentIndex", currentIndex)
                    if (!visible || styleData.row === undefined) {
                        return
                    }
                    root.setValue(styleData.row, styleData.column, currentIndex)
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
        } // itemDelegate end

        TableViewColumn {
            id: bindICD
            visible: true
            role: "bind_icd"
            title: "绑定ICD"
            width: 80
        }

        TableViewColumn {
            id: fieldIndex
            visible: true
            role: "field_index"
            title: "ICD域"
            width: 120
        }

        TableViewColumn {
            id: typeName
            visible: true
            role: "type_name"
            title: "类别名"
            width: 100
        }

        TableViewColumn {
            id: statusType
            visible: true
            role: "status_type"
            title: "status_type"
            width: 160
        }

        TableViewColumn {
            id: desc
            visible: true
            role: "desc"
            title: "描述"
            width: 80
        }

        TableViewColumn {
            id: statusList
            visible: true
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

    // 加载列表数据
    function load(values) {
        segments = values.monitor_status
        // 设置device信息
        _device = values.device

        batchAdd.enabled = true
        table.model.clear()
        for (var i in segments) {
            table.model.append({
                                   "type_id": segments[i].type_id,
                                   // 在_device.input_icd中的下标
                                   "bind_icd": segments[i].bind_icd,
                                   // 在payloads中, 对应icd的values中 name组的下标
                                   "field_index": segments[i].field_index,
                                   "type": segments[i].type,
                                   "type_name": segments[i].type_name,
                                   "status_type": segments[i].status_type,
                                   "desc": segments[i].desc,
                                   "status_list": segments[i].status_list,
                                   // input_icd id列表
                                   "icd_list": getICDList(),
                                   // ICD下field的index
                                   "field_list": getFieldList(segments[i].bind_icd)
                               })
        }
    }

    // 增加新行
    function addSegment(row) {
        var info = {
            "type_id": row + 1,
            // 默认绑第一个icd
            "bind_icd": _device.input_icd[0],
            // field index默认为工程0
            "field_index": "0",
            "type": row + 1,
            "type_name": "状态" + String(row + 1),
            "status_type": 0,
            "desc": "",
            "status_list": [],
            // input_icd id列表
            "icd_list": getICDList(),
            // ICD下field的index
            "field_list": getFieldList(_device.input_icd[0])
        }
        root.segments.splice(row + 1, 0, info)
        table.model.insert(row + 1, info)
    }

    function getEnumdata(meaning) {
        segments[table.currentRow].status_list = meaning
    }

    // 修改某行某列的值
    function setValue(index, column, value) {
        if (index < 0 || column < 0) {
            return
        }

        var segment = root.segments[index]

        if (segment === undefined) {
            return
        }

        switch (column) {
        case _BIND_ICD_COLUMN:
            segment.bind_icd = value
            table.model.setProperty(index, "bind_icd", value)
            // 同步修改改行的field_list
            segment.field_list = getFieldList(value)
            break
        case _FIELD_INDEX_COLUMN:
            //console.log("修改field_index为: ", String(value))
            segment.field_index = String(value)
            table.model.setProperty(index, "field_index", String(value))
            //console.log("修改后model值为", JSON.stringify(table.model.get(index)))
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

    function getICDList() {
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

        // console.log("field index", JSON.stringify(res))
        return res
    }
}
