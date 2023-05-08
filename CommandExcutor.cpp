
#include "CommandExcutor.h"

#include "FileReadWriter.h"
#include "PayloadParser.h"
#include "ConfigManager.h"

#include <QDebug>
#include <QJsonObject>
#include <QJsonArray>
#include <QJsonDocument>
#include <QCoreApplication>

CommandExcutor::CommandExcutor()
{
    clientUdp = nullptr;
}

CommandExcutor::~CommandExcutor()
{
    //    _lan.reset();
}

CommandExcutor &CommandExcutor::instance()
{
    static CommandExcutor *excutor = new CommandExcutor;

    return *excutor;
}

QString CommandExcutor::formatJSON(const QByteArray &data)
{
    return QJsonDocument::fromJson(data).toJson();
}

QJsonValue CommandExcutor::query(const QJsonValue &info)
{
    auto jInfo = info.toObject();
    QString path = QCoreApplication::applicationDirPath();
    if (jInfo.contains("read"))
    {
        QString path = jInfo["read"].toString();
        auto content = FileReadWriter::read(path).toUtf8();
        auto doc = QJsonDocument::fromJson(content);
        if (doc.isObject())
            return doc.object();
        else if (doc.isArray())
            return doc.array();
        else
            return QString(content);
    }
    else if (jInfo.contains("apppath"))
        return QCoreApplication::applicationDirPath();
    else if (jInfo.contains("payloads"))
    {
        QJsonArray payloads;
        QJsonParseError error;
        QString paraPath = jInfo["payloads"].toString();
        QString icdPath = path + "/config/CCICD.payloads";
        QString content = FileReadWriter::read(paraPath);

        if (content.isEmpty())
        {
            qDebug() << "ConfigManager::readPayloads() failed";
            return payloads;
        }

        payloads = QJsonDocument::fromJson(content.toUtf8(), &error).array();
        return payloads;
    }
    else if (jInfo.contains("command"))
    {
        auto &configMgr = ConfigManager::GetManager();
        QString command = jInfo["command"].toString().toLower();
        if (command == "set_payload")
        {
            QJsonObject payload = jInfo["payload"].toObject();
            int payloadIndex = jInfo["index"].toInt();
            configMgr.setPayload(payloadIndex, payload);
        }
        else if (command == "set_payloads")
        {
            auto payloads = jInfo["payloads"].toArray();
            configMgr.setPayloads(payloads);
        }
        else if (command == "append_payload")
        {
            QJsonObject payloadInfo = jInfo["payload"].toObject();
            configMgr.appendPayload(payloadInfo);
        }
        else if (command == "remove_payload")
        {
            auto index = jInfo["index"].toInt();
            configMgr.removePayload(index);
        }
        else if (command == "write")
        {
            qDebug() << jInfo["path"].toString();
            FileReadWriter::write(jInfo["path"].toString(),
                                  jInfo["content"].toString());
        }
    }

    return {};
}

QByteArray CommandExcutor::combine(const QJsonArray &info, const QStringList &datas, int length)
{
    QVector<QVariant> dts;
    for (int i = 0; i < datas.size(); ++i)
    {
        dts.push_back(datas[i].toLatin1());
    }
    PayloadParser parser(info);
    //    qDebug()<<"--->parser "<<parser.combine(dts, length);
    //    qDebug()<<"--->parser toHex"<<parser.combine(dts, length).toHex();
    return parser.combine(dts, length).toHex();
}

QByteArray CommandExcutor::octToHex(const QString &data)
{
    int id = data.toInt();
    PayloadParser parser;
    id = parser.swapI32(id);
    QByteArray idb(4, 0);
    memcpy(idb.data(), &id, sizeof(int));
    // qDebug()<<"--->QByteArray(cid) "<<idb.toHex();
    // 大端格式
    return idb.toHex();
    // return QByteArray::number(data.toInt(), 16);
}

int CommandExcutor::send(const QJsonObject &info)
{
    qDebug() << "ip : " << info["ip"].toString();
    qDebug() << "port : " << info["port"].toInt();
    qDebug() << "send : " << QByteArray().append(info["data"].toString());
    qDebug() << "send : " << QByteArray::fromHex(QByteArray().append(info["data"].toString()));
    QUdpSocket serverUdp;
    serverUdp.bind(QHostAddress(info["serverip"].toString()), info["serverport"].toInt());
    qDebug() << serverUdp.errorString();
    int size = serverUdp.writeDatagram(QByteArray::fromHex(QByteArray().append(info["data"].toString())),
                                       QHostAddress(info["ip"].toString()),
                                       info["port"].toInt());
    qDebug() << serverUdp.errorString();
    qDebug() << "send size = " << size;
    return size;
}

void CommandExcutor::bind(const QString &ip, const int &port, const bool &bBind)
{
    if (bBind)
    {
        clientUdp = new QUdpSocket;
        connect(clientUdp, SIGNAL(readyRead()), this, SLOT(readData()));
        clientUdp->waitForConnected(3000);
        bool ok = clientUdp->bind(QHostAddress(ip), port);
        if (!ok)
        {
            qDebug() << "bind failed";
            qDebug() << clientUdp->errorString();
        }
        else
        {
            qDebug() << "bind success";
        }
    }
    else
    {
        // disconnect(&clientUdp, SIGNAL(readyRead()), this, SLOT(readData()));
        if (clientUdp)
        {
            delete clientUdp;
            clientUdp = nullptr;
        }
    }
}

void CommandExcutor::readData()
{
    while (clientUdp->hasPendingDatagrams())
    {
        QByteArray datagram;
        datagram.resize(clientUdp->pendingDatagramSize());

        clientUdp->readDatagram(datagram.data(), datagram.size());
        //        qDebug()<<"--->readData "<<datagram;
        //        qDebug()<<"--->readData "<<datagram.toHex();
        //        qDebug()<<"--->readData "<<datagram.toHex().data();
        emit recvData(datagram.toHex().data());
    }
}

QStringList CommandExcutor::parseData(const QByteArray &data, const QJsonObject &segment)
{
    QStringList dataList;
    payloadParser.setConfig(segment["values"].toArray());
    //    qDebug()<<" data == "<<data;
    //    qDebug()<<" data fromHex == "<<QByteArray::fromHex(data);
    QVector<QVariant> dVector = payloadParser.parse(QByteArray::fromHex(data));
    for (int i = 0; i < dVector.size(); i++)
    {
        dataList.append(dVector.at(i).toString());
        // qDebug()<<dataList.last();
    }

    return dataList;
}
