#ifndef UTILS_H
#define UTILS_H

#include "UtilsGlobal.h"

#include <QJsonObject>

class QAbstractItemModel;
class QModelIndex;
namespace Utils
{
/// 获取平台临时路径
HWA_UTILS_EXPORT QString tempPath();

/// 根据原始数据解析时间戳（us）
HWA_UTILS_EXPORT quint64 time(const QByteArray &data);

/// 计算CRC数值
/// value is big endian
HWA_UTILS_EXPORT quint32 crc32(void* input, int len);

/// 计算IP Checksum
/// value is big endian
HWA_UTILS_EXPORT quint16 ipCheckSum(void* input, int len);

HWA_UTILS_EXPORT quint32 swapI32(quint32 v);
HWA_UTILS_EXPORT quint32 swapI16(quint16 v);

/**
 * @brief 解析数据,并根据属性配置返回查找到的ICD_ID,index,offset
 * @param data发送/接收的协议数据,不包含时间,序号,标签等信息
 * @param props节点属性,属性必须包含：pays项,例如:
 * {pays:"xxx",properties:{...},parent:{...}}
 * @return 返回数据格式为:{index:0,offset:44},index为载荷序号,offset为数据载荷实际偏移
 */
HWA_UTILS_EXPORT QJsonObject matchPayload(const QByteArray &data,
                                          const QJsonObject &props);

/// 根据载荷配置树解析data数据信息，返回结果树
HWA_UTILS_EXPORT QJsonObject parsePayload(const QByteArray &data,
                                          const QJsonObject& infos);
}

namespace ConfigTree {
//key, role, menu and so on.
HWA_UTILS_EXPORT
QString combineProperty(const QJsonObject& props,
                        const QString &name);

/**
 * @brief findPropertyByNodetype find node properties by node type, chian include
 * full parent properties, e.g. parent: {}.
 * @param propChain is properties chain, include all parent nodes.
 * @param type is node type, e.g. AFDX card node's type is AFDX_CARD
 * @return if have, return node properties, or none.
 */
HWA_UTILS_EXPORT
QJsonObject findPropertyByNodetype(const QJsonObject& propChain,
                                   const QString& type);

/**
  * make every node full property(include all parent), find full property by key value
  */
HWA_UTILS_EXPORT
void makeFullProperty(const QJsonObject &config,
                      QJsonObject& full,
                      const QJsonObject &parent = {},
                      const QString &key = "");

/**
 * @brief fullValue combine key values from property and parent properties.
 * @param property is node full properties
 * @param key is property key
 * @return return full key values
 */
HWA_UTILS_EXPORT
QString fullValue(const QJsonObject &property, const QString &key = "keys");

/**
 * @brief findPropertyValue find node key's value, if not find, iterate parent node.
 * @param property is node full properties.
 * @param key is node property key.
 * @return return property key value.
 */
HWA_UTILS_EXPORT
QString findPropertyValue(const QJsonObject &property, const QString &key);

HWA_UTILS_EXPORT QModelIndex findIndex(const QString &key, QAbstractItemModel *model);
HWA_UTILS_EXPORT QJsonObject nodeData(const QModelIndex &index);
HWA_UTILS_EXPORT void setData(const QModelIndex &index, const QJsonObject &d);
HWA_UTILS_EXPORT QModelIndex append(const QModelIndex &index, const QJsonObject &d);
HWA_UTILS_EXPORT QModelIndex insert(const QModelIndex &index, int i, const QJsonObject &d);
HWA_UTILS_EXPORT void insertRows(const QModelIndex &parent,
                                 int index,
                                 const QJsonArray &props);
HWA_UTILS_EXPORT QString nodeKey(const QModelIndex &index);
HWA_UTILS_EXPORT QString nodeRole(const QModelIndex &index);
HWA_UTILS_EXPORT QString nodeMenu(const QModelIndex &index);
HWA_UTILS_EXPORT QString nodeFullKey(const QModelIndex &index);
HWA_UTILS_EXPORT QString nodeFullRole(const QModelIndex &index);
HWA_UTILS_EXPORT QString nodeFullMenu(const QModelIndex &index);
}

#endif // UTILS_H
