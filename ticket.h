#ifndef TICKET_H
#define TICKET_H

#include <QString>
#include <QJsonObject>

struct Ticket {
    QString id;
    QString status;
    QString firstName;
    QString lastName;
    QString email;
    QString timeId;
    QString time;
    QString timeOfReservation;
    int year{-1};

    Ticket() = default;
    Ticket(QJsonObject object);
};

#endif // TICKET_H
