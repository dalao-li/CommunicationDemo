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
    property var _device: devices[0]

    // 列枚举名
    property var _BIND_ICD_COLUMN: 0
    property var _FIELD_INDEX_COLUMN: 1
    property var _TYPE_NAME_COLUMN: 2
    property var _STATUS_TYPE_COLUMN: 3
    property var _DESC_COLUMN: 4
    property var _STATUS_LIST_COLUMN: 5

    // icd列表
    property var icdList: {
        return getICDList()
    }

    signal itemChanged(string id, string value)

    // 表头
    Rectangle {
        id: title
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }

        height: 32

        color: "#8E8E8E"

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

        TableViewColumn {
            id: bindICD
            visible: true
            role: "bind_icd"
            title: "绑定输出ICD"
            width: 200
        }

        TableViewColumn {
            id: fieldIndex
            visible: true
            role: "field_index"
            title: "ICD域"
            width: 200
        }

        TableViewColumn {
            id: typeName
            visible: true
            role: "type_name"
            title: "类别名"
            width: 200
        }

        TableViewColumn {
            id: statusType
            visible: true
            role: "status_type"
            title: "status_type"
            width: 80
        }

        TableViewColumn {
            id: desc
            visible: true
            role: "desc"
            title: "描述"
            width: 200
        }

        TableViewColumn {
            id: statusList
            visible: true
            role: "status_list"
            title: "状态列表"
            width: 100
        }

        model: ListModel {}

        frameVisible: false

        // 如何绘制每一个单元格
        itemDelegate: Item {
            Loader {
                anchors.fill: parent
                sourceComponent: {
                    if (styleData.selected) {
                        if ([_TYPE_NAME_COLUMN, _DESC_COLUMN].includes(styleData.column)) {
                            return textComponent
                        }

                        if (styleData.column === _BIND_ICD_COLUMN) {
                            return icdComboboxCompoent
                        }

                        if (styleData.column === _FIELD_INDEX_COLUMN) {
                            return indexComboboxComponent
                        }

                        if (styleData.column === _STATUS_LIST_COLUMN) {
                            return buttonComponent
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

                    text: {
                        if (!visible || styleData.row === undefined || segments[styleData.row] === undefined || segments[styleData.row] === []) {
                            return ""
                        }

                        switch (styleData.column) {
                        case _STATUS_TYPE_COLUMN:
                        case _TYPE_NAME_COLUMN:
                        case _DESC_COLUMN:
                            return String(styleData.value)
                        case _BIND_ICD_COLUMN:
                            for (var i in payloads) {
                                if (payloads[i].id === styleData.value) {
                                    return payloads[i].name
                                }
                            }
                            break
                        case _FIELD_INDEX_COLUMN:
                            for (var j in payloads) {
                                if (payloads[j].id === String(segments[styleData.row].bind_icd)) {
                                    var value = payloads[j].values[styleData.value]
                                    if (value === undefined) {
                                        return ""
                                    }
                                    return value.name
                                }
                            }
                            break

                        default:
                            return ""
                        }
                        return ""
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
            }

            Component {
                id: icdComboboxCompoent
                // 绑定的ICD
                ComboBox {
                    id: typeBox
                    anchors {
                        fill: parent
                        margins: 1
                    }

                    textRole: "text"

                    visible: styleData.selected && styleData.column === _BIND_ICD_COLUMN

                    property var curIndex: {
                        if (styleData.row === undefined || segments[styleData.row] === undefined || segments[styleData.row].bind_icd === undefined) {
                            return -1
                        }

                        for (var i in icdList) {
                            if (String(segments[styleData.row].bind_icd) === icdList[i].value) {
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
                        if (!visible || styleData.row === undefined || currentIndex < 0) {
                            return
                        }
                        // 更新当前bind_icd
                        root.setValue(styleData.row, styleData.column, icdList[currentIndex].value)
                    }
                }
            }

            Component {
                id: indexComboboxComponent
                // ICD下的工程index
                ComboBox {
                    id: fieldCombox
                    anchors {
                        fill: parent
                        margins: 1
                    }

                    textRole: "text"

                    visible: styleData.selected && styleData.column === _FIELD_INDEX_COLUMN

                    // field 列表
                    property var fieldList: {
                        if (styleData.row === undefined || segments[styleData.row] === undefined || segments[styleData.row].bind_icd === undefined) {
                            return []
                        }
                        return getFieldList(segments[styleData.row].bind_icd)
                    }

                    property var curIndex: {
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
                        currentIndex = curIndex
                    }

                    onCurrentIndexChanged: {
                        if (!visible || styleData.row === undefined) {
                            return
                        }
                        root.setValue(styleData.row, styleData.column, currentIndex)
                    }
                }
            }

            Component {
                id: buttonComponent
                Button {
                    id: enumBtn
                    text: qsTr("添加状态")
                    anchors {
                        fill: parent
                        margins: 1
                    }

                    visible: styleData.column === _STATUS_LIST_COLUMN && styleData.selected

                    onClicked: {
                        var component = Qt.createComponent("DeviceStatusEnumData.qml")
                        if (component.status === Component.Error) {
                            console.debug("Error:"+ component.errorString())
                            return
                        }
                        if (component.status === Component.Ready) {
                            var windows = component.createObject()
                            windows.show()
                            windows.rootPage = root

                            if (segments[styleData.row].status_list) {
                                windows.setEunmInfos(segments[styleData.row].status_list)
                            }
                        }
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

    // 加载列表
    function load(values) {
        //console.log("values = ", JSON.stringify(values))
        segments = values.monitor_status
        _device = values.device

        batchAdd.enabled = true
        table.model.clear()
        for (var i in segments) {
            table.model.append({
                                   "type_id": segments[i].type_id,
                                   "bind_icd": segments[i].bind_icd,
                                   // 在payloads中, 对应icd的values中 name组的下标
                                   "field_index": segments[i].field_index,
                                   "type": segments[i].type,
                                   "type_name": segments[i].type_name,
                                   "status_type": segments[i].status_type,
                                   "desc": segments[i].desc,
                                   "status_list": segments[i].status_list,
                                   // output_icd id列表
                                   "icd_list": getICDList(),
                                   // ICD下field的index
                                   "field_list": getFieldList(segments[i].bind_icd)
                               })
        }
    }

    // 增加
    function addSegment(row) {
        var info = {
            "type_id": row + 1,
            // 默认绑首个icd
            "bind_icd": _device.output_icd[0],
            // field index默认为工程0
            "field_index": 0,
            "type": row + 1,
            "type_name": "状态" + String(row + 1),
            "status_type": 0,
            "desc": "",
            "status_list": [],
            // output_icd id列表
            "icd_list": getICDList(),
            // ICD下field的index
            "field_list": getFieldList(_device.output_icd[0])
        }
        root.segments.splice(row + 1, 0, info)
        table.model.insert(row + 1, info)
    }

    function updateDevice(newDevice) {
        _device = newDevice
    }

    // 获取枚举
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
            // 同步修改该行的field_list
            segment.field_index = 0
            table.model.setProperty(index, "field_index", 0)
            segment.field_list = getFieldList(value)
            table.model.setProperty(index, "field_list", segment.field_list)
            break
        case _FIELD_INDEX_COLUMN:
            segment.field_index = value
            table.model.setProperty(index, "field_index", value)
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

    function clear() {
        table.model.clear()
        root.segments = []
    }

    function getICDList() {
        if (_device.output_icd === undefined) {
            return []
        }

        if (_device.output_icd === []) {
            return []
        }

        var icd = []
        for (var i in _device.output_icd) {
            for (var j in payloads) {
                if (String(_device.output_icd[i]) === String(payloads[j].id)) {
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
        var values = (()=>{
                          for (var i in payloads) {
                              if (String(bind_icd) === String(payloads[i].id)) {
                                  return payloads[i].values
                              }
                          }
                      })()

        var res = []
        for (var i in values) {
            var info = {
                text: values[i].name,
                value: i
            }
            res.push(info)
        }
        return res
    }
}
