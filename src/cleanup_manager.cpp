#include "cleanup_manager.h"
#include "logger.h"

#include <QDir>
#include <QDirIterator>
#include <QFileInfo>
#include <QFile>
#include <QProcess>
#include <QRegularExpression>

#ifdef Q_OS_WIN
#include <windows.h>
#include <shlobj.h>
#include <shellapi.h>
#endif

// Private Helper Functions
void deleteDirectoryContents(const QString &dirPath) {
    QDir dir(dirPath);
    if (!dir.exists()) return;
    for (const QFileInfo &info : dir.entryInfoList(QDir::NoDotAndDotDot | QDir::AllEntries)) {
        if (info.isDir()) {
            QDir subDir(info.absoluteFilePath());
            subDir.removeRecursively();
        } else {
            QFile::remove(info.absoluteFilePath());
        }
    }
}

bool CleanupManager::cleanTemp() {
    Logger::log("Starting Temporary Files Cleanup...", "INFO");
    
#ifdef Q_OS_WIN
    QString userTemp = QDir::tempPath();
    Logger::log("Cleaning User Temp: " + userTemp, "INFO");
    deleteDirectoryContents(userTemp);
    
    // System Temp
    wchar_t windir[MAX_PATH];
    if (GetWindowsDirectoryW(windir, MAX_PATH)) {
        QString winPath = QString::fromWCharArray(windir);
        QString sysTemp = winPath + "\\Temp";
        Logger::log("Cleaning System Temp: " + sysTemp, "INFO");
        deleteDirectoryContents(sysTemp);
    }
#else
    Logger::log("[Simulation] Windows temp directories cleared.", "INFO");
#endif

    Logger::log("Temporary Files Cleanup completed.", "INFO");
    return true;
}

bool CleanupManager::cleanLocalCache() {
    Logger::log("Starting AppData Local/Roaming Cache Cleanup...", "INFO");
    
#ifdef Q_OS_WIN
    QString localAppData = QString::fromLocal8Bit(qgetenv("LOCALAPPDATA"));
    QString appData = QString::fromLocal8Bit(qgetenv("APPDATA"));
    
    if (localAppData.isEmpty()) {
        localAppData = QDir::homePath() + "/AppData/Local";
    }
    if (appData.isEmpty()) {
        appData = QDir::homePath() + "/AppData/Roaming";
    }
    
    QStringList cacheDirs;
    
    // 1. Google Chrome Cache
    cacheDirs << localAppData + "/Google/Chrome/User Data/Default/Cache";
    cacheDirs << localAppData + "/Google/Chrome/User Data/Default/Code Cache";
    
    // 2. Microsoft Edge Cache
    cacheDirs << localAppData + "/Microsoft/Edge/User Data/Default/Cache";
    cacheDirs << localAppData + "/Microsoft/Edge/User Data/Default/Code Cache";
    
    // 3. Spotify Cache
    cacheDirs << localAppData + "/Spotify/Storage";
    
    // 4. Discord Cache
    cacheDirs << appData + "/Discord/Cache";
    cacheDirs << appData + "/Discord/Code Cache";
    cacheDirs << appData + "/Discord/GPUCache";
    
    // 5. Steam HTML Cache
    cacheDirs << localAppData + "/Steam/htmlcache";
    
    // 6. NVIDIA Shader Cache
    cacheDirs << localAppData + "/NVIDIA/DXCache";
    cacheDirs << localAppData + "/NVIDIA/GLCache";
    
    // 7. AMD Shader Cache
    cacheDirs << localAppData + "/AMD/DxCache";
    
    // 8. Firefox Cache (Iterating over profile subfolders)
    QString firefoxProfilesPath = localAppData + "/Mozilla/Firefox/Profiles";
    QDir firefoxDir(firefoxProfilesPath);
    if (firefoxDir.exists()) {
        for (const QString &profileDirName : firefoxDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot)) {
            QString profilePath = firefoxProfilesPath + "/" + profileDirName;
            cacheDirs << profilePath + "/cache2";
            cacheDirs << profilePath + "/startupCache";
        }
    }
    
    // 9. Developer Caches (pip, npm, NuGet)
    cacheDirs << localAppData + "/pip/cache";
    cacheDirs << appData + "/npm-cache";
    cacheDirs << localAppData + "/NuGet/v3-cache";
    cacheDirs << localAppData + "/NuGet/Cache";
    
    // Clean all listed directories
    for (const QString &path : cacheDirs) {
        if (QDir(path).exists()) {
            Logger::log("Cleaning Cache Directory: " + path, "INFO");
            deleteDirectoryContents(path);
        }
    }
