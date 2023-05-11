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
import QtQuick.Window 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import DesktopControls 0.1 as Desktop
import "../Button"

Window {
    id: root

    width: 800
    height: 500

    title: qsTr("添加状态列表")

    property var enumInfos: []

    property var rootPage

    property var __VALUE_COLUMN: 0
    property var __SHOWINFO_COLUMN: 1
    property var __ICON_COLUMN: 2
    property var __COLOR_COLUMN: 3

    signal itemChanged
    signal enumSave

    Item {
        anchors {
            fill: parent
        }

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
                text: "状态列表"
            }

            Button {
                //保存当前枚举值设置
                id: saveEnumBtn
                height: parent.height
                text: qsTr("保存")

                onClicked: {
                    if (table.rowCount > 0) {
                        rootPage.getEnumdata(enumInfos)
                    }
                }
            }

            Row {
                anchors {
                    right: parent.right
                    rightMargin: 10
                    verticalCenter: parent.verticalCenter
                }

                BatchAddButton {
                    id: batchAdd
                    enabled: true

                    anchors {
                        verticalCenter: parent.verticalCenter
                    }

                    onClicked: {
                        addEnum(table.rowCount - 1)
                    }
                }
            }
        }

        TableView {
            id: table
            anchors {
                top: title.bottom
                bottom: parent.bottom
                left: parent.left
                right: parent.right
            }

            frameVisible: false

            itemDelegate: Item {
                TextField {
                    id: field
                    anchors {
                        fill: parent
                        margins: 1
                    }

                    visible: [__VALUE_COLUMN, __SHOWINFO_COLUMN, __ICON_COLUMN, __COLOR_COLUMN].includes(styleData.column)

                    text: styleData.value

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    onTextChanged: {
                        if (!visible) {
                            return
                        }
                        updateValue(styleData.row, styleData.column, field.text)
                    }
                }
            }

            TableViewColumn {
                id: valueColumn
                visible: true
                role: "value"
                title: "取值"
                width: 200
            }

            TableViewColumn {
                id: showInfoColumn
                visible: true
                role: "showinfo"
                title: "信息"
                width: 200
            }

            TableViewColumn {
                id: iconColumn
                visible: true
                role: "icon"
                title: "图标"
                width: 200
            }

            TableViewColumn {
                id: colorColumn
                visible: true
                role: "color"
                title: "颜色"
                width: 200
            }

            model: ListModel {
                id: myListModel
            }

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

                    IconButton {
                        id: remove
                        name: "minus"
                        color: "black"
                        onClicked: {
                            table.model.remove(table.currentRow, 1)
                        }
                    }
                }
            }
        }
        //setEunmInfos
    }

    // 添加枚举值
    function addEnum(row) {
        var info = {
            "value": "",
            "showinfo": "",
            "icon": "",
            "color": ""
        }
        root.enumInfos.push(info)
        table.model.insert(row + 1, info)
    }

    function setEunmInfos(enumInfos) {
        //将已经保存的枚举值重新输入子界面
        for (var i = 0; i < enumInfos.length; i++) {
            table.model.insert(i, enumInfos[i])
        }
    }

    function updateValue(index, column, value) {
        if (index < 0 || column < 0)
            return

        var enuminfo = root.enumInfos[index]
        switch (column) {
        case __VALUE_COLUMN:
            // value
            enuminfo.value = value
            table.model.setProperty(index, "value", value)
            break
        case __SHOWINFO_COLUMN:
            // showinfo
            enuminfo.showinfo = value
            table.model.setProperty(index, "showinfo", value)
            break
        case __ICON_COLUMN:
            enuminfo.icon = value
            table.model.setProperty(index, "icon", value)
            break
        case __COLOR_COLUMN:
            enuminfo.color = value
            table.model.setProperty(index, "color", value)
            break
        }
    }
}
