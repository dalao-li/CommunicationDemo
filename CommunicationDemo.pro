TEMPLATE = app

QT += qml quick network quick quickcontrols2 widgets

CONFIG += c++11

DESTDIR = $$PWD/third/bin

SOURCES += main.cpp \
    CommandExcutor.cpp \
    FileReadWriter.cpp

RESOURCES += qml.qrc

LIBS += -l$$PWD/third/bin/PayloadParser       \
        -l$$PWD/third/bin/LANCommunication    \
        -l$$PWD/third/bin/Utils               \
        -l$$PWD/third/bin/CSCore

INCLUDEPATH += $$PWD/third/include

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
include(deployment.pri)

HEADERS += \
    CommandExcutor.h \
    FileReadWriter.h
