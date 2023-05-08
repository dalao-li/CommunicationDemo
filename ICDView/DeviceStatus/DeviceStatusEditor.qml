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
            // 水平布局, 设置组件宽度
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
                    // 获取侧边栏对应索引的数据
                    var s = getStatusValue(deviceStatusList.currentIndex)

                    deviceStatusDetail.load(s)
                    deviceStatusSegment.load(s.monitor_status)
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

                    if (id === "type_name") {
                        deviceStatusList.model.set(deviceStatusList.currentIndex, {"type_name": value})
                    }

                    if (id === "desc") {
                        deviceStatusList.model.set(deviceStatusList.currentIndex, {"desc": value})
                    }

                    if (id === "device") {
                        // var deviceValue = deviceIDComboxValue[Number(value)]
                        // console.log("----->", JSON.stringify(deviceValue))
                        deviceStatusList.model.set(deviceStatusList.currentIndex, {"device": value})

                        console.log("->", JSON.stringify(deviceStatusList))
                    }
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

    function getStatusValue(index) {
        return root.status[index]
    }
}
