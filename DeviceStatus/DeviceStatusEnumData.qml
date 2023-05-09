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

                    property var validColumn: styleData.column === 0 || styleData.column === 1 || styleData.column === 2 || styleData.column === 3

                    visible: validColumn

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
                id: valueColumn
                visible: true
                role: "value"
                title: "取值"
                width: 200
            }

            TableViewColumn {
                id: showInfoColumn
                visible: true
                role: "showInfo"
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

    function setValue(index, column, value) {
        if (index < 0 || column < 0)
            return

        var enuminfo = root.enumInfos[index]
        switch (column) {
        case 0:
            // value
            enuminfo.value = value
            table.model.setProperty(index, "value", value)
            break
        case 1:
            // showinfo
            enuminfo.showinfo = value
            table.model.setProperty(index, "showinfo", value)
            break

        case 2:
            enuminfo.icon = value
            table.model.setProperty(index, "icon", value)
            break
        case 3:
            enuminfo.color = value
            table.model.setProperty(index, "color", value)
            break
        }

        //        root.itemChanged()
    }
}
