#ifndef TRANSCRIPTIONMODEL_H
#define TRANSCRIPTIONMODEL_H

#include <QAbstractListModel>
#include <QDateTime>
#include <QVector>

struct TranscriptionItem {
    QString text;
    QDateTime timestamp;
    int id;
};

class TranscriptionModel : public QAbstractListModel
{
    Q_OBJECT
    Q_PROPERTY(int count READ count NOTIFY countChanged)
    
public:
    enum TranscriptionRoles {
        TextRole = Qt::UserRole + 1,
        TimestampRole,
        IdRole,
        TimeStringRole
    };
    
    explicit TranscriptionModel(QObject *parent = nullptr);
    
    // QAbstractListModel interface
    int rowCount(const QModelIndex &parent = QModelIndex()) const override;
    QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const override;
    QHash<int, QByteArray> roleNames() const override;
    
    int count() const { return m_transcriptions.count(); }
    
public slots:
    void addTranscription(const QString &text, const QDateTime &timestamp);
    void removeTranscription(int id);
    void clear();
    void exportToFile(const QString &filePath);
    
signals:
    void countChanged();
    void exportCompleted(bool success, const QString &message);
    
private:
    QVector<TranscriptionItem> m_transcriptions;
    int m_nextId;
};

#endif // TRANSCRIPTIONMODEL_H

