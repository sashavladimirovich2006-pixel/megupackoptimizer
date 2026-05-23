#include "optimizer.h"
#include "logger.h"
#include "settings.h"
#include <QUrl>
#include <QFileInfo>
#include <QDir>
#include <QDirIterator>
#include <QThread>
#include <QCoreApplication>
#include <QSysInfo>
#include <QScreen>
#include <QGuiApplication>
#include <QProcess>

#ifdef Q_OS_WIN
#include <windows.h>
#endif

Optimizer::Optimizer(QObject *parent) : QObject(parent) {
    refreshSystemInfo();
    loadSystemStates();
}

Optimizer::~Optimizer() {
}

void Optimizer::setWinSearchActive(bool val) {
    if (m_winSearchActive != val) {
        m_winSearchActive = val;
        emit winSearchActiveChanged(m_winSearchActive);
    }
}

void Optimizer::setDriveStates(const QVariantMap &states) {
    if (m_driveStates != states) {
        m_driveStates = states;
        emit driveStatesChanged(m_driveStates);
    }
}

void Optimizer::scanDrives() {
    QStringList drives;
    QVariantMap states;
    
#ifdef Q_OS_WIN
    wchar_t driveStrings[256];
    DWORD len = GetLogicalDriveStringsW(254, driveStrings);
    if (len > 0) {
        wchar_t* drive = driveStrings;
        while (*drive) {
            UINT type = GetDriveTypeW(drive);
            if (type == DRIVE_FIXED) {
                QString letter = QString::fromWCharArray(drive).left(2).toUpper();
                
                // Query drive indexing state (FILE_ATTRIBUTE_NOT_CONTENT_INDEXED)
                bool active = true;
                DWORD attrs = GetFileAttributesW(drive);
                if (attrs != INVALID_FILE_ATTRIBUTES) {
                    active = !(attrs & FILE_ATTRIBUTE_NOT_CONTENT_INDEXED);
                }
                
                states[letter] = active;
                
                if (letter != "C:") {
                    drives.append(letter);
                }
            }
            drive += wcslen(drive) + 1;
        }
    }
#else
    // Simulation fallbacks for other OS developers
    states["C:"] = true;
    states["D:"] = false;
    states["E:"] = true;
    drives.append("D:");
    drives.append("E:");
#endif

    m_fixedDrives = drives;
    m_driveStates = states;
    
    emit fixedDrivesChanged(m_fixedDrives);
    emit driveStatesChanged(m_driveStates);
}

void Optimizer::loadSystemStates() {
    bool isWSearchDisabled = false;
#ifdef Q_OS_WIN
    SC_HANDLE hSCM = OpenSCManagerW(NULL, NULL, SC_MANAGER_CONNECT);
    if (hSCM) {
        SC_HANDLE hService = OpenServiceW(hSCM, L"WSearch", SERVICE_QUERY_CONFIG);
        if (hService) {
            DWORD bytesNeeded = 0;
            if (!QueryServiceConfigW(hService, NULL, 0, &bytesNeeded) && GetLastError() == ERROR_INSUFFICIENT_BUFFER) {
                QByteArray buffer(static_cast<int>(bytesNeeded), 0);
                LPQUERY_SERVICE_CONFIGW pConfig = reinterpret_cast<LPQUERY_SERVICE_CONFIGW>(buffer.data());
                if (QueryServiceConfigW(hService, pConfig, bytesNeeded, &bytesNeeded)) {
                    if (pConfig->dwStartType == SERVICE_DISABLED) {
                        isWSearchDisabled = true;
                    }
                }
            }
            CloseServiceHandle(hService);
        }
        CloseServiceHandle(hSCM);
    }
#endif
    m_winSearchActive = !isWSearchDisabled;
    m_originalWinSearchActive = m_winSearchActive;
    emit winSearchActiveChanged(m_winSearchActive);
    emit originalWinSearchActiveChanged(m_originalWinSearchActive);

    scanDrives();
    m_originalDriveStates = m_driveStates;
    emit originalDriveStatesChanged(m_originalDriveStates);
}

