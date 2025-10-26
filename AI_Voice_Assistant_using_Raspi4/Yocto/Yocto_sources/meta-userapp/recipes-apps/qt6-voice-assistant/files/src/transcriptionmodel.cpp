#include "transcriptionmodel.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>

TranscriptionModel::TranscriptionModel(QObject *parent)
    : QAbstractListModel(parent)
    , m_nextId(1)
{
}

int TranscriptionModel::rowCount(const QModelIndex &parent) const
{
    if (parent.isValid())
        return 0;
    
    return m_transcriptions.count();
}

QVariant TranscriptionModel::data(const QModelIndex &index, int role) const
{
    if (!index.isValid() || index.row() >= m_transcriptions.count())
        return QVariant();
    
    const TranscriptionItem &item = m_transcriptions.at(index.row());
    
    switch (role) {
    case TextRole:
        return item.text;
    case TimestampRole:
        return item.timestamp;
    case IdRole:
        return item.id;
    case TimeStringRole:
        return item.timestamp.toString("hh:mm:ss");
    default:
        return QVariant();
    }
}

QHash<int, QByteArray> TranscriptionModel::roleNames() const
{
    QHash<int, QByteArray> roles;
    roles[TextRole] = "text";
    roles[TimestampRole] = "timestamp";
    roles[IdRole] = "transcriptionId";
    roles[TimeStringRole] = "timeString";
    return roles;
}

void TranscriptionModel::addTranscription(const QString &text, const QDateTime &timestamp)
{
    if (text.trimmed().isEmpty())
        return;
    
    beginInsertRows(QModelIndex(), 0, 0);
    
    TranscriptionItem item;
    item.text = text;
    item.timestamp = timestamp;
    item.id = m_nextId++;
    
    m_transcriptions.prepend(item);
    
    endInsertRows();
    emit countChanged();
    
    qDebug() << "Added transcription:" << text;
}

void TranscriptionModel::removeTranscription(int id)
{
    for (int i = 0; i < m_transcriptions.count(); ++i) {
        if (m_transcriptions[i].id == id) {
            beginRemoveRows(QModelIndex(), i, i);
            m_transcriptions.removeAt(i);
            endRemoveRows();
            emit countChanged();
            break;
        }
    }
}

void TranscriptionModel::clear()
{
    if (m_transcriptions.isEmpty())
        return;
    
    beginResetModel();
    m_transcriptions.clear();
    endResetModel();
    emit countChanged();
}

void TranscriptionModel::exportToFile(const QString &filePath)
{
    QFile file(filePath);
    
    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        emit exportCompleted(false, "Failed to open file for writing");
        return;
    }
    
    QTextStream out(&file);
    out << "Voice Assistant Transcription History\n";
    out << "======================================\n\n";
    
    for (const TranscriptionItem &item : m_transcriptions) {
        out << "[" << item.timestamp.toString("yyyy-MM-dd hh:mm:ss") << "] ";
        out << item.text << "\n\n";
    }
    
    file.close();
    emit exportCompleted(true, "Successfully exported " + QString::number(m_transcriptions.count()) + " transcriptions");
}

