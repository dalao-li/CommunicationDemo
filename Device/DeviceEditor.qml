/*
 * @Description: Deivce主页面
 * @Version: 1.0
 * @Author: liyuanhao
 * @Date: 2023-05-9 19:05:47
 * @LastEditors: liyuanhao
 * @LastEditTime: 2023-07-05 19:05:47
 */


import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import DesktopControls 0.1



ColumnLayout {
    id: root

    property var devices: []

    property var icdSelectList: []

    signal signalUpdateICDSelectInfo(var deviceSelectList)

    SplitView {
        Layout.fillHeight: true
        Layout.fillWidth: true

        Rectangle {
            implicitWidth: 200
            Layout.fillHeight: true
            color: "#f0f0f0"

            // 左侧选项卡
            DeviceList {
                id: listComponent
                anchors.fill: parent
                Layout.fillHeight: true

                devices: root.devices

                onCurrentIndexChanged: {
                    detailComponent.load(root.devices[listComponent.currentIndex])
                }

                onCountChanged: {
                    if (listComponent.count <= 0) {
                        detailComponent.clear()
                    }
                }
            }
        }

        Rectangle {
            // 右侧页面
            DeviceDetail {
                id: detailComponent

                onItemChanged: {
                    var curIndex = listComponent.currentIndex
                    if (curIndex < 0) {
                        return
                    }

                    if (id === "type") {
                        listComponent.model.set(curIndex, {"type": value})
                        mainWindow.signalUpdateDeviceInfo(devices)
                        return
                    }

                    if (id === "control_type") {
                        listComponent.model.set(curIndex, {"control_type": Number(value)})
                        return
                    }

                    if (id === "bus_type") {
                        listComponent.model.set(curIndex, {"bus_type": Number(value)})
                        return
                    }

                    if (id === "input_icd" || id === "output_icd") {
                        var data = JSON.parse(value)
                        if (id === "input_icd") {
                            root.devices[curIndex].input_icd = data["icd"]
                            listComponent.model.set(curIndex, {"input_icd": data["icd"]})
                        }
                        if (id === "output_icd") {
                            root.devices[curIndex].output_icd = data["icd"]
                            listComponent.model.set(curIndex, {"output_icd": data["icd"]})
                        }
                    }
                    mainWindow.signalUpdateDeviceInfo(devices)
                }
            }
        }
    }
}
