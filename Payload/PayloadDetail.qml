/*
 * @Description:
 * @Version: 1.0
 * @Author: liyuanhao
 * @Date: 2023-05-09 19:05:47
 * @LastEditors: Please set LastEditors
 * @LastEditTime: 2023-05-10 14:52:15
 */

import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2

Item {
    id: root

    property int defaultHeight: 60
    property var _payload

    signal itemChanged(string id, string value)

    height: defaultHeight

    Rectangle {
        id: title
        anchors {
            left: parent.left
            right: parent.right
        }

        height: 32
        color: "#e5e5e5"

        Label {
            anchors.centerIn: parent
            text: "载荷"
        }

        MouseArea {
            anchors.fill: parent
            onClicked: {
                // 折叠
                if (root.height === defaultHeight) {
                    root.height = title.height
                } else {
                    root.height = defaultHeight
                }
                flow.visible = !flow.visible
            }
        }
    } // title end

    Flow {
        id: flow
        anchors {
            topMargin: 3
            top: title.bottom
            bottom: parent.bottom
            left: parent.left
            leftMargin: 3
            right: parent.right
        }

        spacing: 15

        Label {
            text: "名称"
            height: 25
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        TextField {
            id: nameField
            width: 200
            height: 25
            onTextChanged: {
                if (root._payload) {
                    root._payload.name = text
                    root.itemChanged("name", text)
                }
            }
        }

        // 新增
        Label {
            text: "厂家号"
            height: 25
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        TextField {
            id: factoryID
            width: 25
            height: 25
            text: ""
            //inputMask: ">HH"
            onTextChanged: calculateICDID()
        }

        Label {
            text: "设备号"
            height: 25
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        TextField {
            id: deviceID
            width: 25
            height: 25
            //inputMask: ">HH"
            text: ""
            onTextChanged: calculateICDID()
        }

        Label {
            text: "数据号"
            height: 25
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        TextField {
            id: dataID
            width: 40
            height: 25
            text: ""
            //inputMask: ">HHHH"

            onTextChanged: calculateICDID()
        }

        // ICD的id
        Label {
            text: "ID"
            height: 25
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        TextField {
            id: icdIDField
            width: 200
            height: 25
            text: ""
            //inputMask: ">HHHH"
            onTextChanged: {
                if (root._payload) {
                    splitICDID(Number(text))
                    root._payload.id = text
                    root.itemChanged("id", text)
                }
            }
        }

    } // end flow

    function load(value) {
        _payload = value
        nameField.text = value.name
        icdIDField.text = value.id

    }

    function clear() {
        nameField.text = ""
        icdIDField.text = 0
    }

    // 根据工厂ID, 设备ID, 数据ID计算ICD ID
    function calculateICDID() {
        var factoryValue = Number(factoryID.text)
        var deviceValue = Number(deviceID.text)
        var dataValue = Number(dataID.text)

        var value = 0
        value |= (parseInt(factoryValue, 16) << 24)
        value |= (parseInt(deviceValue, 16) << 16)
        value |= (parseInt(dataValue, 16))

        icdIDField.text = String(value)
    }

    // 根据ICD ID拆分工厂ID, 设备ID, 数据ID
    function splitICDID(value) {
        const factoryValue = (value >> 24) & 0xFF
        const deviceValue = (value >> 16) & 0x00FF
        const dataValue = value & 0xFFFF

        factoryID.text = factoryValue.toString(16)
        deviceID.text = deviceValue.toString(16)
        dataID.text = dataValue.toString(16)
    }

    function analyzePays(value) {
        var pays = []
        var temp = value.split(",")
        for (; i < temp.length; ++i) {
            pays.push(Number(temp[i]))
        }

        return pays
    }

    function getValue(text) {
        var values = text.split(".")
        if (values.length !== 4)
            return

        var tempValue = Number("0x" + Number(
                                   values[0]).toString(16)) << 24 | Number(
                    "0x" + Number(values[1]).toString(16)) << 16 | Number(
                    "0x" + Number(values[2]).toString(16)) << 8 | Number(
                    "0x" + Number(values[3]).toString(16))

        return Number(tempValue.toString(10))
    }

    function getIp(value) {
        var array = []
        array.push(String(value & 0xFF000000) >> 24)
        array.push(String(value & 0x00FF0000) >> 16)
        array.push(String(value & 0x0000FF00) >> 8)
        array.push(String(value & 0x000000FF))

        return array.join(".")
    }
}
