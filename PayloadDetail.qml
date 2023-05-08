import QtQuick 2.5
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import DesktopControls 0.1 as Desktop

Flickable {
    id: root
    contentHeight: lay.implicitHeight
    contentWidth: lay.implicitWidth
    clip: true

    property var detail: {"name":"name","offset":0,"size":4,"mask":"0xff",
                          "type":0,"order":0,"desc":"desc","data":""}

    property var typeModel: ["整型", "单精度浮点", "双精度浮点", "字符串"]

    property alias combineData: dataArea.text

    property string rawValue: ""

    property var leader

    signal itemChanged(var value)

    function clear() {
        root.detail = {"name":"name","offset":0,"size":4,"mask":"0xff",
            "type":0,"order":0,"desc":"desc","data":""}
    }

    Column{
        id: lay
        anchors{
            top: parent.top
            left: parent.left
            right: parent.right
            margins: 15
        }
        spacing: 25

        GridLayout {
            columns: 6
            columnSpacing: root.width/6-35
            rowSpacing: 20
            Column {
                spacing: 5
                Label{
                    id: name
                    text: "名称"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    enabled: false
                }
                Label {
                    id: nameText
                    verticalAlignment: Text.AlignVCenter
                    text: detail.name
                }
            }

            Column {
                spacing: 5
                Label{
                    id: offset
                    text: "偏移"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    enabled: false
                }
                Label {
                    id: offsetText
                    verticalAlignment: Text.AlignVCenter
                    text: String(detail.offset)
                }
            }

            Column {
                spacing: 5
                Label{
                    id: size
                    text: "大小"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    enabled: false
                }
                Label {
                    id: sizeText
                    verticalAlignment: Text.AlignVCenter
                    text: String(detail.size)
                }
            }

            Column {
                spacing: 5
                Label{
                    id: mask
                    text: "掩码"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    enabled: false
                }
                Label {
                    id: maskText
                    verticalAlignment: Text.AlignVCenter
                    text: detail.mask
                }
            }

            Column {
                spacing: 5
                Label{
                    id: order
                    text: "大小端"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    enabled: false
                }
                Label {
                    id: orderText
                    verticalAlignment: Text.AlignVCenter
                    text: detail.order === 0 ? "小端" : "大端"
                }
            }

            Column {
                spacing: 5
                Label{
                    text: "类型"
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    enabled: false
                }

                Label {
                    id: type
                    verticalAlignment: Text.AlignVCenter
                    text: typeModel[detail.type]
                }
            }
        }

        Column {
            spacing: 5
            Label{
                text: "值"
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                enabled: false
            }
            TextField {
                id: textValue
                anchors.horizontalCenter: parent.horizontalCenter
                text: detail.data
                onTextChanged: {
                    detail.data = text
                    root.itemChanged(detail)
                }
            }
        }

        Column {
            spacing: 10

            Label{
                id: desc
                text: "工程值详细信息描述"
                verticalAlignment: Text.AlignVCenter
                enabled: false
            }
            Label {
                id: descText
                text: detail.desc
            }
        }

        Column {
            spacing: 10

            Label{
                id: dataBrowser
                text: "数据预览(前四个字节为ICD的唯一标识ID,第五字节开始为真正的数据)"
                verticalAlignment: Text.AlignVCenter
                enabled: false
            }
            TextArea {
                id: dataArea
                implicitHeight: 50
                Layout.fillWidth: true
                enabled: false
            }
        }

        ColumnLayout {
            Item {Layout.fillWidth: true}
            Button {
                text: "发送"

                onClicked: {
                    var info = new Object
                    info["ip"] = leader.getIP()
                    info["port"] = Number(leader.getPort())
                    info["data"] = rawValue
                    info["size"] = rawValue.length

                    Excutor.send(info)
                }
            }
        }
    }
}
