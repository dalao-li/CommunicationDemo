#ifndef PAYLOADPARSER_H
#define PAYLOADPARSER_H

#include <QJsonArray>
#include <QByteArray>
#include <QVector>
#include <QVariant>

#include "payloadparser_global.h"

class QJsonObject;

/**
 * @brief PayloadParser类负责解析或组合一帧载荷数据，规则按照载荷规则指定；使用时调用parse接口
 *          传入指定数据，返回解析后数据；使用combine接口组合出一帧数据。
 */
class PAYLOADPARSERSHARED_EXPORT PayloadParser
{
    using ulonglong = unsigned long long;

public:
    PayloadParser();

    /**
     * @brief PayloadParser构造函数
     * @param c为载荷规则描述
     */
    PayloadParser(const QJsonArray& c);

    /**
     * @brief setConfig设置载荷规则信息
     * @param c载荷规则信息
     */
    void setConfig(const QJsonArray& c);

    /**
     * @brief config获取载荷规则信息
     * @return 载荷规则信息
     */
    QJsonArray config() const;

    /**
     * @brief parse将data数据按照载荷规则解析出各规则对应的数据
     * @param data要解析的数据
     * @return 解析后的数据
     */
    QVector<QVariant> parse(const QByteArray& data);

    /**
     * @brief parseRaw将data数据按照载荷规则解析出各规则对应的数据，不会计算幅值和偏移
     * @param data要解析的数据
     * @return 解析后的数据
     */
    QVector<QVariant> parseRaw(const QByteArray& data);

    /**
     * @brief combine组合datas，最终长度为length，datas长度与规则描述信息长度必须一致；
     *          长度超出length的规则不会被处理;暂不支持按位组帧
     * @param datas要拼接的所有数据
     * @param length指定拼接数据的总长度
     * @return 返回拼接后的数据
     */
    QByteArray combine(const QVector<QVariant>& datas, int length);

    /**
     * @brief modify 用data及info信息修改result.
     * @param info 要修改值得信息，包括offset, size等等
     * @param data 是将要被修改到数据中的：w值
     * @result 返回修改后最新数据
     */
    static void modify(const QJsonObject &info, const QVariant &data, QByteArray &result);

    /**
     * @brief parse解析data数据，字段信息在segment中指定
     * @param data被解析的数据
     * @param segment数据对应offset、size等信息，大小单位为Byte
     * @return 成功，返回解析后的数据对应的字符串；失败，返回空
     */
    QVariant parse(const QByteArray& data, const QJsonObject& segment);

    /**
     * @brief parseRaw解析data数据，字段信息在segment中指定,不会计算幅值和偏移
     * @param data被解析的数据
     * @param segment数据对应offset、size等信息，大小单位为Byte
     * @return 成功，返回解析后的数据对应的字符串；失败，返回空
     */
    QVariant parseRaw(const QByteArray& data, const QJsonObject& segment);

    static ulonglong swapI64(ulonglong v);
    static uint swapI32(uint v);
    static uint swapI16(unsigned short v);
    static uchar swapI8(unsigned char v);

    /**
     * @brief bitStart calculate bit offset by info.
     * @example info: {offset:0, mask:0xFF}, offset is 0 byte
     * @return return bit offset
     */
    static int bitStart(const QJsonObject& info);

    /**
     * @brief bitLength calculate bit size by info.
     * @example info must have {mask: 0xFF}
     * @return return bit size
     */
    static int bitLength(const QJsonObject& info);

    /**
     * @brief mask calculate mask from bitoffset and bitsize.
     * @param bitoffset bit offset from star pos
     * @param bitsize bit size
     * @return return mask value, e.g. bitoffset is 1, bitsize is 8, return "0x01fe"
     */
    static QString mask(int bitoffset, int bitsize);

private:
    Q_DISABLE_COPY(PayloadParser)
    QVariant readValue(void *d,
                       int length,
                       const QJsonObject& info,
                       bool raw = false);
    quint64 readValueBase(void *data, int offset,
                          int size, int order);
    quint64 readValueWithMask(void *data, int offset,
                              int size, quint64 mask, int order);
    int unsigned2SingedValue(quint32 value, int size);
    static int searchLowBit(quint32 value);
    static int searchHighBit(quint32 value);
    static int searchLowBit64(quint64 value);
    static int searchHighBit64(quint64 value);

    float swapF32(float v) const;
    double swapF64(double v) const;

private:
    QJsonArray  _config;
};

#endif // PAYLOADPARSER_H
