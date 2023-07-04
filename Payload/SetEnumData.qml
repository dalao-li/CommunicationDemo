/*
 * @Description:
 * @Version: 1.0
 * @Author: liyuanhao
 * @Date: 2023-05-09 19:05:47
 * @LastEditors: Please set LastEditors
 * @LastEditTime: 2023-05-16 14:14:45
 */


import QtQuick 2.5
import Qt.labs.settings 1.0
import QtQuick.Window 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import DesktopControls 0.1 as Desktop

import "../Button"


Window {
    property var enumInfos: []

    property var rootPage

    property var _NAME_COLUMN: 0
    property var _DATA_COLUMN: 1

    signal itemChanged
    signal enumSave

    id: root

    width: 800
    height: 500

    title: qsTr("枚举值设置")

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
                text: "枚举"
            }

            Button {
                //保存当前枚举值设置
                id: saveEnumBtn
                height: parent.height
                text: qsTr("保存")

                onClicked: {
                    if (table.rowCount > 0) {
                        console.log("保存前", JSON.stringify(enumInfos))
                        // 处理输出{"enumname":"FASDFADS","enumdata":"123"} 为 {"FASDFADS": "123"}
                        var meaning = {}
                        for (var i in enumInfos) {
                            var key = enumInfos[i].enumname
                            var value = enumInfos[i].enumdata
                            meaning[key] = value
                        }

                        rootPage.getEnumdata(meaning)
                    }
                }
            }

            Row {
                anchors {
                    right: parent.right
                    rightMargin: 10
                    verticalCenter: parent.verticalCenter
                }

                // 增加
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

            TableViewColumn {
                id: nameColumn
                visible: true
                role: "enumname"
                title: "名称"
                width: 350
            }

            TableViewColumn {
                id: dataColumn
                visible: true
                role: "enumdata"
                title: "数值"
                width: 350
            }

            model: ListModel {
                id: myListModel
            }

            itemDelegate: Item {
                TextField {
                    id: field
                    anchors {
                        fill: parent
                        margins: 1
                    }

                    visible: styleData.column === _NAME_COLUMN || styleData.column === _DATA_COLUMN

                    property var select: styleData.value
                    text: select

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    onTextChanged: {
                        if (!visible) {
                            return
                        }
                        //console.log("select", JSON.stringify(field.text))
                        updateValue(styleData.row, styleData.column, field.text)
                    }
                }
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
                            root.enumInfos.splice(table.currentRow, 1)
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
            "enumname": "",
            "enumdata": ""
        }
        root.enumInfos.push(info)
        table.model.insert(row + 1, info)
    }

    // 将已经保存的枚举值重新输入子界面
    function setEunmInfos(enumInfos) {
        var index = 0
        var info = {}
        for (var i in enumInfos) {
            info = {
                "enumname": i,
                "enumdata": enumInfos[i]
            }
            //console.log("info ", JSON.stringify(info))
            table.model.insert(index++, info)
            root.enumInfos.push(info)
        }
        return
    }

    function updateValue(index, column, value) {
        if (index < 0 || column < 0) {
            return
        }

        var enuminfo = root.enumInfos[index]
        switch (column) {
        case _NAME_COLUMN:
            // enumname
            enuminfo.enumname = value
            table.model.setProperty(index, "enumname", value)
            break
        case _DATA_COLUMN:
            // enumdata
            enuminfo.enumdata = value
            table.model.setProperty(index, "enumdata", value)
            break
        }

        root.enumInfos[index] = enuminfo
    }
}
