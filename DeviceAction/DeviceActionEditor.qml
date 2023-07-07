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

    property var keysList : []

    SplitView {
        Layout.fillHeight: true
        Layout.fillWidth: true

        Rectangle {
            implicitWidth: 200
            Layout.fillHeight: true
            color: "#f0f0f0"

            // 侧边栏
            DeviceActionList {
                id: listComponent

                anchors.fill: parent
                Layout.fillHeight: true

                actions: root.actions

                onCurrentIndexChanged: {
                    if (listComponent.currentIndex < 0) {
                        return
                    }
                    var data = root.actions[listComponent.currentIndex]
                    detailComponent.load(data)
                    segmentComponent.load(data)
                }

                onCountChanged: {
                    if (listComponent.count <= 0) {
                        detailComponent.clear()
                        segmentComponent.clear()
                    }
                }
            } // listComponent end
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#f0f0f0"

            DeviceActionDetail {
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

                    if (id === "name") {
                        listComponent.model.set(listComponent.currentIndex, {"name": value})
                        return
                    }

                    if (id === "device") {
                        var device = JSON.parse(value)
                        root.actions[listComponent.currentIndex].device = device
                        // 修改device时, 同步修改
                        //segmentComponent.clear()
                        segmentComponent.updateDevice(device)
                        return
                    }

                    if (id === "bind_input_icd") {
                        //segmentComponent.clear()
                        segmentComponent.updateBindInputICD(value)
                        root.actions[listComponent.currentIndex].actions.bind_input_icd = value
                    }
                }
            }

            DeviceActionSegmentList {
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
