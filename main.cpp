#include <QGuiApplication>
#include <QQmlApplicationEngine>

#include "ticketmodel.h"
#include "ticketfiltermodel.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    QQmlApplicationEngine engine;
    qmlRegisterType<TicketModel>("Pohles", 1, 0, "TicketModel");
    qmlRegisterType<TicketFilterModel>("Pohles", 1, 0, "TicketFilterModel");

    const QUrl url(u"qrc:/pohles-admin-v3/main.qml"_qs);
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
        &app, [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl)
                QCoreApplication::exit(-1);
        }, Qt::QueuedConnection);
    engine.load(url);

    return app.exec();
}
