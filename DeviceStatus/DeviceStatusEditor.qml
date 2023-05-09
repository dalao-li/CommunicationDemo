import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import DesktopControls 0.1

ColumnLayout {
    id: root
    property var status: []
    property alias deviceStatusList: deviceStatusList
    property alias deviceStatusDetail: deviceStatusDetail

    SplitView {
        Layout.fillHeight: true
        Layout.fillWidth: true

        // 侧边栏
        Rectangle {
            implicitWidth: 200
            Layout.fillHeight: true
            color: "#f0f0f0"

            // al
            DeviceStatusList {
                id: deviceStatusList
                anchors.fill: parent
                Layout.fillHeight: true
                status: root.status

                onCurrentIndexChanged: {
                    if (deviceStatusList.currentIndex < 0) {
                        return
                    }

                    var s = root.status[deviceStatusList.currentIndex]
                    deviceStatusDetail.load(s)
                    deviceStatusSegment.load(s)
                }
            } // DeviceStatusList end
        }

        // 右上方
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#f0f0f0"

            DeviceStatusDetail {
                id: deviceStatusDetail
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                onItemChanged: {
                    if (deviceStatusList.currentIndex < 0) {
                        return
                    }

                    var d = {}
                    if (id === "type_name") {
                        d["type_name"] = value
                    }

                    if (id === "desc") {
                        d["desc"] = value
                    }

                    if (id === "device_id") {
                        d["device_id"] = value
                    }
                    deviceStatusList.model.set(deviceStatusList.currentIndex, d)
                }
            }

            DeviceStatusSegmentList {
                id: deviceStatusSegment
                anchors {
                    left: parent.left
                    right: parent.right
                    top: deviceStatusDetail.bottom
                    topMargin: 5
                    bottom: parent.bottom
                }
            }
        }
    }
}
