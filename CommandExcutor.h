/**
* \file CommandExcutor.h
* \author DotDot
* \date 2016/11/28
* \copyright Copyright (C), 2015-2017, All rights reserved.
*/
#ifndef __HWACOMMONPROJECT_H__
#define __HWACOMMONPROJECT_H__


#include <QJsonValue>
#include <QJsonObject>
#include <QObject>
#include <memory>
#include <QUdpSocket>

#include <functional>
#include "LANCommunication.h"
#include "PayloadParser.h"

class QAbstractItemModel;

/**
*	\class CommandExcutor
*	\breif 命令执行器，负责响应界面请求和向界面发送信号.
*	Details
*/
class CommandExcutor : public QObject
{
    Q_OBJECT

public:
    static CommandExcutor& instance();

public slots:

    QString formatJSON(const QByteArray &data);

    /// 向底层查询信息，即时返回
    virtual QJsonValue query(const QJsonValue& q);

    ///将各个工程值组成最终数据
    QByteArray combine(const QJsonArray& info, const QStringList& datas, int length);

    ///将十进制转成十六进制
    QByteArray octToHex(const QString &data);

    ///发送数据
    int send(const QJsonObject &info);

    //客户端监听端口
    void bind(const QString & ip, const int &port, const bool &bBind);

    //接收数据
    void readData();

    //按ICD解析数据
    QStringList parseData(const QByteArray &data, const QJsonObject &segment);

signals:
    void recvData(const QByteArray &data);


private:
    Q_DISABLE_COPY(CommandExcutor)
    CommandExcutor();
    ~CommandExcutor();


    QUdpSocket * clientUdp;
    PayloadParser payloadParser;
};

#endif //__HWACOMMONPROJECT_H__
