#include <QApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>


#include "CommandExcutor.h"

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);
    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty("Excutor", &CommandExcutor::instance());
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    return app.exec();
}
