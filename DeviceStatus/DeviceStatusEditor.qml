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
                    //console.log("data = ", JSON.stringify(data))
                    detailComponent.load(data)
                    segmentComponent.load(data)
                }

                onCountChanged: {
                    if (listComponent.count <= 0) {
                        //console.log("listComponent.count", listComponent.count)
                        detailComponent.clear()
                        segmentComponent.clear()
                    }
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
                    var currentIndex = listComponent.currentIndex
                    if (currentIndex < 0) {
                        return
                    }

                    var data = {}
                    if (id === "type_name") {
                        listComponent.model.set(currentIndex, {"type_name": value})
                        return
                    }

                    if (id === "desc") {
                        listComponent.model.set(currentIndex, {"desc": value})
                        return
                    }

                    if (id === "device") {
                        var device = JSON.parse(value)
                        root.status[currentIndex].device = device
                        segmentComponent.updateDevice(device)
                        return
                        //segmentComponent.clear()
                    }
                    listComponent.model.set(currentIndex, {id: value})
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
