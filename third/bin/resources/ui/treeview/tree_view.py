
import PyLogger as pl
import PyTree as pt
import PyController as pc
import json

def run(info):
    pl.info(json.dumps(info))
    sendNet = info["send_net"]
    sendVLCount = info["send_vl"]
    sendPortCount = info["send_port"]
    sendCount = info["send_count"]
    sendInterval = info["send_interval"]
    recvNet = info["recv_net"]
    recvVLCount = info["recv_vl"]
    recvPortCount = info["recv_port"]
    vlbuff = pc.query("AFDX_ROOT", "AFDX_VL")
    portbuff = pc.query("AFDX_ROOT", "AFDX_PORT")
    vlProps = json.loads(vlbuff)
    portProps = json.loads(portbuff)
    vlName = vlProps["name"]
    config = []
    for i in range(sendVLCount):
        vlProps = json.loads(vlbuff)
        vlProps["vl_id"] = str(i)
        vlProps["name"] = vlName+":"+str(i)
        vl = {"properties": vlProps}
        ports = []
        portid = 0
        for j in range(sendPortCount):
            portProps = json.loads(portbuff)
            portProps["port_id"] = str(portid)
            portProps["destport_id"] = str(portid)  
            portProps["interval"] = str(sendInterval)
            portProps["count"] = str(sendCount)
            portProps["port_id"] = str(j)
            portProps["network"] = str(sendNet)
            port = {"properties": portProps}
            ports.append(port)
            portid = portid + 1
        vl["children"] = ports
        config.append(vl)
    for i in range(recvVLCount):
        vlProps = json.loads(vlbuff)
        vlProps["vl_id"] = str(i)
        vlProps["vl_type"] = "1"
        vlProps["name"] = vlName+":"+str(i)
        vl = {"properties": vlProps}
        ports = []
        portid = 0
        for j in range(recvPortCount):
            portProps = json.loads(portbuff)
            portProps["port_id"] = str(portid)
            portProps["destport_id"] = str(portid)  
            portProps["interval"] = "1000"
            portProps["count"] = "10"
            portProps["port_id"] = str(j)
            portProps["port_mode"] = "1"
            portProps["network"] = str(recvNet)
            port = {"properties": portProps}
            ports.append(port)
            portid = portid + 1
        vl["children"] = ports
        config.append(vl)
    pt.appends("hard_tree", info["fullkey"], json.dumps(config))
