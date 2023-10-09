#include "ticketmodel.h"

#include <QJsonDocument>
#include <QDebug>

TicketModel::TicketModel(QObject *parent)
    : QAbstractListModel(parent)
{
}

int TicketModel::rowCount(const QModelIndex &parent) const
{
    // For list models only the root node (an invalid parent) should return the list's size. For all
    // other (valid) parents, rowCount() should return 0 so that it does not become a tree model.
    if (parent.isValid())
        return 0;

    return m_tickets.size();
}

QHash<int, QByteArray> TicketModel::roleNames() const {
    QHash<int, QByteArray> roles;
    roles[IdRole] = "idRole";
    roles[StatusRole] = "statusRole";
    roles[FirstNameRole] = "firstNameRole";
    roles[LastNameRole] = "lastNameRole";
    roles[EmailRole] = "emailRole";
    roles[TimeIdRole] = "timeIdRole";
    roles[TimeRole] = "timeRole";
    roles[TimeOfReservationRole] = "timeOfReservationRole";
    roles[YearRole] = "yearRole";
    return roles;
}

QVariant TicketModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() < 0 || index.row() >= rowCount()) {
        return {};
    }

    const Ticket &ticket = m_tickets[index.row()];

    switch (static_cast<TicketRole>(role)) {
    case TicketModel::IdRole:
        return ticket.id;
    case TicketModel::StatusRole:
        return ticket.status;
    case TicketModel::FirstNameRole:
        return ticket.firstName;
    case TicketModel::LastNameRole:
        return ticket.lastName;
    case TicketModel::EmailRole:
        return ticket.email;
    case TicketModel::TimeIdRole:
        return ticket.timeId;
    case TicketModel::TimeRole:
        return ticket.time;
    case TicketModel::TimeOfReservationRole:
        return ticket.timeOfReservation;
    case TicketModel::YearRole:
        return ticket.year;
    }

    return {};
}

void TicketModel::loadFromArray(QJsonArray array) {
    clear();
    for (QJsonValue value : array) {
        if (!value.isObject()) {
            continue;
        }
        QJsonObject object = value.toObject();
        QJsonValue yearValue = object.value("year");
        if (yearValue.isObject()) {
            QJsonObject yearObject = yearValue.toObject();
            QString year = yearObject.value("name").toString();
            if (year != "2023") {
                continue;
            }
        }
        beginInsertRows({}, rowCount(), rowCount());
        m_tickets << Ticket(object);
        endInsertRows();
    }
}

void TicketModel::loadFromJson(QString json) {
    QJsonDocument doc = QJsonDocument::fromJson(json.toUtf8());
    if (!doc.isArray()) {
        return;
    }
    loadFromArray(doc.array());
}

void TicketModel::clear() {
    beginResetModel();
    m_tickets.clear();
    endResetModel();
}
