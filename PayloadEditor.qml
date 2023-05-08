import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import DesktopControls 0.1
import PayloadEditor 0.1

ControlContainer {
    id: root
    objectName: "PayloadEditor"
    toolBarActions: [
        {"action":"open","size":16,"icon":"level_down","tooltip":"导入"},
        {"action":"save","size":16,"icon":"level_up","tooltip":"导出"}
    ]

    onToggled: {
        fileDialogConnect.enabled = true
        __sysFileDialog.nameFilters = ["载荷配置 (*.payloads)"]
        if (index === 0) {
            //open
            __sysFileDialog.selectExisting = true
            __sysFileDialog.open()
        } else if (index === 1) {
            //save
            __sysFileDialog.selectExisting = false
            __sysFileDialog.open()
        }
    }

    title: ""
    property var payloads: []
    property var editorConfig: readEditorConfig()
    property alias payloadsList: payloadsList
    Component.onCompleted: {
        var payloads = Excutor.query({"payloads":""})
        load(payloads)
    }

    function load(config) {
        payloadsList.model.clear()
        payloads = config
        for (var i=0; i<config.length; ++i) {
            var payload = config[i]
            payloadsList.model.append({name: payload.name})
        }
    }
    function savePayload( path ){
        Excutor.excute({"command":"write",
                           content:Framework.formatJSON(JSON.stringify(root.payloads)),
                           path:path})
    }

    function openPayload(path){
        var config = Excutor.query({"read":path})
        load(config)
    }

    function cleanPayload(){
        payloadsList.model.clear()
        segments.load([])
    }

    function readEditorConfig() {
        var apppath = Excutor.query({"apppath":""})
        var config = Excutor.query({"read":apppath+"/config/payload_edit.json"})
        for (var i=0; i<config.length; ++i) {
            var c = config[i]
            c.bus = i
        }

        return config
    }

    //按照总线类型bus获取index的载荷数据
    function getPayload(index, busType) {
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

    PayloadEditorHelper {
        id: helper
    }

    SplitView {
        anchors.fill: parent
        handleDelegate: SplitViewHandleDelegate {implicitWidth: 3}
        Rectangle {
            color: Theme.current.subBackground
            implicitWidth: 200
            Layout.fillHeight: true
            PayloadList {
                id: payloadsList
                anchors.fill: parent
                payloads: root.payloads
                editorConfig: root.editorConfig
                onCurrentIndexChanged: {
                    if (payloadsList.currentIndex < 0) return

                    var payload = getPayload(payloadsList.currentIndex, payloadsList.busType)
                    detail.load(payload)
                    segments.load(payload.values)
                }
            }
        }

        Rectangle {
            color: Theme.current.subBackground
            Layout.fillWidth: true
            Layout.fillHeight: true
            PayloadDetail {
                id: detail
                editorConfig: root.editorConfig
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }
                onItemChanged: {
                    if (payloadsList.currentIndex < 0) return

                    if (id === "name")
                        payloadsList.model.set(payloadsList.currentIndex, {"name":value})

                    Excutor.excute({"command":"set_payload",
                                       "payload":detail.payload,
                                       "index":payloadsList.currentIndex})
                }
            }

            SegmentList {
                id: segments
                anchors {
                    left: parent.left
                    right: parent.right
                    top: detail.bottom
                    topMargin: 80
                    bottom: parent.bottom
                }
                helper: helper
                onItemChanged: {
                    Excutor.excute({"command":"set_payload",
                                       "payload":detail.payload,
                                       "index":payloadsList.currentIndex})
                }
            }
        }
    }
    Connections {
        id: fileDialogConnect
        target: enabled ? __sysFileDialog : null
        property bool enabled: false
        onAccepted: {
            if (!enabled) return

            if (!__sysFileDialog.selectExisting) {
                //save
                var full = __sysFileDialog.fullPath(String(__sysFileDialog.fileUrl))
                root.savePayload(full)
            } else {
                //open
                full = __sysFileDialog.fullPath(String(__sysFileDialog.fileUrl))
                var tmp = Excutor.query({"read":full})
                root.load(tmp)
                Excutor.excute({"command":"set_payloads",
                                   "payloads":JSON.parse(tmp)})
            }
            fileDialogConnect.enabled = false
        }
        onRejected: {
            fileDialogConnect.enabled = false
        }
    }
}
