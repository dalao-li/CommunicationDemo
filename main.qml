import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2

import "Send"
import "Receive"
import "Button"
import "Device"
import "DeviceStatus"
import "Payload"

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1200
    height: 800
    title: qsTr("通信Demo")

    //property var content: Excutor.query({"payloads": ""})
    property var content: []
    property string path: ""

    property var gDeviceInfoAndICD: []

    property var gICDInfoList: []

    property var deviceMonitorSettingJSON

    // signal deviceIdChange()

    menuBar: MenuBar {
        Menu {
            title: qsTr("&File")
            MenuItem {
                text: "New"
                shortcut: "Ctrl+N"
            }

            MenuItem {
                text: "Open"
                shortcut: "Ctrl+O"
                onTriggered: {
                    fileDialog.open()
                }
            }

            MenuItem {
                text: "Save"
                shortcut: "Ctrl+S"
                onTriggered: {
                    if (path === "")
                        newfileDialog.open()
                    else
                        getTabItem(2).save()
                }
            }

            MenuItem {
                text: "Save As"
                shortcut: "Ctrl+Alt+S"
                onTriggered: {
                    newfileDialog.open()
                }
            }

            MenuSeparator {

            }

            MenuItem {
                text: "Quit"
                shortcut: "Ctrl+Q"
                onTriggered: {
                    Qt.quit()
                }
            }
        }
    }

    TabView {
        id: tabView
        implicitHeight: 200
        implicitWidth: 300
        tabPosition: Qt.TopEdge
        frameVisible: false
        anchors.fill: parent

        Tab {
            id: tab1
            title: "发送端"
            active: true
            Send {
                id: send
            }
        }

        Tab {
            title: "接收端"
            Receive {
                id: receive
            }
        }

        Tab {
            id: tab3
            title: "ICD编辑"
            PayloadEditor {
                id: payloadEditor
                //payloads: content
            }
        }

        Tab {
            id: tab4
            title: "设备类型"
            Device {
                id: device
            }

        }

        Tab {
            id: tab5
            title: "设备状态"
            DeviceStatusEditor {
                id: deviceStatus
            }

        }
    } // TabView end



    Component.onCompleted: {
        tabView.currentIndex = 1
        tabView.currentIndex = 2
        tabView.currentIndex = 0
    }

    FileDialog {
        id: fileDialog
        title: "Please choose a file"
        nameFilters: ["payloads files (*.payloads)", "json files (*.json)", "All files (*)"]
        onAccepted: {
            var fpath = String(fileDialog.fileUrls)
            path = fpath.substring(8)
            content = Excutor.query({ "payloads": path })
            getTabItem(0).load()
            getTabItem(1).stopListen()
            getTabItem(2).load(content)
        }
        onRejected: {
            console.log("Canceled")
        }
    }

    FileDialog {
        id: newfileDialog
        title: "Please choose a file"
        selectExisting: false
        nameFilters: ["json files (*.json)", "All files (*)"]
        onAccepted: {
            var fpath = String(newfileDialog.fileUrls)
            path = fpath.substring(8)
            // console.log("____>",path)
            //getTabItem(2).save()
        }
        onRejected: {
            console.log("Canceled")
        }
    }

    function getTabItem(index) {
        var tab = tabView.getTab(index)
        if (!tab) {
            console.log("!tab:", tab)
            return
        }

        var item = tab.item
        if (!item) {
            console.log("!item:", item)
            return
        }

        return item
    }
}
