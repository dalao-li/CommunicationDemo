import QtQuick 2.5

import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3

ColumnLayout {
    anchors.fill: parent
    anchors.margins: 5
    GroupBox {
        id: netSet
        title: "网络设置"
        Layout.fillWidth: true
        Layout.margins: 5

        RowLayout {
            spacing: 12

            Label {
                text: "服务器地址："
                //visible: false
            }

            TextField {
                id: ipBox
                text: "127.0.0.1"
                Layout.minimumWidth: 130
                //visible: false
            }

            Label {
                text: "端口："
            }

            TextField {
                id: portField
                text: "9000"
            }

            Button {
                text: "监听"

                onClicked: {
                    if (!ipBox.enabled) {
                        ipBox.enabled = true
                        portField.enabled = true
                        Excutor.bind(ipBox.text,Number(portField.text), false)
                    }
                    else {
                        ipBox.enabled = false
                        portField.enabled = false
                        Excutor.bind(ipBox.text,Number(portField.text), true)
                    }
                }
            }
        }
    }

    TextArea {
        id: dataArea
        Layout.fillHeight: true
        Layout.fillWidth: true

    }

    function stopListen(){
        if (!ipBox.enabled) {
            ipBox.enabled = true
            portField.enabled = true
            Excutor.bind(ipBox.text,Number(portField.text), false)
        }
    }

    Component.onCompleted: {
        Excutor.recvData.connect(function(data) {
            var strData = String(data)
            //console.log("recv data: "  + strData)
            dataArea.append("recv data: "  + strData.toUpperCase())
            for (var i = 0; i < content.length; i++) {
                var segment = content[i]
                if (Number(segment.id) === parseInt(strData.substring(0,8), 16)) {
                    var d = strData.substring(8)
                    var result = Excutor.parseData(d,segment)
                    for (var j = 0; j < result.length; j++) {
                        dataArea.append("    " + segment.values[j].name + ": "+ result[j])
                    }
                }
            }
        })
    }

}
