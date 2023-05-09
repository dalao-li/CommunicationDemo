import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import DesktopControls 0.1

ColumnLayout {
    id: root
    objectName: "PayloadEditor"

    property var payloads: []

    // 外部控件
    property alias payloadsList: payloadsList
    property alias payloadDetail: detail

//    Component.onCompleted: {
//        var payloads = Excutor.query({"payloads":""})
//        load(payloads)
//    }

    SplitView {
        Layout.fillHeight: true
        Layout.fillWidth: true

        Rectangle {
            // 水平布局, 设置组件宽度
            implicitWidth: 200
            Layout.fillHeight: true
            color: "#f0f0f0"

            // 侧边栏
            PayloadList {
                id: payloadsList
                anchors.fill: parent
                Layout.fillHeight: true

                payloads: root.payloads

                onCurrentIndexChanged: {
                    if (payloadsList.currentIndex < 0) {
                        return
                    }
                    // 获取侧边栏对应索引的数据
                    var value = getPayload(payloadsList.currentIndex, payloadsList.busType)

                    // console.log("->", JSON.stringify(value))

                    detail.load(value)
                    segmentList.load(value.values)
                }
            } // PayloadList end
        }

        // 右上方
        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#f0f0f0"

            PayloadDetail {
                id: detail
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                onItemChanged: {
                    if (payloadsList.currentIndex < 0) {
                        return
                    }

                    if (id === "name") {
                        payloadsList.model.set(payloadsList.currentIndex, {"name": value})
                    }
                }
            }

            SegmentList {
                id: segmentList

                anchors {
                    left: parent.left
                    right: parent.right
                    top: detail.bottom
                    topMargin: 5
                    bottom: parent.bottom
                }
            }
        }
    }

    function load(config) {
        payloadsList.model.clear()
        payloads = config
        for (var i = 0; i < config.length; ++i) {
            var payload = config[i]
            payloadsList.model.append({name: payload.name})
        }
        payloadsList.currentIndex = 0
        var payloadValue = getPayload(payloadsList.currentIndex, payloadsList.busType)
        detail.load(payloadValue)
        segmentList.load(payloadValue.values)
    }

    function save() {
        payloadsList.savePayload(path)
    }


    function openPayload(path) {
        var config = Excutor.query({"read":path})
        load(config)
    }

    function cleanPayload() {
        payloadsList.model.clear()
        segmentList.load([])
    }

    //按照总线类型bus获取index的载荷数据
    function getPayload(index, busType) {
        // console.log("----->", root.payloads)
        if (!busType)
            return root.payloads[index]

        var counter = -1
        for (var i=0; i<root.payloads.length; ++i) {
            var payload = root.payloads[i]
            if (payload.bus_type === busType)
                ++counter

            if (index === counter)
                return payload
        }
    }

    //按照总线类型bus更改index的载荷数据
    function setPayload(index, busType, value) {
        if (!busType)
            return root.payloads[index] = value

        var counter = -1
        for (var i=0; i<root.payloads.length; ++i) {
            var payload = root.payloads[i]
            if (payload.bus_type === busType)
                ++counter

            if (index === counter)
                return root.payloads[i] = value
        }
    }
}
