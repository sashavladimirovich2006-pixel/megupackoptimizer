#pragma once
#include <QString>
#include <QVariantMap>

class CleanupManager {
public:
    static bool cleanTemp();
    static bool cleanLocalCache();
    static bool cleanStorage();
    static bool cleanFileExplorer();
    static bool cleanMicrosoftStore();
    static bool cleanNetwork();
    static bool cleanSystemRestore();
    static QVariantMap getCleanerDetails(const QString &cleanerName);
};
