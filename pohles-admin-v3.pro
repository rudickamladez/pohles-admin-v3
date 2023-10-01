QT += quick

SOURCES += \
        main.cpp \
        ticket.cpp \
        ticketfiltermodel.cpp \
        ticketmodel.cpp

resources.files = main.qml
resources.prefix = /$${TARGET}
RESOURCES += resources \
    resources.qrc

# Additional import path used to resolve QML modules in Qt Creator's code model
QML_IMPORT_PATH =

# Default rules for deployment.
unix:!android: target.path = /opt/$${TARGET}/bin
!isEmpty(target.path): INSTALLS += target

DISTFILES += \
    qtquickcontrols2.conf

HEADERS += \
    ticket.h \
    ticketfiltermodel.h \
    ticketmodel.h
