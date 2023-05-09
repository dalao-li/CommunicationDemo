/**
* \file BaseHandler.h
* \author lyp
* \date 2017/12/27
* \copyright Copyright (C), 2015-2017, All rights reserved.
*/
#ifndef __BASEHANDLER_H__
#define __BASEHANDLER_H__

#ifdef HWA_HANDLER_DLL
# define HWA_HANDLER_EXPORT Q_DECL_EXPORT
#else
# define HWA_HANDLER_EXPORT Q_DECL_IMPORT
#endif

#include <QObject>
#include <QJsonArray>
#include <QJsonObject>

/**
*	\class BaseHandler
*	\breif 视图处理器基类，不同总线处理数据的方式不同，界面上需要显示的数据也不同.
*	Details
*/

class HWA_HANDLER_EXPORT BaseHandler : public QObject
{
    Q_OBJECT
public:
    BaseHandler();
    virtual ~BaseHandler();

    /**
     * @brief 视图中显示的列
     * @param data发送/接收的数据
     * @param props节点属性(总线，卡，port)、pays、key、apppath
     * @return 返回[{name: "", role: ""}, ...]
     */
    virtual QJsonArray columns(const QJsonObject &props) = 0;

    /**
     * @brief 当前视图的带宽
     * @param props节点属性(总线，卡，port)、pays、key、apppath
     * @return 返回当前视图的带宽(K)
     */
    virtual qreal bandwidth(const QJsonObject &props) const = 0;

    /**
     * @brief 协议树
     * @param data发送/接收的数据
     * @param props节点属性(卡||port)、pays、key、apppath
     * @return 返回{config:[{name:"SOF", value: "", offset:0,size:0,mask:"",type:0,order:0,desc:""},...]}
     */
    virtual QJsonObject tree(const QByteArray &data, const QJsonObject &props) = 0;

    /**
     * @brief 解析数据
     * @param data发送/接收的数据
     * @param props节点属性(卡||port)、pays、key
     * @return 将解析结果按role顺序放到QStringList返回
     */
    virtual QStringList parse(const QByteArray &data, const QJsonObject &props) = 0;

    /**
     * @brief count获取key下数据总个数,TODO:实现
     * @param key为存储模块对应数据键名
     * @return 如果存在数据则返回数据条数，如果不存在返回0
     */
    quint64 count(const QString &key) const;

    /**
     * @brief datas获取key下，从start开始，count条数据,TODO:实现
     * @param key要说去数据对应键名
     * @param start数据起始位置
     * @param count要获取数据条数
     * @return 获取key下满足条件所有数据，没有数据则返回空
     */
    QJsonArray datas(const QString &key, quint64 start, int count);

    /**
     * @brief 总线的过滤条件
     * @param props节点属性，板卡不同模式下过滤条件不一样
     * @return 返回[{name: "", id: "", text:""}, ...]，
     * 其中name是指该条件对应的控件名称，id：过滤项,text：界面上显示的名称
     */
    virtual QJsonArray filterCondition(const QJsonObject &props) = 0;

    /**
     * @brief filteCount获取过滤后数据总个数,TODO:实现
     * @param key存储数据的键名，一段字符串;如果要访问key相关属性，可以通过配置树获取
     * @return 存在key对应数据返回true，并进行过滤，成功后发出信号
     */
    virtual bool filteCount(const QString &key, const QJsonObject &conditions) const { return true; }

    //TODO implite interface, pure interface = 0
    /**
     * @brief filteDatas获取满足过滤条件所有数据,TODO:
     * @param conditions过滤数据对应的条件
     * @param key获取数据对应的键名
     * @param start为原始数据起始位置
     * @param count为要获取过滤数据条数
     * @return key下存在数据则返回true，否则返回false
     */
    virtual bool filteDatas(const QString &key,
                                   const QJsonObject &conditions,
                                   quint64 start,
                                   int count) { return {}; }

    /**
     * @brief exportData导出数据
     * @param infos，包括key、target、附加信息
     * @return 保存成功返回true，否则返回false
     */
    virtual bool exportData(const QJsonObject &infos) { return true; }
    virtual bool importData(const QString &file, const QString &key = "") { return true; }

    /**
     * @brief 数据过滤
     * @param data当前数据，conditions：过滤条件，props：节点属性
     * @return 符合过滤条件返回解析结果，不符合返回空
     */
    virtual QStringList filte(const QByteArray &data,
                              const QJsonObject &conditions,
                              const QJsonObject &props) { return {}; }

    /**
     * @brief statistics获取板卡统计信息
     * @param props包括adapter_name,card_type,card_id
     * @return 返回板卡时间MIB信息
     */
    virtual QJsonObject statistics(const QJsonObject &props);

    /**
     * @brief protocalParse解析data，返回各个字段数据信息，例如AFDX协议，返回{"vl":1,"ip":"10.0.1.0"...}
     * @param data是需要解析的数据
     * @return返回解析后的协议字段信息
     */
    virtual QJsonObject protocalParse(const QJsonObject &,
                                      const QByteArray &) { return {}; }

    /**
     * @brief combineProtocal按照传入的字段信息，组出一包数据
     * @param info协议组包字段信息，与protocalParse行为正好相反
     * @return 解析后的一包数据
     */
    virtual QByteArray combineProtocal(const QJsonObject &info) { return {}; }

    /**
     * @brief timeValue转换xx.xx.xx.xx.xx格式时间为数值，返回实际微妙数值
     * @param timexx.xx.xx.xx.xx格式时间
     * @return 返回实际微妙数值，否则返回0
     */
    quint64 timeValue(const QString& time);

    /// condition format: xx.xx.xx:xx.xx.xx/xx.xx.xx,[+-]xx
    bool checkTime(const QString &time, const QString &condition);
    bool checkIndex(quint64 start, quint64 end, quint64 index);

signals:
    /// {count:1000,key:xxxx,conditions:[]}
    void filteCountFinished(const QString &key, quint64 count);

    /// {key:xxx,conditons:[],start:0,count:100}
    void filteDatasFinished(const QJsonObject &infos);

    /// key对应数据过滤进度信息，例如获取过滤后总数据条数，当前过滤进度；或者
    /// {key:xxx,filtedcount:100,count:1000,percent:0.1}
    void filteProgress(const QJsonObject &infos);
};

#endif //__BASEHANDLER_H__
