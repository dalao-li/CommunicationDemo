import QtQuick 2.5
import DesktopControls 0.1

ListView {
    id: root

    property var busType
    property var payloads
    property var editorConfig
    focus: true
    implicitWidth: 200
    model: ListModel {}
    header: Item {
        height: 25
        width: root.width
        ComboBox {
            id: buses
            height: parent.height
            width: parent.width - batchAdd.width - 13
            model: {
                var names = ["全部"]
                for (var i=0; i<editorConfig.length; ++i) {
                    names.push(editorConfig[i].name)
                }

                return names
            }

            onActivated: {
                root.model.clear()

                if (index > 0)
                    root.busType = editorConfig[index-1].bus_type
                else
                    root.busType = undefined
                for (var i=0; i<root.payloads.length; ++i) {
                    var payload = root.payloads[i]
                    if (index === 0 || payload.bus_type === root.busType) {
                        payloadsList.model.append({name: payload.name})
                    }
                }
            }
        }

        BatchAddButton {
            id: batchAdd
            anchors.right: parent.right
            anchors.rightMargin: 8
            anchors.verticalCenter: parent.verticalCenter
            onClicked: {
                var max = 0
                switch (index) {
                case -1:
                    max = 1
                    break;
                case 0: //5
                    max = 5
                    break;
                case 1: //10
                    max = 10
                    break;
                case 2: //20
                    max = 20
                    break;
                }
                for (var i=0; i<max; ++i) {
                    var info = {
                        "name":"载荷"+String(root.payloads.length),
                        "pays":[
                            0,
                            0,
                            167772416,
                            167772416,
                            0,
                            0],
                        "id":String(generateId()),
                        "bus": 0,
                        "bus_type": "afdx",
                        "values":[]
                    }
                    root.payloads.push(info)
                    root.model.append({"name": info.name})

                    Excutor.excute({"command":"append_payload",
                                       "payload":info
                                   })
                }
            }
        }
    }

    function contains(id) {
        for (var i=0; i<root.payloads.length; ++i) {
            if (root.payloads[i].id === id) {
                return true
            }

            return false
        }
    }

    function generateId() {
        var i = 0;
        for (;;) {
            if (!contains(String(i))) return i

            ++i;
        }
    }

    delegate: Label {
        x: 3
        height: 27
        width: root.width
        text: name
    }

    highlight: Rectangle {
        id: rowDelegate
        color: Qt.darker(Theme.current.accent, 1.5)
        Row {
            spacing: 3
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter
            anchors.rightMargin: 10
            AwesomeButton {
                id: add
                backgroundColor: rowDelegate.color
                name: "plus"
                onClicked: {
                    var info = {
                        "name":"载荷"+root.currentIndex+1,
                        "pays":[
                            0,
                            0,
                            167772416,
                            167772416,
                            0,
                            0],
                        "id":String(generateId()),
                        "bus": 0,
                        "bus_type": "afdx",
                        "values":[]}
                    root.payloads.splice(root.currentIndex+1, 0, info)
                    root.model.insert(root.currentIndex+1, {name:info.name})

                    Excutor.excute({"command":"append_payload",
                                       "payload":info
                                   })
                }
            }
            AwesomeButton {
                id: remove
                backgroundColor: rowDelegate.color
                name: "minus"
                onClicked: {
                    root.payloads.splice(root.currentIndex, 1)
                    root.model.remove(root.currentIndex, 1)

                    Excutor.excute({"command":"remove_payload",
                                       "index":root.currentIndex
                                   })
                }
            }
        }
    }

    MouseArea {
        anchors.fill: parent
        propagateComposedEvents: true
        onPressed: {
            mouse.accepted = false
            root.currentIndex = root.indexAt(mouse.x, mouse.y - headerItem.height)
        }
        onReleased: mouse.accepted = false
        onDoubleClicked: mouse.accepted = false
        onPressAndHold: mouse.accepted = false
    }
}
