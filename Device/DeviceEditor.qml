/*
 * @Description:
 * @Version: 1.0
 * @Author: liyuanhao
 * @Date: 2023-05-9 19:05:47
 * @LastEditors: liyuanhao
 * @LastEditTime: 2023-05-9 19:05:47
 */


import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import DesktopControls 0.1

ColumnLayout {
    id: root

    property var devices: []

    SplitView {
        Layout.fillHeight: true
        Layout.fillWidth: true

        Rectangle {
            implicitWidth: 200
            Layout.fillHeight: true
            color: "#f0f0f0"

            DeviceList {
                id: deviceList
                anchors.fill: parent
                Layout.fillHeight: true

                devices: root.devices

                onCurrentIndexChanged: {
                    deviceDetail.load(root.devices[deviceList.currentIndex])
                }
            }
        }

        Rectangle {
            //            Layout.fillWidth: true
            //            Layout.fillHeight: true
            //            color: "#f0f0f0"
            //            implicitWidth: 200
            DeviceDetail {
                id: deviceDetail
                //                anchors {
                //                    top: parent.top
                //                    left: parent.left
                //                    right: parent.right
                //                }

                onItemChanged: {
                    if (deviceList.currentIndex < 0) {
                        return
                    }

                    var curIndex = deviceList.currentIndex

                    if (id === "control_type") {
                        deviceList.model.set(curIndex, {"control_type": Number(value)})
                        return
                    }

                    if (id === "bus_type") {
                        deviceList.model.set(curIndex, {"bus_type": Number(value)})
                        return
                    }

                    if (id === "update_icd") {
                        var info = JSON.parse(value)
                        if (info["type"] === "input") {
                            root.devices[curIndex].input_icd = info["icdList"]
                            deviceList.model.set(curIndex, {"input_icd": info["icdList"]})
                        }
                        if (info["type"] === "output") {
                            root.devices[curIndex].output_icd = info["icdList"]
                            deviceList.model.set(curIndex, {"output_icd": info["icdList"]})
                        }
                        return
                    }

                    deviceList.model.set(curIndex, {id: value})
                }
            }
        }
    }
}
