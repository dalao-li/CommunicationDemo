import QtQuick 2.5

import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.3
import DesktopControls 0.1

Dialog {
    id:root
    width: 300
    height: 410

    title: "批量添加对话框"

    function getInfos() {
        return {
            "send_vl": sendVL.value, "send_port": sendPort.value,
            "send_net": txNet.currentIndex,
            "recv_net": rxNet.currentIndex,
            "send_count": sendCount.value, "send_interval": interval.value,
            "recv_vl": recvVL.value, "recv_port": recvPort.value
        }
    }

    Column {
        spacing: 5
        anchors.margins: 15
        anchors.top: parent.top
        anchors.horizontalCenter: parent.horizontalCenter
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            Label {
                width: 100
                anchors.verticalCenter: parent.verticalCenter
                text: "发送网络："
            }
            ComboBox {
                id: txNet
                model: ["A", "B", "AB", "C", "D", "CD"]
            }
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            Label {
                width: 100
                anchors.verticalCenter: parent.verticalCenter
                text: "发送VL数："
            }
            SpinBoxInt {
                id: sendVL

                maximumValue: 65535
                minimumValue: 0
                value: 128
            }
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            Label {
                width: 100
                anchors.verticalCenter: parent.verticalCenter
                text: "发送端口数："
            }
            SpinBoxInt {
                id: sendPort

                maximumValue: 65535
                minimumValue: 1
                value: 8
            }
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            Label {
                width: 100
                anchors.verticalCenter: parent.verticalCenter
                text: "发送个数："
            }
            SpinBoxInt {
                id: sendCount

                maximumValue: 65535
                minimumValue: 0
                value: 10
            }
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            Label {
                width: 100
                anchors.verticalCenter: parent.verticalCenter
                text: "发送时间间隔："
            }
            SpinBoxInt {
                id: interval

                maximumValue: 65535
                minimumValue: 0
                value: 1000
            }
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            Label {
                width: 100
                anchors.verticalCenter: parent.verticalCenter
                text: "接收网络："
            }
            ComboBox {
                id: rxNet
                currentIndex: 1
                model: ["A", "B", "AB", "C", "D", "CD"]
            }
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            Label {
                width: 100
                anchors.verticalCenter: parent.verticalCenter
                text: "接收VL数："
            }
            SpinBoxInt {
                id: recvVL

                maximumValue: 65535
                minimumValue: 0
                value: 128
            }
        }
        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            Label {
                width: 100
                anchors.verticalCenter: parent.verticalCenter
                text: "接收端口数："
            }
            SpinBoxInt {
                id: recvPort

                maximumValue: 65535
                minimumValue: 1
                value: 8
            }
        }
    }
    Row {
        spacing: 5
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.margins: 15
        Button {
            text: "确认"
            onClicked: {
                root.accepted()
            }
        }
        Button {
            text: "取消"
            onClicked: {
                root.rejected()
            }
        }
    }
}