#else
    Logger::log("[Simulation] AppData Cache cleared.", "INFO");
#endif
    
    Logger::log("AppData Local/Roaming Cache Cleanup completed.", "INFO");
    return true;
}

bool CleanupManager::cleanStorage() {
    Logger::log("Starting Storage Cleanup...", "INFO");
    
    // 1. User Temp
    QString userTemp = QDir::tempPath();
    Logger::log("Cleaning User Temp: " + userTemp, "INFO");
    deleteDirectoryContents(userTemp);
    
    // 2. System Temp
#ifdef Q_OS_WIN
    wchar_t windir[MAX_PATH];
    if (GetWindowsDirectoryW(windir, MAX_PATH)) {
        QString winPath = QString::fromWCharArray(windir);
        QString sysTemp = winPath + "\\Temp";
        Logger::log("Cleaning System Temp: " + sysTemp, "INFO");
        deleteDirectoryContents(sysTemp);
        
        // 3. Prefetch
        QString prefetch = winPath + "\\Prefetch";
        Logger::log("Cleaning Prefetch: " + prefetch, "INFO");
        deleteDirectoryContents(prefetch);

        // 4. SoftwareDistribution\Download
        QString swDist = winPath + "\\SoftwareDistribution\\Download";
        Logger::log("Cleaning Windows Update Cache: " + swDist, "INFO");
        deleteDirectoryContents(swDist);
    }
    
    // 5. Empty Recycle Bin
    Logger::log("Emptying Recycle Bin...", "INFO");
    SHEmptyRecycleBinW(NULL, NULL, SHERB_NOCONFIRMATION | SHERB_NOPROGRESSUI | SHERB_NOSOUND);
#else
    Logger::log("[Simulation] Windows temp directories and Recycle Bin cleared.", "INFO");
#endif
    
    Logger::log("Storage Cleanup completed.", "INFO");
    return true;
}

bool CleanupManager::cleanFileExplorer() {
    Logger::log("Starting File Explorer Cleanup...", "INFO");
#ifdef Q_OS_WIN
    // 1. Clear TypedPaths
    HKEY hKey;
    if (RegOpenKeyExW(HKEY_CURRENT_USER, L"Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\TypedPaths", 0, KEY_SET_VALUE | KEY_QUERY_VALUE, &hKey) == ERROR_SUCCESS) {
        wchar_t valueName[16384];
        DWORD valueNameSize = 16384;
        while (true) {
            valueNameSize = 16384;
            if (RegEnumValueW(hKey, 0, valueName, &valueNameSize, NULL, NULL, NULL, NULL) == ERROR_SUCCESS) {
                RegDeleteValueW(hKey, valueName);
            } else {
                break;
            }
        }
        RegCloseKey(hKey);
    }
    
    // 2. Clear RunMRU
    if (RegOpenKeyExW(HKEY_CURRENT_USER, L"Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\RunMRU", 0, KEY_SET_VALUE | KEY_QUERY_VALUE, &hKey) == ERROR_SUCCESS) {
        wchar_t valueName[16384];
        DWORD valueNameSize = 16384;
        while (true) {
            valueNameSize = 16384;
            if (RegEnumValueW(hKey, 0, valueName, &valueNameSize, NULL, NULL, NULL, NULL) == ERROR_SUCCESS) {
                RegDeleteValueW(hKey, valueName);
            } else {
                break;
            }
        }
        RegCloseKey(hKey);
    }

    // 3. Clear RecentDocs
    RegDeleteKeyW(HKEY_CURRENT_USER, L"Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\RecentDocs");

    // 4. Delete recent folders files
    QString appData = QDir::toNativeSeparators(QDir::homePath() + "\\AppData\\Roaming\\Microsoft\\Windows\\Recent");
    deleteDirectoryContents(appData);
    deleteDirectoryContents(appData + "\\AutomaticDestinations");
    deleteDirectoryContents(appData + "\\CustomDestinations");
#else
    Logger::log("[Simulation] File Explorer history and recent items cleared.", "INFO");
#endif
    Logger::log("File Explorer Cleanup completed.", "INFO");
    return true;
}

