#ifndef TICKETFILTERMODEL_H
#define TICKETFILTERMODEL_H

#include <QSortFilterProxyModel>

class TicketFilterModel : public QSortFilterProxyModel
{
    Q_OBJECT
    Q_PROPERTY(QString query READ query WRITE setQuery NOTIFY queryChanged FINAL)

public:
    explicit TicketFilterModel(QObject *parent = nullptr);

    QString query() const
    {
        return m_query;
    }
    void setQuery(const QString &newQuery)
    {
        if (m_query == newQuery)
            return;
        m_query = newQuery;
        emit queryChanged();
    }

signals:
    void queryChanged();

protected:
    bool filterAcceptsRow(int source_row, const QModelIndex &source_parent) const override;
private:
    QString m_query;
};

#endif // TICKETFILTERMODEL_H
