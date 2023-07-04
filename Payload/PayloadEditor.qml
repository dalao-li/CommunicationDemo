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
    objectName: "PayloadEditor"

    property var payloads: []

    SplitView {
        Layout.fillHeight: true
        Layout.fillWidth: true

        // 侧边栏
        Rectangle {
            // 水平布局, 设置组件宽度
            implicitWidth: 200
            Layout.fillHeight: true
            color: "#f0f0f0"

            PayloadList {
                id: listComponent
                anchors.fill: parent
                Layout.fillHeight: true

                payloads: root.payloads

                onCurrentIndexChanged: {
                    if (listComponent.currentIndex < 0) {
                        return
                    }
                    var data = root.payloads[listComponent.currentIndex]
                    detailComponent.load(data)
                    segmentComponent.load(data.values)
                }

                onCountChanged: {
                    if (listComponent.count <= 0) {
                        detailComponent.clear()
                        segmentComponent.clear()
                    }
                }
            } // PayloadList end
        }

        // 标题栏
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#f0f0f0"

            // 顶部编辑
            PayloadDetail {
                id: detailComponent
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                onItemChanged: {
                    var newValue = {}
                    if (listComponent.currentIndex < 0) {
                        return
                    }
                    if (id === "name") {
                        newValue = {"name": value}
                    }

                    if (id === "id") {
                        newValue = {"id": value}
                    }
                    listComponent.model.set(listComponent.currentIndex, newValue)
                }
            }

            // 表格
            SegmentList {
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

    function load(config) {
        listComponent.model.clear()
        for (var i = 0; i < config.length; ++i) {
            var payload = config[i]
            //console.log("payload", JSON.stringify(payload))
            root.payloads.push(payload)
            listComponent.model.append({name: payload.name})
        }
        listComponent.currentIndex = 0

        //var payloadValue = getPayload(listComponent.currentIndex, listComponent.busType)
//        var data = root.payloads[]
//        detailComponent.load(payloadValue)
//        segmentComponent.load(payloadValue.values)
    }


    function openPayload(path) {
        var config = Excutor.query({"read":path})
        load(config)
    }

    function cleanPayload() {
        listComponent.model.clear()
        segmentComponent.load([])
    }

    // 按照总线类型bus获取index的载荷数据
    function getPayload(index, busType) {
        if (!busType) {
            return root.payloads[index]
        }

        var counter = -1
        for (var i= 0; i<root.payloads.length; ++i) {
            var payload = root.payloads[i]
            if (payload.bus_type === busType) {
                ++counter
            }

            if (index === counter) {
                return payload
            }
        }
    }

    // 按照总线类型bus更改index的载荷数据
    function setPayload(index, busType, value) {
        if (!busType) {
            return root.payloads[index] = value
        }

        var counter = -1
        for (var i=0; i<root.payloads.length; ++i) {
            var payload = root.payloads[i]
            if (payload.bus_type === busType) {
                ++counter
            }

            if (index === counter) {
                return root.payloads[i] = value
            }
        }
    }
}
