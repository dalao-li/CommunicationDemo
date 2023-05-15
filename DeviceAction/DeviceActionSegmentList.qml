import QtQuick 2.5
import Qt.labs.settings 1.0
import QtQuick.Controls 1.4
import DesktopControls 0.1 as Desktop

import "../Button"

Item {
    id: root

    property var actions: []
    property var canUseICD : []

    property int _CONDITION_BIND_ICDICOLUMN: 0
    property var _CONDTION_KEYS_COLUMN: 1

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
            TextField {
                id: field
                anchors {
                    fill: parent
                    margins: 1
                }

                property var validColumn: false

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

            // conditon绑定ICD
            ComboBox {
                id: typeBox
                anchors {
                    fill: parent
                    margins: 1
                }

                property var validColumn: styleData.column === _CONDITION_BIND_ICDICOLUMN

                visible: validColumn && styleData.selected

                textRole: "name"

                currentIndex: validColumn ? Number(styleData.value) : 0

                onCurrentIndexChanged: {
                    if (!visible) {
                        return
                    }
                    root.setValue(styleData.row, styleData.column, String(payloads[currentIndex].icd_id))
                }

                model: {
                    var icdNameList = []
                    for (var i in canUseICD) {
                        for (var j in payloads) {
                            if (String(canUseICD[i]) === String(payloads[j].icd_id)) {
                                icdNameList.push(payloads[j])
                                break
                            }
                        }
                    }
                    return icdNameList
                }
            }

            // 添加condition
            Button {
                id: enumBtn
                text: qsTr("添加Condition")
                anchors {
                    fill: parent
                    margins: 1
                }

                visible: styleData.column === __STATUS_LIST_COLUMN && styleData.selected

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
                        if (actions[styleData.row].condition) {
                            win.setEunmInfos(actions[styleData.row].condition)
                        }
                    }
                }
            }

            Label {
                id: label
                anchors.fill: parent
                visible: false

                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter

                text: {
                    if (!visible) {
                        return ""
                    }

                    if (styleData.column === __TYPE_NAME_COLUMN || styleData.column === __DESC_COLUMN) {
                        return String(styleData.value)

                    }
                    return String(JSON.stringify(styleData.value))
                }
            }
        } // itemDelegate end

        TableViewColumn {
            id: type
            visible: table.columsVisible[_CONDITION_BIND_ICDICOLUMN]
            role: "type"
            title: "类型"
            width: 100
        }

        TableViewColumn {
            id: condition
            visible: table.columsVisible[_CONDTION_KEYS_COLUMN]
            role: "condition"
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
                        root.actions.splice(table.currentRow, 1)
                        table.model.remove(table.currentRow, 1)
                    }
                }
            }
        } // end of rowDelegate
    } // end of TableView


    // 增加新行
    function addSegment(row) {
        var info = {
            "bind_icd": payloads[0].id,
            "condition": []
        }

        root.actions.splice(row + 1, 0, info)
        table.model.insert(row + 1, info)
    }

    // 获取枚举
    function getEnumdata(meaning) {
        actions[table.currentRow].condition = meaning
    }

    // 加载列表数据
    function load(values) {
        for (var i in devices) {
            if (values.device_id === devices[i].device_id) {
                canUseICD = devices[i].input_icd
                break
            }
        }

        batchAdd.enabled = true

        table.model.clear()

        actions = values.monitor_status
        for (var i in actions) {
            table.model.append({
                                   "bind_icd": actions[i].type_id,
                                   "status_list": actions[i].condition,
                               })
        }
    }

    // 修改某行某列的值
    function setValue(index, column, value) {
        if (index < 0 || column < 0) {
            return
        }

        var segment = root.actions[index]
        switch (column) {
        case _CONDITION_BIND_ICDICOLUMN:
            segment.bind_icd = value
            table.model.setProperty(index, "bind_icd", value)
            break

        case _CONDTION_KEYS_COLUMN:
            segment.condition = value
            table.model.setProperty(index, "condition", value)
            break
        }
        root.actions[index] = segment
    }
}
