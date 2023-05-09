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
    property alias deviceList: deviceList
    property alias deviceDetail: deviceDetail

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
                    // 获取侧边栏对应索引的数据
                    console.log("DeviceDetail加载数据", JSON.stringify(root.devices[deviceList.currentIndex]))
                    deviceDetail.load(root.devices[deviceList.currentIndex])
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#f0f0f0"

            // 左上编辑界面
            DeviceDetail {
                id: deviceDetail
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                onItemChanged: {
                    if (deviceList.currentIndex < 0) {
                        return
                    }

                    var d = {}
                    if (["control_type", "bus_type"].includes(id)) {
                        d[id] = Number(value)
                    }
                    if (id === "icd_info") {
                        var v = JSON.parse(value)

                        if (v["type"] === "input") {
                            console.log("....", root.devices[deviceList.currentIndex].input_icd)
                            d["input_icd"] = root.devices[deviceList.currentIndex].input_icd
                            // console.log("传递过来, ", JSON.stringify(d["input_icd"]))

                        }

                        if (v["type"] === "ouput") {
                            d["ouput_icd"] = root.devices[deviceList.currentIndex].ouput_icd
                        }
                    }

                    else {
                        d[id] = value
                    }
                    deviceList.model.set(deviceList.currentIndex, d)
                }
            }
        }
    }
}
