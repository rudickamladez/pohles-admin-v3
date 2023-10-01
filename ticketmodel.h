#ifndef TICKETMODEL_H
#define TICKETMODEL_H

#include "ticket.h"

#include <QAbstractListModel>
#include <QJsonArray>
#include <QList>

class TicketModel : public QAbstractListModel
{
    Q_OBJECT
    QList<Ticket> m_tickets;

public:
    enum TicketRole {
        IdRole = Qt::UserRole+1,
        StatusRole,
        FirstNameRole,
        LastNameRole,
        EmailRole,
        TimeIdRole,
        TimeRole,
        TimeOfReservationRole,
        YearRole
    };
    explicit TicketModel(QObject *parent = nullptr);

    // Basic functionality:
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QHash<int, QByteArray> roleNames() const override;

    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
//    bool setData(const QModelIndex &index, const QVariant &value, int role) override;

    void loadFromArray(QJsonArray array);
    Q_INVOKABLE void loadFromJson(QString json);
    void clear();
};

#endif // TICKETMODEL_H
