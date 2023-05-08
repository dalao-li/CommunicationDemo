import QtQuick 2.5
import Qt.labs.settings 1.0
import QtQuick.Controls 1.4
import DesktopControls 0.1 as Desktop

Item {
    id: root

    signal itemChanged()

    property var helper
    property var segments
    function load(values) {
        batchAdd.enabled = true
        table.model.clear()
        segments = values
        for (var i=0; i<values.length; ++i) {
            var segment = values[i]
            table.model.append({"name":segment.name,"bit_start":helper.bitStart(segment),
                                   "bit_length":helper.bitLength(segment),
                                   "offset":segment.offset, "size":segment.size,
                                   "mask":segment.mask, "order":segment.order,
                                   "type":segment.type, "desc":segment.desc,
                                   "dim":segment.dim, "amp":segment.amp})
        }
    }

    Rectangle {
        id: title
        anchors {
            left: parent.left
            right: parent.right
            top: parent.top
        }
        color: Desktop.Theme.current.section

        height: 32

        Desktop.Label {
            anchors.centerIn: parent
            text: "字段"
        }

        Row {
            anchors.right: parent.right
            anchors.rightMargin: 10
            anchors.verticalCenter: parent.verticalCenter
            Desktop.AwesomeButton {
                id: columns
                anchors.verticalCenter: parent.verticalCenter
                size: 16
                name: "columns"
                tooltip: "列编缉"

                onClicked: {
                    menu.init()
                    menu.open()
                }

                Desktop.FlatMenu {
                    id: menu
                    property var columns: [nameCol,offsetCol,
                        sizeCol,typeCol,maskCol,orderCol,
                        dimCol,ampCol,bsCol,blCol,descCol]

                    function init() {
                        var  items = []
                        for (var i=0; i<menu.columns.length; ++i) {
                            var col = menu.columns[i]
                            items.push({
                                           "url":"qrc:/Desktop/FlatMenuItem.qml",
                                           "properties":{
                                               "text": col.title,
                                               "index":i,
                                               "parameter":{},
                                               "checked": col.visible ? true : false
                                           }
                                       })
                        }
                        menu.reset(items)
                    }

                    onTriggered: {
                        var index = value.index
                        var col = menu.columns[index]
                        col.visible = !col.visible

                        table.persist(index, col.visible)
                    }
                }
            }

            BatchAddButton {
                id: batchAdd
                enabled: false
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
                            "name":"工程值"+String(i),
                            "bit_start":0,"bit_length":32,"offset":0,
                            "size":4,"mask":"0xFFFFFFFF",
                            "order":0,"type":0,"desc":"描述",
                            "dim":1,"amp":0
                        }
                        root.segments.push(info)
                        table.model.append(info)

                        root.itemChanged()
                    }
                }
            }
        }
    }

    function setValue(index, column, value) {
        if (index < 0 || column < 0) return

        var segment = root.segments[index]
        switch (column) {
        case 0://name
            segment.name = value
            table.model.setProperty(index, "name", value)
            break;
        case 1://offset
            segment.offset = Number(value)
            table.model.setProperty(index, "offset", Number(value))
            table.model.setProperty(index, "bit_start", helper.bitStart(segment))
            break;
        case 2://size
            segment.size = Number(value)
            table.model.setProperty(index, "size", Number(value))
            break;
        case 3://type
            segment.type = Number(value)
            table.model.setProperty(index, "type", Number(value))
            break;
        case 4://mask
            segment.mask = value
            table.model.setProperty(index, "mask", value)
            table.model.setProperty(index, "bit_start", helper.bitStart(segment))
            table.model.setProperty(index, "bit_length", helper.bitLength(segment))
            break;
        case 5://order
            segment.order = Number(value)
            table.model.setProperty(index, "order", Number(value))
            break;
        case 6://dim
            segment.dim = Number(value)
            table.model.setProperty(index, "dim", Number(value))
            break;
        case 7://amp
            segment.amp = Number(value)
            table.model.setProperty(index, "amp", Number(value))
            break;
        case 8://bit_start
            table.model.setProperty(index, "bit_start", Number(value))
            break;
        case 9://bit_length
            table.model.setProperty(index, "bit_length", Number(value))
            break;
        case 10://desc
            segment.desc = value
            table.model.setProperty(index, "desc", value)
            break;
        }

        root.itemChanged()
    }

    TableView {
        id: table
        anchors {
            top: title.bottom
//            topMargin: 100
            bottom: parent.bottom
            left: parent.left
            right: parent.right
        }

        style: Desktop.DesktopTableViewStyle {}
        itemDelegate: Item {
            Desktop.TextField {
                id: field
                anchors.fill: parent
                anchors.margins: 1
                anchors.leftMargin: 3
                anchors.rightMargin: 3
                property var validColumn: styleData.column === 0 ||
                                          styleData.column === 4 ||
                                          styleData.column === 10
                visible: styleData.selected && validColumn
                text: validColumn ? styleData.value : ""
                horizontalAlignment: Text.AlignHCenter
                onItemChanged: {
                    if (!visible) return

                    root.setValue(styleData.row, styleData.column, value)
                }
            }
            Desktop.ComboBox {
                anchors.fill: parent
                anchors.margins: 1
                property var validColumn: styleData.column === 3 ||
                                          styleData.column === 5
                visible: styleData.selected && validColumn
                model: styleData.column === 3 ?
                           ["整数","单精度浮点","双精度浮点","字符串"]
                         : styleData.column === 5 ? ["小端","大端"] : []
                currentIndex: validColumn ? Number(styleData.value) : 0
                onItemChanged: {
                    if (!visible) return

                    root.setValue(styleData.row, styleData.column, value)
                }
            }

            Desktop.SpinBoxInt {
                anchors.fill: parent
                anchors.margins: 1
                property var validColumn: styleData.column === 1 ||
                                          styleData.column === 2
                visible: styleData.selected && validColumn
                value: validColumn ? Number(styleData.value) : 0
                maximumValue: 8
                minimumValue: 1
                onItemChanged: {
                    if (!visible) return

                    root.setValue(styleData.row, styleData.column, value)
                    if(styleData.column === 2){
                        var ff = "0xFF"
                        for(var i= 0;i < value - 1;i++){
                            ff += "FF"
                        }
                        root.setValue(styleData.row, 4, ff)
                        root.setValue(styleData.row, 9, value * 8)
                    }
                }
            }

            Desktop.SpinBoxDouble {
                anchors.fill: parent
                anchors.margins: 1
                property var validColumn: styleData.column === 6 ||
                                          styleData.column === 7
                visible: styleData.selected && validColumn
                value: validColumn ? Number(styleData.value) : 0
                maximumValue: 999999
                minimumValue: 0
                onItemChanged: {
                    if (!visible) return

                    root.setValue(styleData.row, styleData.column, value)
                }
            }

            Desktop.Label {
                id: label
                anchors.fill: parent
                visible: !styleData.selected ||
                         styleData.column === 8 ||
                         styleData.column === 9
                text: {
                    if (!visible) return ""

                    if (styleData.column === 3) {
                        var dts = ["整数","单精度浮点","双精度浮点","字符串"]
                        return dts[Number(styleData.value)]
                    } else if (styleData.column === 5) {
                        return Number(styleData.value) === 0 ? "小端" : "大端"
                    }

                    return String(styleData.value)
                }

                horizontalAlignment: Text.AlignHCenter
            }
        }

        function persist(index, state) {
            var apppath = Excutor.query({"apppath":""})
            var file = apppath+"/config/persistence.soft"
            var config = Excutor.query({"read":file})
            config.payload_editor.segments[index] = state
            Excutor.excute({"command":"write","path":file,
                               "content":Framework.formatJSON(JSON.stringify(config))})
        }

        property var columsVisible: {
            var apppath = Excutor.query({"apppath":""})
            var config = Excutor.query({"read":apppath+"/config/persistence.soft"})
            return config.payload_editor.segments
        }

        TableViewColumn {id:nameCol;    visible:table.columsVisible[0];     role: "name"; title: "名称"; width: 80}
        TableViewColumn {id:offsetCol;  visible:table.columsVisible[1];     role: "offset"; title: "偏移"; width: 80}
        TableViewColumn {id:sizeCol;    visible:table.columsVisible[2];     role: "size"; title: "大小"; width: 80}
        TableViewColumn {id:typeCol;    visible:table.columsVisible[3];     role: "type"; title: "类型"; width: 100}
        TableViewColumn {id:maskCol;    visible:table.columsVisible[4];     role: "mask"; title: "掩码"; width: 100}
        TableViewColumn {id:orderCol;   visible:table.columsVisible[5];     role: "order"; title: "大/小端"; width: 80}
        TableViewColumn {id:dimCol;     visible:table.columsVisible[6];     role: "dim"; title: "量纲"; width: 80}
        TableViewColumn {id:ampCol;     visible:table.columsVisible[7];     role: "amp"; title: "幅值"; width: 80}
        TableViewColumn {id:bsCol;      visible:table.columsVisible[8];     role: "bit_start"; title: "比特起始位"; width: 80}
        TableViewColumn {id:blCol;      visible:table.columsVisible[9];     role: "bit_length"; title: "比特长度"; width: 80}
        TableViewColumn {id:descCol;    visible:table.columsVisible[10];    role: "desc"; title: "描述"; width: 100}
        model: ListModel {}

        rowDelegate: Item{
            height: 25

            Rectangle {
                height: 1
                width: parent.width
                anchors.bottom: parent.bottom
                color: "#00000000"
                border.color: Desktop.Theme.current.section
            }

            Row {
                spacing: 3
                visible: styleData.selected
                anchors.verticalCenter: parent.verticalCenter
                x: table.width - 55
                IconButton {
                    id: add
                    name: "plus"
                    onClicked: {
                        console.log("biaoji")
                        var preInfo = table.model.get(table.currentRow)
                        var offset = Number(preInfo.offset)+Number(preInfo.size)
                        var info = {"name":"工程值"+String(table.currentRow+1),
                            "bit_start":Number(preInfo.bit_start)+Number(preInfo.bit_length),
                            "bit_length":32,"offset":offset,
                            "size":4,"mask":"0xFFFFFFFF",
                            "order":0,"type":0,"desc":"描述",
                            "dim":1,"amp":0}
                        root.segments.splice(table.currentRow+1, 0, info)
                        table.model.insert(table.currentRow+1, info)

                        root.itemChanged()
                    }
                }
                IconButton {
                    id: remove
                    name: "minus"
                    onClicked: {
                        root.segments.splice(table.currentRow, 1)
                        table.model.remove(table.currentRow, 1)

                        root.itemChanged()
                    }
                }
            }
        }
    }
}
