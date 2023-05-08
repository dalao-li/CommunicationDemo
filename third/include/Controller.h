#ifndef CONTROLLER_H
#define CONTROLLER_H

#include <QtGlobal>
#include <QObject>

#ifdef VLD_FORCE_ENABLE
#include "vld.h"
#endif

class QJsonObject;
struct ControllerPrivate;
class Controller : public QObject
{
public:
    static Controller& instance();

public:
    bool excute(const QJsonObject& c);

    /*!
     * \brief isFinished判断下发配置是否成功
     * \return 成功返回True；否则，返回False
     */
    bool isFinished() const;

    /*!
     * \brief isStarted判断是否开始仿真
     * \return 成功，返回True；否则，返回False
     */
    bool isStarted() const;

    void init();

private:
    Controller();
    ~Controller();
    Q_DISABLE_COPY(Controller)

    ControllerPrivate* _p;
};
#endif // CONTROLER_H
