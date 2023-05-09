#ifndef CONFIGMANAGER_H
#define CONFIGMANAGER_H

#include "UtilsGlobal.h"

#include <QObject>

struct ConfigManagerPrivate;

class HWA_UTILS_EXPORT ConfigManager
{
public:
    static ConfigManager& GetManager();

    /// 设置配置文件所在路径
    void setPath(const QString& p);

    /// 获取配置文件所在路径
    QString path() const;

    /// 获取平台配置信息
    QJsonValue platformInfo(const QString& key) const;

    /// 恢复出厂设置
    bool readDefaultPlatformInfo();
    /// 修改平台配置信息
    void modifyPlatformInfo(const QString& key, const QJsonObject &value);
    /// 全部修改平台配置信息
    void setPlatformConfig(const QJsonObject &value);

    /**
     * @brief propertyTemplates属性编辑模版
     * @return 属性编辑模版
     */
    QJsonObject propertyTemplates() const;

    /**
     * @brief hardTemplates硬件状态显示模版
     * @return 硬件状态显示所有模版
     */
    QJsonValue hardTemplates() const;

    /**
     * @brief properties获取协议对应的配置属性项
     * @param protocal协议名称
     * @param key一组属性对应的键名
     * @return 存在则返回配置的一组属性，否则，返回空
     */
    QJsonObject properties(const QString& protocal, const QString& key) const;
    QJsonArray properties(const QString& key) const;

    /**
     * @brief menus获取所有定义的菜单项
     * @return 所有定义的菜单项
     */
    QJsonObject menus() const;

    /// 载荷相关操作，包括获取或重置所有载荷，增删改查某个载荷
    QJsonArray payloads() const;
    QJsonObject findPayloadByID(const QString& id) const;
    QJsonObject findPayloadByIndex(int index) const;
    QJsonObject findPayloadByPays(const QJsonArray& pays) const;
    bool setPayload(const QString &id, const QJsonObject& payload);
    bool setPayload(int index, const QJsonObject& payload);
    void setPayloads(const QJsonArray& payloads);
    bool appendPayload(const QJsonObject& payload);
    void removePayload(const QString &id);
    void removePayload(int index);

    QJsonObject sysPayloads() const;
    QJsonObject findSysPayload(const QString &key);

    QJsonObject busHandlers() const;
    QJsonObject findHandler(const QString& key) const;

    QJsonObject treatyTrees() const;
    QJsonObject findTreatyTree(const QString& key) const;

    QJsonObject controls() const;

private:
    Q_DISABLE_COPY(ConfigManager)
    ConfigManager();
    ~ConfigManager();
    void readPlatformInfo();
    void readTemplates();
    void readMenus();
    bool readPayloads();
    void readSysPayloads();
    void readBusHandlers();
    void readTreatyTrees();
    void readControls();
    QJsonArray readProperties(const QString& bus) const;

private:
    ConfigManagerPrivate* _p;
};
#endif // CONFIGMANAGER_H
