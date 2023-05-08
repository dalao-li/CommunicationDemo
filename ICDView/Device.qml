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
        // anchors.fill: parent
        Layout.fillHeight: true
        Layout.fillWidth: true

        Rectangle {
            implicitWidth: 200
            Layout.fillHeight: true
            color: "#f0f0f0"

            // 侧边栏
            DeviceList {
                id: deviceList
                anchors.fill: parent
                Layout.fillHeight: true

                devices: root.devices

                onCurrentIndexChanged: {
                    // 获取侧边栏对应索引的数据
                    var device = getDevice(deviceList.currentIndex)
                    deviceDetail.load(device)
                }
            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#f0f0f0"

            // 编辑界面
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
                        if (value["opeator"] === "add") {
                            var addValue = []
                            if (value["type"] === "input") {
                                addValue = deviceList.model[deviceList.currentIndex].input_icd
                                addValue.push(value["icd_id"])
                                d["input_icd"] = addValue
                            }

                            if (value["type"] === "ouput") {
                                addValue = deviceList.model[deviceList.currentIndex].ouput_icd
                                addValue.push(value["icd_id"])
                                d["ouput_icd"] = addValue
                            }
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


    // 获取产品
    function getDevice(index) {
        return root.devices[index]
    }
}
