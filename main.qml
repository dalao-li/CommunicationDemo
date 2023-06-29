/*
 * @Description:
 * @Version: 1.0
 * @Author: liyuanhao
 * @Date: 2023-05-09 19:05:47
 * @LastEditors: liyuanhao
 * @LastEditTime: 2023-05-09 19:05:47
 */


import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2

import "Send"
import "Receive"
import "Button"
import "Device"
import "DeviceStatus"
import "Payload"
import "DeviceAction"

ApplicationWindow {
    id: mainWindow
    visible: true
    width: 1200
    height: 800

    title: qsTr("通信Demo")

    property string path: ""

    property var content: []

    // 全局共享变量
    property var payloads: []

    property var devices: []

    property var status: []

    property var actions: []

    property var _SEND_TAB_INDEX: 0
    property var _RECEIVE_TAB_INDEX: 1
    property var _PAYLOAD_TAB_INDEX: 2
    property var _DEVICE_TAB_INDEX: 3
    property var _DEVICE_STATUS_TAB_INDEX: 4
    property var _DEVICE_ACTION_TAB_INDEX: 5

    property var currentTabIndex: 0


    menuBar: MenuBar {
        Menu {
            title: qsTr("&文件操作")
            //            MenuItem {
            //                text: "New"
            //                shortcut: "Ctrl+N"
            //            }

            MenuItem {
                text: "导入ICD"
                onTriggered: {
                    currentTabIndex = _PAYLOAD_TAB_INDEX
                    importFileDialog.open()
                }
            }

//            MenuItem {
//                text: "导入设备信息"
//                onTriggered: {
//                    currentTabIndex = _DEVICE_TAB_INDEX
//                    importFileDialog.open()
//                }
//            }

//            MenuItem {
//                text: "导入设备状态"
//                onTriggered: {
//                    currentTabIndex = _DEVICE_STATUS_TAB_INDEX
//                    importFileDialog.open()
//                }
//            }

//            MenuItem {
//                text: "导入设备动作"
//                onTriggered: {
//                    currentTabIndex = _DEVICE_ACTION_TAB_INDEX
//                    importFileDialog.open()
//                }
//            }

            //            MenuItem {
            //                text: "Open"
            //                shortcut: "Ctrl+O"
            //                onTriggered: {
            //                    fileDialog.open()
            //                }
            //            }

            //            MenuItem {
            //                text: "Save"
            //                shortcut: "Ctrl+S"
            //                onTriggered: {
            //                    if (path === "")
            //                        newfileDialog.open()
            //                    else
            //                        getTabItem(2).save()
            //                }
            //            }

            //            MenuItem {
            //                text: "Save As"
            //                shortcut: "Ctrl+Alt+S"
            //                onTriggered: {
            //                    newfileDialog.open()
            //                }
            //            }

            //            MenuItem {
            //                text: "Quit"
            //                shortcut: "Ctrl+Q"
            //                onTriggered: {
            //                    Qt.quit()
            //                }
            //            }
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
                payloads: mainWindow.payloads
            }
        }

        Tab {
            id: tab4
            title: "设备类型"
            DeviceEditor {
                id: device
                devices: mainWindow.devices
            }
        }

        Tab {
            id: tab5
            title: "设备状态"
            DeviceStatusEditor {
                id: deviceStatus
                status: mainWindow.status
            }

        }

        Tab {
            id: tab6
            title: "设备动作"
            DeviceActionEditor {
                id: deviceAction
                actions: mainWindow.actions
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

    FileDialog {
        id: importFileDialog
        title: "请选择文件"
        nameFilters: ["payloads files (*.payloads)", "json files (*.json)", "All files (*)"]
        onAccepted: {
            var fpath = String(importFileDialog.fileUrls)
            path = fpath.substring(8)
            content = Excutor.query({ "payloads": path })
            //            getTabItem(0).load()
            //            getTabItem(1).stopListen()
            getTabItem(currentTabIndex).load(content)
        }
        onRejected: {
            console.log("取消")
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