void Optimizer::startSystemOptimization() {
    if (m_isOptimizingSystem) return;
    
    m_isOptimizingSystem = true;
    m_systemProgress = 0.0;
    emit isOptimizingSystemChanged(m_isOptimizingSystem);
    emit systemProgressChanged(m_systemProgress);

    Logger::log("Starting System Drives Optimization...", "INFO");
    emit systemStepReported(tr("Starting system optimization..."), "INFO");

    // Copy targets to worker thread scope
    bool searchVal = m_winSearchActive;
    QVariantMap targets = m_driveStates;

    QThread* worker = QThread::create([this, searchVal, targets]() {
        // Step 1: Windows Search service
        emit systemStepReported(tr("Processing Windows Search service..."), "INFO");
        QThread::msleep(800);
        
        bool wSearchSuccess = true;
#ifdef Q_OS_WIN
        SC_HANDLE hSCM = OpenSCManagerW(NULL, NULL, SC_MANAGER_ALL_ACCESS);
        if (hSCM) {
            SC_HANDLE hService = OpenServiceW(hSCM, L"WSearch", SERVICE_CHANGE_CONFIG | SERVICE_STOP | SERVICE_START | SERVICE_QUERY_STATUS);
            if (hService) {
                DWORD startType = searchVal ? SERVICE_AUTO_START : SERVICE_DISABLED;
                if (ChangeServiceConfigW(hService, SERVICE_NO_CHANGE, startType, SERVICE_NO_CHANGE, NULL, NULL, NULL, NULL, NULL, NULL, NULL)) {
                    QString logMsg = searchVal ? tr("Windows Search startup set to Automatic.") : tr("Windows Search startup set to Disabled.");
                    emit systemStepReported(logMsg, "INFO");
                    
                    SERVICE_STATUS_PROCESS ssp;
                    DWORD bytesNeeded = 0;
                    if (QueryServiceStatusEx(hService, SC_STATUS_PROCESS_INFO, reinterpret_cast<LPBYTE>(&ssp), sizeof(ssp), &bytesNeeded)) {
                        if (!searchVal && ssp.dwCurrentState != SERVICE_STOPPED && ssp.dwCurrentState != SERVICE_STOP_PENDING) {
                            emit systemStepReported(tr("Stopping Windows Search service..."), "INFO");
                            SERVICE_STATUS status;
                            ControlService(hService, SERVICE_CONTROL_STOP, &status);
                            for (int i = 0; i < 15; ++i) {
                                QThread::msleep(200);
                                if (QueryServiceStatusEx(hService, SC_STATUS_PROCESS_INFO, reinterpret_cast<LPBYTE>(&ssp), sizeof(ssp), &bytesNeeded)) {
                                    if (ssp.dwCurrentState == SERVICE_STOPPED) break;
                                }
                            }
                            if (ssp.dwCurrentState == SERVICE_STOPPED) {
                                emit systemStepReported(tr("Windows Search service stopped successfully."), "SUCCESS");
                            } else {
                                emit systemStepReported(tr("Windows Search service stop requested."), "WARNING");
                            }
                        } else if (searchVal && ssp.dwCurrentState != SERVICE_RUNNING && ssp.dwCurrentState != SERVICE_START_PENDING) {
                            emit systemStepReported(tr("Starting Windows Search service..."), "INFO");
                            if (StartServiceW(hService, 0, NULL)) {
                                for (int i = 0; i < 15; ++i) {
                                    QThread::msleep(200);
                                    if (QueryServiceStatusEx(hService, SC_STATUS_PROCESS_INFO, reinterpret_cast<LPBYTE>(&ssp), sizeof(ssp), &bytesNeeded)) {
                                        if (ssp.dwCurrentState == SERVICE_RUNNING) break;
                                    }
                                }
                                if (ssp.dwCurrentState == SERVICE_RUNNING) {
                                    emit systemStepReported(tr("Windows Search service started successfully."), "SUCCESS");
                                } else {
                                    emit systemStepReported(tr("Windows Search service start pending."), "INFO");
                                }
                            } else {
                                emit systemStepReported(tr("Failed to start Windows Search service."), "ERROR");
                            }
                        }
                    }
                } else {
                    wSearchSuccess = false;
                    emit systemStepReported(tr("Failed to change Windows Search service configuration. Error: %1").arg(GetLastError()), "ERROR");
                }
                CloseServiceHandle(hService);
            } else {
                wSearchSuccess = false;
                emit systemStepReported(tr("Failed to open Windows Search service. Error: %1").arg(GetLastError()), "ERROR");
            }
            CloseServiceHandle(hSCM);
        } else {
            wSearchSuccess = false;
            emit systemStepReported(tr("Failed to connect to SCM. Error: %1").arg(GetLastError()), "ERROR");
        }
#else
        emit systemStepReported(tr("[Simulation] Windows Search service state set to: %1").arg(searchVal ? "Enabled" : "Disabled"), "SUCCESS");
#endif
        m_winSearchActive = searchVal;
        emit winSearchActiveChanged(m_winSearchActive);
        
        m_systemProgress = 0.25;
        emit systemProgressChanged(m_systemProgress);
        QThread::msleep(500);

        // Steps 2+: Iterate drives in target list
        int driveIndex = 0;
        int totalDrives = targets.keys().size();
        bool overallDrivesSuccess = true;
        
        for (const QString &driveLetter : targets.keys()) {
            emit systemStepReported(tr("Processing Drive %1 indexing...").arg(driveLetter), "INFO");
            QThread::msleep(800);
            
            bool targetVal = targets.value(driveLetter).toBool();
            bool driveSuccess = true;
            
            QString driveRoot = driveLetter + "\\";
#ifdef Q_OS_WIN
            DWORD attrs = GetFileAttributesW(reinterpret_cast<const wchar_t*>(driveRoot.utf16()));
            if (attrs != INVALID_FILE_ATTRIBUTES) {
                if (targetVal) {
                    attrs &= ~FILE_ATTRIBUTE_NOT_CONTENT_INDEXED;
                } else {
                    attrs |= FILE_ATTRIBUTE_NOT_CONTENT_INDEXED;
                }
                if (SetFileAttributesW(reinterpret_cast<const wchar_t*>(driveRoot.utf16()), attrs)) {
                    QString logMsg = targetVal ? tr("Drive %1 content indexing is now ENABLED.").arg(driveLetter) : tr("Drive %1 content indexing is now DISABLED.").arg(driveLetter);
                    emit systemStepReported(logMsg, "SUCCESS");
                } else {
                    driveSuccess = false;
                    overallDrivesSuccess = false;
                    emit systemStepReported(tr("Failed to update Drive %1 file attributes. Error: %2").arg(driveLetter).arg(GetLastError()), "ERROR");
                }
            } else {
                emit systemStepReported(tr("Drive %1 is not mounted or unavailable. Skipping.").arg(driveLetter), "WARNING");
            }
#else
            emit systemStepReported(tr("[Simulation] Drive %1 indexing set to: %2").arg(driveLetter).arg(targetVal ? "Enabled" : "Disabled"), "SUCCESS");
#endif
            driveIndex++;
            m_systemProgress = 0.25 + (0.75 * (double(driveIndex) / (totalDrives > 0 ? totalDrives : 1)));
            emit systemProgressChanged(m_systemProgress);
            QThread::msleep(500);
        }

        bool overallSuccess = wSearchSuccess && overallDrivesSuccess;
        if (overallSuccess) {
            emit systemStepReported(tr("System optimization completed successfully!"), "SUCCESS");
            Logger::log("System optimization completed successfully!", "INFO");
        } else {
            emit systemStepReported(tr("System optimization completed with warning/errors."), "WARNING");
            Logger::log("System optimization completed with warning/errors.", "WARNING");
        }

        m_driveStates = targets;
        m_originalWinSearchActive = searchVal;
        m_originalDriveStates = targets;
        
        emit driveStatesChanged(m_driveStates);
        emit originalWinSearchActiveChanged(m_originalWinSearchActive);
        emit originalDriveStatesChanged(m_originalDriveStates);

        m_isOptimizingSystem = false;
        emit isOptimizingSystemChanged(m_isOptimizingSystem);
        emit systemOptimizationFinished(overallSuccess);
    });

    connect(worker, &QThread::finished, worker, &QThread::deleteLater);
    worker->start();
}

