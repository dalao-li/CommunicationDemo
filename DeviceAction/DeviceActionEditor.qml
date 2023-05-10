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

    property var actions: []
    property alias deviceActionList: deviceActionList
    property alias deviceActionDetail: deviceActionDetail
    property alias deviceActionSegmentList: deviceActionSegmentList

    SplitView {
        Layout.fillHeight: true
        Layout.fillWidth: true

        // 侧边栏
        Rectangle {
            implicitWidth: 200
            Layout.fillHeight: true
            color: "#f0f0f0"

            DeviceActionList {
                id: deviceActionList

                anchors.fill: parent
                Layout.fillHeight: true

                actions: root.actions

                onCurrentIndexChanged: {
                    if (deviceActionList.currentIndex < 0) {
                        return
                    }
                    var data = root.actions[deviceActionList.currentIndex]
                    deviceActionDetail.load(data)
                    // deviceActionSegmentList.load(data)
                }
            } // deviceActionList end
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#f0f0f0"

            DeviceActionDetail {
                id: deviceActionDetail
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                onItemChanged: {
                    if (deviceActionList.currentIndex < 0) {
                        return
                    }

                    var d = {}
                    if (id === "name") {
                        d["name"] = value
                    }

                    if (id === "icd_id") {
                        d["icd_id"] = value
                    }

                    if (id === "device_id") {
                        d["device_id"] = value
                    }
                    deviceActionList.model.set(deviceActionList.currentIndex, d)
                }
            }

            DeviceActionSegmentList {
                id: deviceActionSegmentList
                anchors {
                    left: parent.left
                    right: parent.right
                    top: deviceActionDetail.bottom
                    topMargin: 5
                    bottom: parent.bottom
                }
            }
        }
    }
}
