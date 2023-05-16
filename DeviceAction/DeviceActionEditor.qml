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

    SplitView {
        Layout.fillHeight: true
        Layout.fillWidth: true

        // 侧边栏
        Rectangle {
            implicitWidth: 200
            Layout.fillHeight: true
            color: "#f0f0f0"

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
                    console.log("加载==>", JSON.stringify(data))
                    detailComponent.load(data)
                    segmentComponent.load(data)
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

                    var d = {}
                    if (id === "name") {
                        d["name"] = value
                    }

                    // 修改device
                    if (id === "device") {
                        d["device"] = Number(value)
                    }

                    // 修改bind_ouput_icd
                    if (id === "bind_ouput_icd") {
                        d["bind_ouput_icd"] = Number(value)
                    }

                    listComponent.model.set(listComponent.currentIndex, d)
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