void Optimizer::showPath(const QString &funcName) {
    if (funcName == "Windows Search service" || funcName == "wsearch") {
        QProcess::startDetached("cmd.exe", QStringList() << "/c" << "start services.msc");
        Logger::log("Opening Services Manager for Windows Search...", "INFO");
    } else {
        // Assume drive letter like "C:" or "D:"
        QString letter = funcName.trimmed();
        if (letter.endsWith("indexing", Qt::CaseInsensitive)) {
            // e.g. "Drive C: indexing" -> extract "C:"
            int colIdx = letter.indexOf(":");
            if (colIdx > 0) {
                letter = letter.mid(colIdx - 1, 2).trimmed();
            }
        }
        if (!letter.endsWith("\\")) {
            letter += "\\";
        }
        QProcess::startDetached("explorer.exe", QStringList() << letter);
        Logger::log(QString("Opening Drive %1 in File Explorer...").arg(letter), "INFO");
    }
}

void Optimizer::refreshSystemInfo() {
    m_osName = "Unknown OS";
    m_cpuName = "Unknown CPU";
    m_logicalCores = "Unknown Cores";
    m_ramSize = "Unknown RAM";
    m_gpuName = "Unknown GPU";
    m_motherboard = "Unknown Motherboard";
    m_storage = "Unknown Storage";
    m_display = "Unknown Display";

#ifdef Q_OS_WIN
    // 1. OS Name
    QString os = QSysInfo::prettyProductName();
    HKEY hKey;
    if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion", 0, KEY_READ, &hKey) == ERROR_SUCCESS) {
        wchar_t displayVersion[128] = {0};
        DWORD size = sizeof(displayVersion);
        if (RegQueryValueExW(hKey, L"DisplayVersion", NULL, NULL, (LPBYTE)displayVersion, &size) == ERROR_SUCCESS) {
            os = QSysInfo::prettyProductName() + QString(" (Build %1)").arg(QString::fromWCharArray(displayVersion));
        } else {
            wchar_t currentBuild[128] = {0};
            size = sizeof(currentBuild);
            if (RegQueryValueExW(hKey, L"CurrentBuild", NULL, NULL, (LPBYTE)currentBuild, &size) == ERROR_SUCCESS) {
                os = QSysInfo::prettyProductName() + QString(" (Build %1)").arg(QString::fromWCharArray(currentBuild));
            }
        }
        RegCloseKey(hKey);
    }
    m_osName = os;

    // 2. CPU Name
    if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"HARDWARE\\DESCRIPTION\\System\\CentralProcessor\\0", 0, KEY_READ, &hKey) == ERROR_SUCCESS) {
        wchar_t cpu[256] = {0};
        DWORD size = sizeof(cpu);
        if (RegQueryValueExW(hKey, L"ProcessorNameString", NULL, NULL, (LPBYTE)cpu, &size) == ERROR_SUCCESS) {
            m_cpuName = QString::fromWCharArray(cpu).trimmed();
        }
        RegCloseKey(hKey);
    }

    // 3. Logical Cores
    m_logicalCores = QString("%1 Logical Processors").arg(QThread::idealThreadCount());

    // 4. Memory (RAM)
    MEMORYSTATUSEX memInfo;
    memInfo.dwLength = sizeof(MEMORYSTATUSEX);
    if (GlobalMemoryStatusEx(&memInfo)) {
        double totalPhysMem = memInfo.ullTotalPhys / (1024.0 * 1024.0 * 1024.0);
        m_ramSize = QString::number(totalPhysMem, 'f', 2) + " GB RAM";
    }

    // 5. GPU Name
    DISPLAY_DEVICEW dd;
    dd.cb = sizeof(dd);
    for (int i = 0; EnumDisplayDevicesW(NULL, i, &dd, 0); ++i) {
        if (dd.StateFlags & DISPLAY_DEVICE_PRIMARY_DEVICE) {
            m_gpuName = QString::fromWCharArray(dd.DeviceString).trimmed();
            break;
        }
    }
    if (m_gpuName == "Unknown GPU" && EnumDisplayDevicesW(NULL, 0, &dd, 0)) {
        m_gpuName = QString::fromWCharArray(dd.DeviceString).trimmed();
    }

    // 6. Motherboard
    QString manufacturer, product;
    if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"HARDWARE\\DESCRIPTION\\System\\BIOS", 0, KEY_READ, &hKey) == ERROR_SUCCESS) {
        wchar_t val[256] = {0};
        DWORD size = sizeof(val);
        if (RegQueryValueExW(hKey, L"BaseBoardManufacturer", NULL, NULL, (LPBYTE)val, &size) == ERROR_SUCCESS) {
            manufacturer = QString::fromWCharArray(val).trimmed();
        }
        size = sizeof(val);
        memset(val, 0, sizeof(val));
        if (RegQueryValueExW(hKey, L"BaseBoardProduct", NULL, NULL, (LPBYTE)val, &size) == ERROR_SUCCESS) {
            product = QString::fromWCharArray(val).trimmed();
        }
        RegCloseKey(hKey);
    }
    if (!manufacturer.isEmpty() && !product.isEmpty()) {
        m_motherboard = manufacturer + " " + product;
    } else {
        m_motherboard = "Unknown Motherboard";
    }

    // 7. Storage
    ULARGE_INTEGER freeBytesAvailable, totalBytes, totalFreeBytes;
    if (GetDiskFreeSpaceExW(L"C:\\", &freeBytesAvailable, &totalBytes, &totalFreeBytes)) {
        double freeGB = freeBytesAvailable.QuadPart / (1024.0 * 1024.0 * 1024.0);
        double totalGB = totalBytes.QuadPart / (1024.0 * 1024.0 * 1024.0);
        m_storage = QString("%1 GB Free / %2 GB Total").arg(QString::number(freeGB, 'f', 1)).arg(QString::number(totalGB, 'f', 1));
    }
#else
    m_osName = QSysInfo::prettyProductName();
    m_cpuName = "AMD Ryzen 5 5600X 6-Core Processor";
    m_logicalCores = QString("%1 Logical Processors").arg(QThread::idealThreadCount());
    m_ramSize = "32.00 GB RAM";
    m_gpuName = "NVIDIA GeForce RTX 5070";
    m_motherboard = "ASUSTeK COMPUTER INC. TUF GAMING B550M-PLUS";
    m_storage = "120.0 GB Free / 250.0 GB Total";
#endif

    // 8. Display
    QScreen *screen = QGuiApplication::primaryScreen();
    if (screen) {
        m_display = QString("%1x%2 @ %3Hz")
                        .arg(screen->geometry().width())
                        .arg(screen->geometry().height())
                        .arg(qRound(screen->refreshRate()));
    }

    emit osNameChanged(m_osName);
    emit cpuNameChanged(m_cpuName);
    emit logicalCoresChanged(m_logicalCores);
    emit ramSizeChanged(m_ramSize);
    emit gpuNameChanged(m_gpuName);
    emit motherboardChanged(m_motherboard);
    emit storageChanged(m_storage);
    emit displayChanged(m_display);
}
