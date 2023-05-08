/**
* \file CommandExcutor.h
* \author DotDot
* \date 2016/11/28
* \copyright Copyright (C), 2015-2017, All rights reserved.
*/
#ifndef __HWACOMMONPROJECT_H__
#define __HWACOMMONPROJECT_H__

#include "CoreGlobal.h"

#include <QJsonValue>
#include <QJsonObject>
#include <QObject>

#include <functional>

class QAbstractItemModel;

/**
*	\class CommandExcutor
*	\breif 命令执行器，负责响应界面请求和向界面发送信号.
*	Details
*/
class HWA_CORE_EXPORT CommandExcutor : public QObject
{
    Q_OBJECT
public:
    using WaitingHandler = std::function<void (const QJsonObject&)>;

public:
    static CommandExcutor& instance();

public slots:
    /// 通知底层执行相关命令
    virtual void excute(const QJsonValue& action);

    /// 向底层查询信息，即时返回
    virtual QJsonValue query(const QJsonValue& q);
    void wait();
    void closeWaiting();
    static void wait(const WaitingHandler &handler, const QJsonObject &pars = {});

signals:
	/**
	*    \fn    command
	*    \brief 对界面发送命令，命令格式为json.
	*    \param const QString & command
	*    \param const QVariant& param
	*    \returns void
	*/
    void command(QJsonObject);

private:
    Q_DISABLE_COPY(CommandExcutor)
    CommandExcutor();
    ~CommandExcutor();
};

#endif //__HWACOMMONPROJECT_H__