bool CleanupManager::cleanMicrosoftStore() {
    Logger::log("Starting Microsoft Store Cleanup...", "INFO");
#ifdef Q_OS_WIN
    // 1. Run wsreset.exe in background
    QProcess::startDetached("wsreset.exe");
    
    // 2. Clean LocalCache folder
    QString localAppData = QDir::toNativeSeparators(QDir::homePath() + "\\AppData\\Local\\Packages\\Microsoft.WindowsStore_8wekyb3d8bbwe\\LocalCache");
    deleteDirectoryContents(localAppData);
#else
    Logger::log("[Simulation] Microsoft Store cache cleared.", "INFO");
#endif
    Logger::log("Microsoft Store Cleanup completed.", "INFO");
    return true;
}

bool CleanupManager::cleanNetwork() {
    Logger::log("Starting Network Cleanup (Flush DNS & Reset)...", "INFO");
#ifdef Q_OS_WIN
    QProcess proc;
    proc.start("ipconfig", QStringList() << "/flushdns");
    proc.waitForFinished(5000);
    
    proc.start("netsh", QStringList() << "winsock" << "reset");
    proc.waitForFinished(5000);
    
    proc.start("netsh", QStringList() << "int" << "ip" << "reset");
    proc.waitForFinished(5000);
#else
    Logger::log("[Simulation] Network DNS cache flushed and winsock reset.", "INFO");
#endif
    Logger::log("Network Cleanup completed.", "INFO");
    return true;
}

bool CleanupManager::cleanSystemRestore() {
    Logger::log("Starting System Restore Points Cleanup...", "INFO");
#ifdef Q_OS_WIN
    QProcess proc;
    proc.start("vssadmin", QStringList() << "delete" << "shadows" << "/for=C:" << "/all" << "/quiet");
    proc.waitForFinished(10000);
    
    proc.start("powershell", QStringList() << "-Command" << "Disable-ComputerRestore -Drive 'C:'; Enable-ComputerRestore -Drive 'C:'");
    proc.waitForFinished(15000);
#else
    Logger::log("[Simulation] System Restore shadow copies deleted.", "INFO");
#endif
    Logger::log("System Restore Points Cleanup completed.", "INFO");
    return true;
}

