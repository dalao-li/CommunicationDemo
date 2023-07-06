/*
 * @Description:
 * @Version: 1.0
 * @Author: liyuanhao
 * @Date: 2023-05-09 19:05:47
 * @LastEditors: liyuanhao
 * @LastEditTime: 2023-05-09 19:05:47
 */


import QtQuick 2.5
import QtQuick.Layouts 1.1
import QtQuick.Controls 1.4
import DesktopControls 0.1

ColumnLayout {
    id: root

    property var actions: []

    property var keysList : []

    SplitView {
        Layout.fillHeight: true
        Layout.fillWidth: true

        Rectangle {
            implicitWidth: 200
            Layout.fillHeight: true
            color: "#f0f0f0"

            // 侧边栏
            DeviceActionList {
                id: listComponent

                anchors.fill: parent
                Layout.fillHeight: true

                actions: root.actions

                onCurrentIndexChanged: {
                    if (listComponent.currentIndex < 0) {
                        return
                    }
                    var data = root.actions[listComponent.currentIndex]

                    // 获取Devices ComboBox与InputICD ComboBox
                    var deviceComboBoxModel = createDeviceComboBoxModel()
                    var deviceIndex = (()=>{
                                           for (var i in deviceComboBoxModel) {
                                               if (data.device.device_id === deviceComboBoxModel[i].value) {
                                                   return i
                                               }
                                           }
                                           return -1
                                       })()
                    var inputICDComboBoxModel = createInputICDComboBoxModel(data.device.input_icd)
                    var intputICDIndex = (()=>{
                                              for (var i in inputICDComboBoxModel) {
                                                  if (data.actions.bind_input_icd === inputICDComboBoxModel[i].value) {
                                                      return i
                                                  }
                                              }
                                              return -1
                                          })()
                    detailComponent.load(data, deviceComboBoxModel, deviceIndex, inputICDComboBoxModel, intputICDIndex)

                    // 获取InputICD 中index ComboBox
                    var inIndexComboBoxModel = createInIndexComboBoxModel(data.actions.bind_input_icd)
                    // 获取表格中所有inIndex控件的currentIndex
                    var inIndexComboBoxIndex = (()=>{
                                                    var info = []
                                                    var keyList = data.actions.keyList
                                                    for (var i in keyList) {
                                                        info.push(keyList[i].in_index)
                                                    }
                                                    return info
                                                })()

                    // 记录outputICD的下拉框选取情况
                    var outputICDComboBoxModel = createOutputICDComboBoxModel(data.device.output_icd)
                    var outputICDComboBoxIndex = (()=>{
                                                      var info = []
                                                      var keyList = data.actions.keyList
                                                      for (var i in keyList) {
                                                          for (var j in outputICDComboBoxModel) {
                                                              if (keyList[i].bind_output_icd === outputICDComboBoxModel[j].value) {
                                                                  info.push(j)
                                                              }
                                                          }
                                                      }
                                                      return info
                                                  })()

                    // 存成二维数组[[名称1， 名称2], [],....]
                    var outIndexComboBoxModel = (()=>{
                                                     var info = []
                                                     for (var i in outputICDComboBoxModel) {
                                                         info.push(createOutIndexComboBoxModel(outputICDComboBoxModel[i].value))
                                                     }
                                                     return info
                                                 })()
                    // output ICD的index选取情况
                    var outIndexComboBoxIndex = (()=>{
                                                     var info = []
                                                     var keyList = data.actions.keyList
                                                     for (var i in keyList) {
                                                         info.push(keyList[i].out_index)
                                                     }
                                                     return info
                                                 })()
                    //console.log("data = ", JSON.stringify(data))
                    segmentComponent.load(data, inIndexComboBoxModel, inIndexComboBoxIndex, outputICDComboBoxModel, outputICDComboBoxIndex, outIndexComboBoxModel, outIndexComboBoxIndex)
                }

                onCountChanged: {
                    if (listComponent.count <= 0) {
                        detailComponent.clear()
                        segmentComponent.clear()
                    }
                }
            } // listComponent end
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.fillHeight: true
            color: "#f0f0f0"

            DeviceActionDetail {
                id: detailComponent
                anchors {
                    top: parent.top
                    left: parent.left
                    right: parent.right
                }

                onItemChanged: {
                    if (listComponent.currentIndex < 0) {
                        return
                    }

                    if (id === "name") {
                        listComponent.model.set(listComponent.currentIndex, {"name": value})
                        return
                    }

                    if (id === "device") {
                        var device = JSON.parse(value)
                        root.actions[listComponent.currentIndex].device = device
                        // 修改device时, 同步修改
                        segmentComponent.clear()
                        segmentComponent.updateDevice(device)
                        return
                    }

                    if (id === "bind_input_icd") {
                        segmentComponent.clear()
                        segmentComponent.updateBindInputICD(value)
                        root.actions[listComponent.currentIndex].actions.bind_input_icd = value
                    }
                }
            }

            DeviceActionSegmentList {
                id: segmentComponent
                anchors {
                    left: parent.left
                    right: parent.right
                    top: detailComponent.bottom
                    topMargin: 5
                    bottom: parent.bottom
                }

                keysList: root.keysList
            }
        }
    }

    function createDeviceComboBoxModel() {
        var info = []
        for (var i in devices) {
            info.push({
                          text: devices[i].type,
                          value: devices[i].device_id

                      })
        }
        return info
    }

    function createInputICDComboBoxModel(inputICDList) {
        var info = []
        for (var i in inputICDList) {
            for (var j in payloads) {
                if (String(inputICDList[i]) === String(payloads[j].id)) {
                    info.push({
                                  text: payloads[j].name,
                                  value: payloads[j].id
                              })
                }
            }
        }
        return info
    }

    function createOutputICDComboBoxModel(outputICDList) {
        var info = []
        for (var i in outputICDList) {
            for (var j in payloads) {
                if (String(outputICDList[i]) === String(payloads[j].id)) {
                    info.push({
                                  text: payloads[j].name,
                                  value: payloads[j].id
                              })
                }
            }
        }
        return info
    }

    function createInIndexComboBoxModel(bindInputICD) {
        var payload = mainWindow.getPayLoads(bindInputICD)
        var values = payload.values
        var info = []
        for (var i in values) {
            info.push({
                          text: values[i].name,
                          value: String(i)
                      })
        }
        return info
    }

    function createOutIndexComboBoxModel(bindOutputICD) {
        var payload = mainWindow.getPayLoads(bindOutputICD)
        var values = payload.values
        var info = []
        for (var i in values) {
            info.push({
                          text: values[i].name,
                          value: String(i)
                      })
        }
        return info
    }
}
