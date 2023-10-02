#include "ticketfiltermodel.h"
#include "ticketmodel.h"
#include <array>
#include <algorithm>

TicketFilterModel::TicketFilterModel(QObject *parent): QSortFilterProxyModel(parent) {
    connect(this, &TicketFilterModel::queryChanged, this, &TicketFilterModel::invalidateFilter);
}

bool TicketFilterModel::filterAcceptsRow(int source_row, const QModelIndex &source_parent) const {
    Q_UNUSED(source_parent)
    if (!sourceModel()) {
        return false;
    }
    QStringList queries = m_query.split(" ", Qt::SkipEmptyParts, Qt::CaseInsensitive);
    QModelIndex index = sourceModel()->index(source_row, 0);
    QString firstName = index.data(TicketModel::FirstNameRole).toString();
    QString lastName = index.data(TicketModel::LastNameRole).toString();
    QString email = index.data(TicketModel::EmailRole).toString();
    QString time = index.data(TicketModel::TimeRole).toString();
    QStringList strings = {firstName, lastName, email, time};

    return std::all_of(queries.cbegin(), queries.cend(), [strings](const QString &q) {
        return std::any_of(strings.cbegin(), strings.cend(), [q](const QString &str) {
               return str.contains(q, Qt::CaseInsensitive);
    });});
}