QVariantMap CleanupManager::getCleanerDetails(const QString &cleanerName) {
    QVariantMap res;
    
    auto getDirSizeAndCount = [](const QString &path, qint64 &count) -> qint64 {
        qint64 size = 0;
        QDir dir(path);
        if (!dir.exists()) return 0;
        QDirIterator it(path, QDir::Files | QDir::NoDotAndDotDot, QDirIterator::Subdirectories);
        while (it.hasNext()) {
            it.next();
            size += it.fileInfo().size();
            count++;
        }
        return size;
    };

    auto parseVssCount = [](const QString &output) -> qint64 {
        qint64 count = 0;
        QStringList lines = output.split('\n');
        for (const QString &line : lines) {
            if (line.contains("Shadow Copy ID", Qt::CaseInsensitive) || 
                line.contains("теневого копирования", Qt::CaseInsensitive)) {
                count++;
            }
        }
        return count;
    };

    auto parseVssSize = [](const QString &output) -> qint64 {
        QStringList lines = output.split('\n');
        for (const QString &line : lines) {
            if (line.contains("Used Shadow", Qt::CaseInsensitive) || 
                line.contains("хранилища теневых", Qt::CaseInsensitive)) {
                int colonIdx = line.indexOf(':');
                int parenIdx = line.indexOf('(', colonIdx);
                if (colonIdx != -1) {
                    QString part = line.mid(colonIdx + 1, parenIdx != -1 ? (parenIdx - colonIdx - 1) : -1).trimmed();
                    QStringList parts = part.split(QRegularExpression("\\s+"));
                    if (parts.size() >= 2) {
                        bool ok = false;
                        double num = parts[0].toDouble(&ok);
                        if (ok) {
                            QString unit = parts[1].toUpper();
                            qint64 multiplier = 1;
                            if (unit.contains("KB") || unit.contains("КБ")) multiplier = 1024;
                            else if (unit.contains("MB") || unit.contains("МБ")) multiplier = 1024 * 1024;
                            else if (unit.contains("GB") || unit.contains("ГБ")) multiplier = 1024 * 1024 * 1024;
                            else if (unit.contains("TB") || unit.contains("ТБ")) multiplier = 1024LL * 1024 * 1024 * 1024;
                            return static_cast<qint64>(num * multiplier);
                        }
                    }
                }
            }
        }
        return 0;
    };

    if (cleanerName == "temp") {
        qint64 userTempSize = 0, userTempCount = 0;
        qint64 sysTempSize = 0, sysTempCount = 0;
        
        userTempSize = getDirSizeAndCount(QDir::tempPath(), userTempCount);
        
#ifdef Q_OS_WIN
        wchar_t windir[MAX_PATH];
        if (GetWindowsDirectoryW(windir, MAX_PATH)) {
            QString winPath = QString::fromWCharArray(windir);
            sysTempSize = getDirSizeAndCount(winPath + "\\Temp", sysTempCount);
        }
#endif
        
        res["userTempSize"] = userTempSize;
        res["userTempCount"] = userTempCount;
        res["sysTempSize"] = sysTempSize;
        res["sysTempCount"] = sysTempCount;
        res["totalSize"] = userTempSize + sysTempSize;
        res["totalCount"] = userTempCount + sysTempCount;
    }
    else if (cleanerName == "cache") {
        qint64 browserSize = 0, browserCount = 0;
        qint64 appSize = 0, appCount = 0;
        qint64 shaderSize = 0, shaderCount = 0;
        
        QString localAppData = QString::fromLocal8Bit(qgetenv("LOCALAPPDATA"));
        QString appData = QString::fromLocal8Bit(qgetenv("APPDATA"));
        
        if (localAppData.isEmpty()) localAppData = QDir::homePath() + "/AppData/Local";
        if (appData.isEmpty()) appData = QDir::homePath() + "/AppData/Roaming";
        
        QStringList browserDirs;
        browserDirs << localAppData + "/Google/Chrome/User Data/Default/Cache";
        browserDirs << localAppData + "/Google/Chrome/User Data/Default/Code Cache";
        browserDirs << localAppData + "/Microsoft/Edge/User Data/Default/Cache";
        browserDirs << localAppData + "/Microsoft/Edge/User Data/Default/Code Cache";
        
        QString firefoxProfilesPath = localAppData + "/Mozilla/Firefox/Profiles";
        QDir firefoxDir(firefoxProfilesPath);
        if (firefoxDir.exists()) {
            for (const QString &profileDirName : firefoxDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot)) {
                browserDirs << firefoxProfilesPath + "/" + profileDirName + "/cache2";
                browserDirs << firefoxProfilesPath + "/" + profileDirName + "/startupCache";
            }
        }

        for (const QString &path : browserDirs) {
            browserSize += getDirSizeAndCount(path, browserCount);
        }

        QStringList appDirs;
        appDirs << localAppData + "/Spotify/Storage";
        appDirs << appData + "/Discord/Cache";
        appDirs << appData + "/Discord/Code Cache";
        appDirs << appData + "/Discord/GPUCache";
        appDirs << localAppData + "/Steam/htmlcache";
        
        for (const QString &path : appDirs) {
            appSize += getDirSizeAndCount(path, appCount);
        }

        qint64 devSize = 0, devCount = 0;
        QStringList devDirs;
        devDirs << localAppData + "/pip/cache";
        devDirs << appData + "/npm-cache";
        devDirs << localAppData + "/NuGet/v3-cache";
        devDirs << localAppData + "/NuGet/Cache";

        for (const QString &path : devDirs) {
            devSize += getDirSizeAndCount(path, devCount);
        }

        QStringList shaderDirs;
        shaderDirs << localAppData + "/NVIDIA/DXCache";
        shaderDirs << localAppData + "/NVIDIA/GLCache";
        shaderDirs << localAppData + "/AMD/DxCache";

        for (const QString &path : shaderDirs) {
            shaderSize += getDirSizeAndCount(path, shaderCount);
        }

        res["browserSize"] = browserSize;
        res["browserCount"] = browserCount;
        res["appSize"] = appSize;
        res["appCount"] = appCount;
        res["shaderSize"] = shaderSize;
        res["shaderCount"] = shaderCount;
        res["devSize"] = devSize;
        res["devCount"] = devCount;
        res["totalSize"] = browserSize + appSize + shaderSize + devSize;
        res["totalCount"] = browserCount + appCount + shaderCount + devCount;
    }
    else if (cleanerName == "storage") {
        qint64 tempSize = 0, tempCount = 0;
        qint64 prefetchSize = 0, prefetchCount = 0;
        qint64 updateSize = 0, updateCount = 0;
        qint64 rbSize = 0, rbCount = 0;

        tempSize += getDirSizeAndCount(QDir::tempPath(), tempCount);
        
#ifdef Q_OS_WIN
        wchar_t windir[MAX_PATH];
        if (GetWindowsDirectoryW(windir, MAX_PATH)) {
            QString winPath = QString::fromWCharArray(windir);
            tempSize += getDirSizeAndCount(winPath + "\\Temp", tempCount);
            prefetchSize += getDirSizeAndCount(winPath + "\\Prefetch", prefetchCount);
            updateSize += getDirSizeAndCount(winPath + "\\SoftwareDistribution\\Download", updateCount);
        }

        SHQUERYRBINFO rbInfo;
        rbInfo.cbSize = sizeof(SHQUERYRBINFO);
        if (SHQueryRecycleBinW(NULL, &rbInfo) == S_OK) {
            rbSize = rbInfo.i64Size;
            rbCount = rbInfo.i64NumItems;
        }
#endif

        res["tempSize"] = tempSize;
        res["tempCount"] = tempCount;
        res["prefetchSize"] = prefetchSize;
        res["prefetchCount"] = prefetchCount;
        res["updateSize"] = updateSize;
        res["updateCount"] = updateCount;
        res["recycleBinSize"] = rbSize;
        res["recycleBinCount"] = rbCount;
        res["totalSize"] = tempSize + prefetchSize + updateSize + rbSize;
        res["totalCount"] = tempCount + prefetchCount + updateCount + rbCount;
    }
    else if (cleanerName == "explorer") {
        qint64 recentSize = 0, recentCount = 0;
        QString appData = QString::fromLocal8Bit(qgetenv("APPDATA"));
        if (appData.isEmpty()) appData = QDir::homePath() + "/AppData/Roaming";
        
        recentSize += getDirSizeAndCount(appData + "/Microsoft/Windows/Recent", recentCount);
        
        qint64 registryCount = 0;
#ifdef Q_OS_WIN
        HKEY hKey;
        if (RegOpenKeyExW(HKEY_CURRENT_USER, L"Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\TypedPaths", 0, KEY_QUERY_VALUE, &hKey) == ERROR_SUCCESS) {
            DWORD valueCount = 0;
            if (RegQueryInfoKeyW(hKey, NULL, NULL, NULL, NULL, NULL, NULL, &valueCount, NULL, NULL, NULL, NULL) == ERROR_SUCCESS) {
                registryCount += valueCount;
            }
            RegCloseKey(hKey);
        }
        if (RegOpenKeyExW(HKEY_CURRENT_USER, L"Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\RunMRU", 0, KEY_QUERY_VALUE, &hKey) == ERROR_SUCCESS) {
            DWORD valueCount = 0;
            if (RegQueryInfoKeyW(hKey, NULL, NULL, NULL, NULL, NULL, NULL, &valueCount, NULL, NULL, NULL, NULL) == ERROR_SUCCESS) {
                registryCount += valueCount;
            }
            RegCloseKey(hKey);
        }
#endif
        res["recentSize"] = recentSize;
        res["recentCount"] = recentCount;
        res["registryCount"] = registryCount;
        res["totalSize"] = recentSize;
        res["totalCount"] = recentCount + registryCount;
    }
    else if (cleanerName == "store") {
        qint64 storeSize = 0, storeCount = 0;
        QString localAppData = QString::fromLocal8Bit(qgetenv("LOCALAPPDATA"));
        if (localAppData.isEmpty()) localAppData = QDir::homePath() + "/AppData/Local";
        
        storeSize = getDirSizeAndCount(localAppData + "/Packages/Microsoft.WindowsStore_8wekyb3d8bbwe/LocalCache", storeCount);
        
        res["storeSize"] = storeSize;
        res["storeCount"] = storeCount;
        res["totalSize"] = storeSize;
        res["totalCount"] = storeCount;
    }
    else if (cleanerName == "network") {
        qint64 dnsCount = 0;
        qint64 activeConnCount = 0;
#ifdef Q_OS_WIN
        QProcess proc;
        proc.start("ipconfig", QStringList() << "/displaydns");
        if (proc.waitForFinished(3000)) {
            QString out = QString::fromLocal8Bit(proc.readAllStandardOutput());
            QStringList lines = out.split('\n');
            for (const QString &line : lines) {
                if (line.contains("Record Name", Qt::CaseInsensitive) || 
                    line.contains("Имя записи", Qt::CaseInsensitive)) {
                    dnsCount++;
                }
            }
        }
        proc.start("netstat", QStringList() << "-an");
        if (proc.waitForFinished(3000)) {
            QString out = QString::fromLocal8Bit(proc.readAllStandardOutput());
            QStringList lines = out.split('\n');
            for (const QString &line : lines) {
                QString trimmed = line.trimmed();
                if (trimmed.startsWith("TCP", Qt::CaseInsensitive) || 
                    trimmed.startsWith("UDP", Qt::CaseInsensitive)) {
                    activeConnCount++;
                }
            }
        }
#endif
        res["dnsCount"] = dnsCount;
        res["activeConnCount"] = activeConnCount;
        res["totalSize"] = 0;
        res["totalCount"] = dnsCount + activeConnCount;
    }
    else if (cleanerName == "restore") {
        qint64 restoreSize = 0;
        qint64 restoreCount = 0;
#ifdef Q_OS_WIN
        QProcess proc;
        proc.start("vssadmin", QStringList() << "list" << "shadows" << "/for=C:");
        if (proc.waitForFinished(3000)) {
            QString out = QString::fromLocal8Bit(proc.readAllStandardOutput());
            restoreCount = parseVssCount(out);
        }
        proc.start("vssadmin", QStringList() << "list" << "shadowstorage");
        if (proc.waitForFinished(3000)) {
            QString out = QString::fromLocal8Bit(proc.readAllStandardOutput());
            restoreSize = parseVssSize(out);
        }
#endif
        res["restoreSize"] = restoreSize;
        res["restoreCount"] = restoreCount;
        res["totalSize"] = restoreSize;
        res["totalCount"] = restoreCount;
    }
    
    return res;
}
