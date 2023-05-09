#ifndef ICDDisplayView_H
#define ICDDisplayView_H

#include <QQmlExtensionPlugin>

class QJSEngine;
class ICDDisplayView : public QQmlExtensionPlugin
{
    Q_OBJECT
    Q_PLUGIN_METADATA(IID "io.dotdot.view.icd.display")
public:
    virtual void registerTypes(const char *uri);
};

#endif // ICDDisplayView_H
