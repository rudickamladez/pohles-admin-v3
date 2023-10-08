#include "ticket.h"

#include <QJsonValue>
#include <QJsonObject>

Ticket::Ticket(QJsonObject object) {
    id = object.value("id").toString();
    status = object.value("status").toString();
    QJsonValue nameValue = object.value("name");
    if (nameValue.isObject()) {
        QJsonObject nameObject = nameValue.toObject();
        firstName = nameObject.value("first").toString();
        lastName = nameObject.value("last").toString();
    }
    email = object.value("email").toString();
    QJsonValue timeValue = object.value("time");
    if (timeValue.isObject()) {
        QJsonObject timeObject = timeValue.toObject();
        timeId = timeObject.value("id").toString();
        time = timeObject.value("name").toString();
    }
    timeOfReservation = object.value("date").toString();
    QJsonValue yearValue = object.value("year");
    if (yearValue.isObject()) {
        QJsonObject yearObject = yearValue.toObject();
        year = yearObject.value("name").toString().toInt();
    }
}
