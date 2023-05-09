import QtQuick 2.5
import Qt.labs.settings 1.0
import QtQuick.Controls 1.4
import DesktopControls 0.1 as Desktop
import "../"

Item {
    id: root

    property var segments: []

    signal itemChanged(string id, string value)

    property int __TYPE_ID_COLUMN: 0
    property var __BIND_ICD_COLUMN: 1
    property var __FIELD_INDEX_COLUMN: 2
    property var __TYPE_COLUMN: 3
    property var __TYPE_NAME_COLUMN: 4
    property var __STATUS_TYPE_COLUMN: 5
    property var __DESC_COLUMN: 6
    property var __STATUS_LIST_COLUMN: 7

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

                property var validColumn: [__TYPE_ID_COLUMN, __TYPE_COLUMN, __TYPE_NAME_COLUMN, __DESC_COLUMN].includes(styleData.column)

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

            ComboBox {
                id: typeBox
                anchors {
                    fill: parent
                    margins: 1
                }

                property var validColumn: styleData.column === __BIND_ICD_COLUMN

                visible: validColumn && styleData.selected

                textRole: "name"

                currentIndex: validColumn ? Number(styleData.value) : 0

                onCurrentIndexChanged: {
                    if (!visible) {
                        return
                    }
                    root.setValue(styleData.row, styleData.column, mainWindow.gICDInfoList[currentIndex].icd_id)
                }
            }

            Binding {
                target: typeBox
                property: "model"
                value: mainWindow.gICDInfoList
            }

            // 大小
            SpinBox {
                anchors {
                    fill: parent
                    margins: 1
                }

                property var validColumn: styleData.column === __FIELD_INDEX_COLUMN || styleData.column === __STATUS_TYPE_COLUMN

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

                property var validColumn: styleData.column === __STATUS_LIST_COLUMN

                visible: validColumn && styleData.selected

                onClicked: {
                    var component = Qt.createComponent("DeviceStatusEnumData.qml")
                    //console.debug("Error:"+ component.errorString() );
                    if (component.status === Component.Ready) {
                        var win = component.createObject()
                        win.show()
                        win.rootPage = root

                        if (segments[styleData.row].status_list) {
                            //存在枚举值
                            console.log("存在枚举", JSON.stringify(segments[styleData.row].status_list))
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

                    if (styleData.column === __TYPE_NAME_COLUMN || styleData.column === __DESC_COLUMN) {
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
                        //root.itemChanged()
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

    function getMask(N) {
        var ff = "0x"
        for (var i = 0; i < N; i++) {
            ff += "ff"
        }
        return ff
    }

    function getEnumdata(meaning) {
        segments[table.currentRow].status_list = meaning
    }

    // 加载列表数据
    function load(values) {
        batchAdd.enabled = true

        table.model.clear()

        segments = values

        for (var i in values) {
            table.model.append({
                                   "type_id": values[i].type_id,
                                   "bind_icd": values[i].bind_icd,
                                   "field_index": values[i].field_index,
                                   "type": values[i].type,
                                   "type_name": values[i].type_name,
                                   "status_type": values[i].status_type,
                                   "desc": values[i].desc,
                                   "status_list": values[i].status_list,
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
        case __TYPE_ID_COLUMN:
            segment.type_id = value
            table.model.setProperty(index, "type_id", value)
            break
        case __BIND_ICD_COLUMN:
            segment.bind_icd = value
            // console.log("=============>", value)
            table.model.setProperty(index, "bind_icd", value)
            break
        case __FIELD_INDEX_COLUMN:
            segment.field_index = value
            table.model.setProperty(index, "field_index", value)
            break
        case __TYPE_COLUMN:
            segment.type = value
            table.model.setProperty(index, "type", value)
            break
        case __TYPE_NAME_COLUMN:
            segment.type_name = value
            table.model.setProperty(index, "type_name", value)
            break
        case __STATUS_TYPE_COLUMN:
            segment.status_type = value
            table.model.setProperty(index, "status_type", value)
            break
        case __DESC_COLUMN:
            segment.desc = value
            table.model.setProperty(index, "desc", value)
            break
        case __STATUS_LIST_COLUMN:
            segment.status_list = value
            table.model.setProperty(index, "status_list", value)
            break
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
