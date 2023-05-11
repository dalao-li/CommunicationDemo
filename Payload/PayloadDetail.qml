import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Dialogs 1.2

Item {
    id: root

    property int defaultHeight: 60
    property var payload

    height: defaultHeight

    signal itemChanged(string id, string value)

    // 另存为文件
    FileDialog {
        id: newfileDialog
        title: "Please choose a file"

        selectExisting: false
        nameFilters: ["json files (*.json)", "All files (*)"]
        onAccepted: {
            var path = String(newfileDialog.fileUrls).substring(8)
            saveDeviceICDInfo(path)
        }
        onRejected: {
            console.log("Canceled")
        }
    }

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
            id: name
            width: 100
            height: 25
            onTextChanged: {
                if (root.payload) {
                    root.payload.name = text
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
            inputMask: ">HH"

            onTextChanged: {
                // 清除上次输入的值
                icdIDField.value &= 0xFFFFFF
                icdIDField.value |= (parseInt(text, 16) << 24)
            }
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
            inputMask: ">HH"
            text: ""
            onTextChanged: {
                icdIDField.value &= 0xFF00FFFF
                icdIDField.value |= (parseInt(text, 16) << 16)
            }
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
            inputMask: ">HHHH"

            onTextChanged: {
                icdIDField.value &= (0xFFFF0000)
                icdIDField.value |= (parseInt(text, 16))
            }
        }

        // icd id
        Label {
            text: "ID"
            height: 25
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        SpinBox {
            id: icdIDField
            width: 80
            height: 25
            //value:
            maximumValue: 99999999999
            onValueChanged: {
                if (root.payload) {
                    root.payload.id = String(value)
                    root.itemChanged("id", String(value))
                }
            }
        } 
    } // end flow

    // 加载函数
    function load(value) {
        payload = value
        name.text = value.name
        icdIDField.value = Number(value.id)
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

    function splitValue(value) {
        const factoryValue = (value >> 24) & 0xFF
        const deviceValue = (value >> 16) & 0x00FF
        const dataValue = value & 0xFFFF

        factoryID.text = factoryValue.toString(16)
        deviceID.text = deviceValue.toString(16)
        dataID.text = dataValue.toString(16)
    }
}
