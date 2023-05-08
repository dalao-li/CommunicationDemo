#ifndef ICDDisplayViewParser_HPP
#define ICDDisplayViewParser_HPP

#include <QObject>
#include <QJsonArray>
#include <QJsonObject>

class QByteArray;
struct ICDDisplayViewParserPrivate;
/**
 * @brief The ICDDisplayViewParser class
 *        一个通道对应一个Parser，Parser按照指定属性 ICD信息解析数据
 */
class ICDDisplayViewParser : public QObject
{
    Q_OBJECT
public:
    ICDDisplayViewParser();
    ICDDisplayViewParser(const ICDDisplayViewParser&);
    virtual ~ICDDisplayViewParser();

public slots:
    quint64 parseTime(const QByteArray& data);
    QJsonArray parseRaw(const QByteArray& data, const QJsonArray& segments);
    QJsonArray parse(const QByteArray& data, int offset, const QJsonArray& segments);

private:
    ICDDisplayViewParserPrivate* _p;
};

#endif // ICDDisplayViewParser_HPP
