import QtQuick 2.5

import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3

Item {
    id: send

    property var curSegments:[]

    //按照载荷规则更新列表数据
    function updateContent() {
        if (content.length < 1) return

        bind.model.clear()
        bind.selection.clear()
        bind.currentRow = -1


        curSegments = deepCopy(content[icdBox.currentIndex].values)

        var info
        for (var i = 0; i < curSegments.length; i++) {
            info = curSegments[i]
            bind.model.append({"name":info.name, "value":"0"})
        }

        if( curSegments.length > 0 )
        {
            bind.currentRow = 0
            bind.selection.select(0)
        }
    }

    function deepCopy(arr){
        var newobj = [];
        for(var i = 0;i<arr.length;i++){
            var obj = {}
            for ( var j in arr[i]) {
                obj[j] = arr[i][j];
            }
            newobj.push(obj)
        }
        return newobj;
    }

    function generateData(value) {
        detailCom.rawValue = value
        detailCom.datagram = value
        //console.log("--->value : "+value)
        var formated = []
        for (var i=0; i<value.length/2; ++i) {
            var line = value.slice(i*2, i*2+2)
            if (i !== 0) {
                if (i % 16 === 0)
                    line = "\n"+line
                else if (i % 8 === 0)
                    line = "  "+line
            }

            formated.push(line)
        }
        //console.log("--->formated : "+formated)
        detailCom.combineData = formated.join(" ").toUpperCase()
    }

    function getIP() {
        return ipBox.text
    }

    function getPort() {
        return portField.text
    }

    function getServerIP() {
        return severipBox.text
    }

    function getServerPort() {
        return severportField.text
    }

    //参数:ICD中的工程值们，values
    function updateData(segments) {

        var icdSize = 0, info
        for (var i = 0; i < segments.length; i++) {
            info = segments[i]
            icdSize += info.size
        }

        var dts = []
        for (i=0; i<bind.model.count; ++i) {
            dts.push(bind.model.get(i).value)
        }

        var data = Excutor.combine(segments, dts, icdSize)
        var idValue = String(Excutor.octToHex(idText.text))
//        var fill = ""
//        if (idValue.length < 8) {
//            for (i = 0; i < 8-idValue.length; i++) {
//                fill += "0"
//            }
//            idValue = fill +idValue
//        }

        generateData(String(idValue+data))
    }

    ColumnLayout {
        anchors.fill: parent
        GroupBox {
            id: netSet
            title: "网络设置"
            Layout.fillWidth: true
            Layout.alignment: Qt.AlignTop
            Layout.margins: 5
//            anchors.left: parent.left
//            anchors.right: parent.right
//            anchors.top: parent.top
//            anchors.margins: 5

            RowLayout {
                spacing: 12
                id:row1
                anchors.top: parent.top

                Label {
                    text: "服务器UDP地址："
                }

                TextField {
                    id: severipBox
                    text: "127.0.0.1"
                    Layout.minimumWidth: 130
                }

                Label {
                    text: "端口："
                }

                TextField {
                    id: severportField
                    text: "9000"
                }

                Label {
                    text: "接收端UDP地址："
                }

                TextField {
                    id: ipBox
                    text: "127.0.0.1"
                    Layout.minimumWidth: 130
                }

                Label {
                    text: "端口："
                }

                TextField {
                    id: portField
                    text: "9000"
                }
            }

        }

        GroupBox {
            id: root
            title: "数据编辑"
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.margins: 5
            //Layout.alignment: Qt.AlignBottom
//            anchors.left: parent.left
//            anchors.right: parent.right
//            anchors.top: netSet.bottom
//            anchors.bottom: parent.bottom
//            anchors.margins: 5

            ColumnLayout {
                anchors.fill: parent
                RowLayout {
                    id: icdRow
                    spacing: 5

                    Label {text: "ICD列表："}

                    ComboBox {
                        id: icdBox
                        model:[]
                        Layout.minimumWidth: 220

                        onCurrentIndexChanged: {
                            updateContent()
                            var curIndex = icdBox.currentIndex
                            if (curIndex > -1 && curIndex < content.length) {
                                idText.text = content[curIndex].id
                                updateData(curSegments)
                            }
                        }
                    }

                    Label {text: "  ID："}

                    TextField {
                        id: idText
                        enabled: false
                    }
                }

                SplitView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    PayloadBind {
                        id: bind
                        implicitWidth: 300
                        implicitHeight: 150

                        onCurrentRowChanged: {
                            if (currentRow < 0 || bind.model.count === 0) return
                            var propss = content[icdBox.currentIndex].values[currentRow]
                            var info ={}
                            for ( var j in propss) {
                                info[j] = propss[j];
                            }

                            info["data"] = bind.model.get(currentRow).value
//                            var info = {"name":propss.name,
//                                "offset":propss.offset,
//                                "size":propss.size,
//                                "mask":propss.mask,
//                                "order":propss.order,
//                                "type":propss.type,
//                                "desc":propss.desc,
//                                "dim":propss.dim,
//                                "amp":propss.amp,
//                                "data":bind.model.get(currentRow).value
//                            }
                            detailCom.detail = info
                        }
                    }

                    PayloadShowDetail{
                        id: detailCom
                        implicitHeight: 140
                        leader: send

                        onDataChanged: {
                            curSegments[bind.currentRow] = value
                            bind.model.set(bind.currentRow, {"name": value.name, "value":value.data})
                            updateData(curSegments)
                        }
                    }
                }
            }

//            Component.onCompleted: {

//                var icdArray = new Array
//                for (var i =0; i < content.length; i++) {
//                    var icd = content[i]
//                    icdArray.push(icd.name)
//                }

//                icdBox.model = icdArray
//                var curIndex = icdBox.currentIndex
//                if (curIndex > -1 && curIndex < content.length) {
//                    idText.text = content[curIndex].id
//                }

//                updateContent()

//                var segments = content[icdBox.currentIndex].values

//                updateData(segments)
//            }

        }
    }

    function load(){
        var icdArray = new Array
        for (var i =0; i < content.length; i++) {
            var icd = content[i]
            icdArray.push(icd.name)
        }

        icdBox.model = icdArray
        var curIndex = icdBox.currentIndex
        if (curIndex > -1 && curIndex < content.length) {
            idText.text = content[curIndex].id
        }

        updateContent()
        updateData(curSegments)
    }


}
