﻿import QtQuick 2.5
import Qt.labs.settings 1.0
import QtQuick.Window 2.0
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import DesktopControls 0.1 as Desktop

Window {
    id: root

    width: 800
    height: 500

    title: qsTr("枚举值设置")

    property var enumInfos: []

    property var rootPage

    signal itemChanged
    signal enumSave

    Item {
        //        id:root
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
                        console.log("++++++++++enumInfos++++++++++++"+JSON.stringify(enumInfos))
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

                    property var validColumn: styleData.column === 0 || styleData.column === 1

                    visible: validColumn
                    // text: styleData.column === 0  ? "名称" : "数值"

                    text: styleData.value

                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter

                    onTextChanged: {
                        if (!visible) {
                            return
                        }
                        setValue(styleData.row, styleData.column, field.text)
                    }
                }
            }

            TableViewColumn {
                id: enumnameCol
                visible: true
                role: "enumname"
                title: "名称"
                width: 350
            }

            TableViewColumn {
                id: enumdataCol
                visible: true
                role: "enumdata"
                title: "数值"
                width: 350
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
                            //root.enumInfos.splice(table.currentRow, 1)
                            table.model.remove(table.currentRow, 1)

                            //root.itemChanged()
                        }
                    }
                }
            }
        }
        //setEunmInfos
    }

    function addEnum(row) //添加枚举值
    {
        var info = {
            "enumname": "",
            "enumdata": ""
        }
        root.enumInfos.push(info)
        table.model.insert(row + 1, info)
        //root.itemChanged()
    }

    function setEunmInfos(enumInfos) {
        //将已经保存的枚举值重新输入子界面
        for (var i = 0; i < enumInfos.length; i++) {
            console.log("将已经保存的枚举值重新输入子界面", enumInfos[i])
            table.model.insert(i, enumInfos[i])
        }
    }

    function setValue(index, column, value) {
        if (index < 0 || column < 0)
            return

        var enuminfo = root.enumInfos[index]
        switch (column) {
        case 0:
            //enumname
            enuminfo.enumname = value
            table.model.setProperty(index, "enumname", value)
            break
        case 1:
            //enumdata
            enuminfo.enumdata = value
            table.model.setProperty(index, "enumdata", value)
            break
        }
        //        root.itemChanged()
    }
}
