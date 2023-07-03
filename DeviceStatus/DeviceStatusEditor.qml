/*
 * @Description:
 * @Version: 1.0
 * @Author: liyuanhao
 * @Date: 2023-05-09 19:05:47
 * @LastEditors: liyuanhao
 * @LastEditTime: 2023-05-09 19:05:47
 */

import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import DesktopControls 0.1

ColumnLayout {
    id: root

    property var status: []

    SplitView {
        Layout.fillHeight: true
        Layout.fillWidth: true

        Rectangle {
            implicitWidth: 200
            Layout.fillHeight: true
            color: "#f0f0f0"

            DeviceStatusList {
                id: listComponent

                status: root.status

                anchors.fill: parent
                Layout.fillHeight: true

                onCurrentIndexChanged: {
                    if (listComponent.currentIndex < 0) {
                        return
                    }
                    var data = root.status[listComponent.currentIndex]
                    detailComponent.load(data)
                    segmentComponent.load(data)
                }
            } // DeviceStatusList end
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#f0f0f0"

            DeviceStatusDetail {
                id: detailComponent

                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                onItemChanged: {
                    if (listComponent.currentIndex < 0) {
                        return
                    }

                    var data = {}
                    if (id === "type_name") {
                        data["type_name"] = value
                    }

                    if (id === "desc") {
                        data["desc"] = value
                    }

                    if (id === "device") {
                        data["device"] = JSON.parse(value)
                        // 修改设备名, 直接清空segmentComponent
                        segmentComponent.updateDevice(JSON.parse(value))
                        segmentComponent.clear()
                    }
                    listComponent.model.set(listComponent.currentIndex, data)
                }
            }

            DeviceStatusSegmentList {
                id: segmentComponent
                anchors {
                    left: parent.left
                    right: parent.right
                    top: detailComponent.bottom
                    topMargin: 5
                    bottom: parent.bottom
                }
            }
        }
    }
}
