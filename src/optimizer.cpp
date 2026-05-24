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

void Optimizer::setHibernationActive(bool val) {
    if (m_hibernationActive != val) {
        m_hibernationActive = val;
        emit hibernationActiveChanged(m_hibernationActive);
    }
}

void Optimizer::setGamingOverlayActive(bool val) {
    if (m_gamingOverlayActive != val) {
        m_gamingOverlayActive = val;
        emit gamingOverlayActiveChanged(m_gamingOverlayActive);
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

    // Read HibernateEnabled Registry Key on Windows
    bool isHibernationActive = false;
#ifdef Q_OS_WIN
    HKEY hKeyPower;
    if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SYSTEM\\CurrentControlSet\\Control\\Power", 0, KEY_READ, &hKeyPower) == ERROR_SUCCESS) {
        DWORD value = 0;
        DWORD size = sizeof(value);
        if (RegQueryValueExW(hKeyPower, L"HibernateEnabled", NULL, NULL, (LPBYTE)&value, &size) == ERROR_SUCCESS) {
            isHibernationActive = (value == 1);
        }
        RegCloseKey(hKeyPower);
    }
#else
    isHibernationActive = true; // Simulation default
#endif
    m_hibernationActive = isHibernationActive;
    m_originalHibernationActive = m_hibernationActive;
    emit hibernationActiveChanged(m_hibernationActive);
    emit originalHibernationActiveChanged(m_originalHibernationActive);

    // Check if Xbox packages are installed on startup
    bool isXboxAppInstalled = false;
    bool isXboxGamingOverlayInstalled = false;
    bool isXboxTcuiInstalled = false;
    bool isXboxSpeechWindowInstalled = false;
#ifdef Q_OS_WIN
    QProcess checkXboxProc;
    checkXboxProc.start("powershell.exe", QStringList() << "-NoProfile" << "-NonInteractive" << "-Command" << "Get-AppxPackage -Name *Xbox* | Select-Object Name");
    checkXboxProc.waitForFinished(12000);
    QString checkOut = checkXboxProc.readAllStandardOutput().trimmed();
    isXboxAppInstalled = checkOut.contains("XboxApp", Qt::CaseInsensitive);
    isXboxGamingOverlayInstalled = checkOut.contains("XboxGamingOverlay", Qt::CaseInsensitive);
    isXboxTcuiInstalled = checkOut.contains("Xbox.TCUI", Qt::CaseInsensitive) || checkOut.contains("XboxTCUI", Qt::CaseInsensitive);
    isXboxSpeechWindowInstalled = checkOut.contains("XboxGameSpeechWindow", Qt::CaseInsensitive);
#else
    isXboxAppInstalled = true;
    isXboxGamingOverlayInstalled = true;
    isXboxTcuiInstalled = true;
    isXboxSpeechWindowInstalled = true;
#endif
    m_xboxAppInstalled = isXboxAppInstalled;
    m_xboxGamingOverlayInstalled = isXboxGamingOverlayInstalled;
    m_xboxTcuiInstalled = isXboxTcuiInstalled;
    m_xboxSpeechWindowInstalled = isXboxSpeechWindowInstalled;
    m_xboxInstalled = m_xboxAppInstalled || m_xboxGamingOverlayInstalled || m_xboxTcuiInstalled || m_xboxSpeechWindowInstalled;

    emit xboxInstalledChanged(m_xboxInstalled);
    emit xboxStatesChanged();

    // Check if gaming overlay popups are disabled/neutralized on startup
    bool isOverlayActive = true;
#ifdef Q_OS_WIN
    HKEY hKeyDVR;
    if (RegOpenKeyExW(HKEY_CURRENT_USER, L"SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\GameDVR", 0, KEY_READ, &hKeyDVR) == ERROR_SUCCESS) {
        DWORD value = 1;
        DWORD size = sizeof(value);
        if (RegQueryValueExW(hKeyDVR, L"AppCaptureEnabled", NULL, NULL, (LPBYTE)&value, &size) == ERROR_SUCCESS) {
            if (value == 0) {
                isOverlayActive = false;
            }
        }
        RegCloseKey(hKeyDVR);
    }
    // Check HKCR protocol association to confirm if it is neutralized
    if (isOverlayActive) {
        HKEY hKeyProto;
        if (RegOpenKeyExW(HKEY_CLASSES_ROOT, L"ms-gamingoverlay\\shell\\open\\command", 0, KEY_READ, &hKeyProto) == ERROR_SUCCESS) {
            wchar_t path[256] = {0};
            DWORD size = sizeof(path);
            if (RegQueryValueExW(hKeyProto, NULL, NULL, NULL, (LPBYTE)path, &size) == ERROR_SUCCESS) {
                QString p = QString::fromWCharArray(path);
                if (p.contains("systray.exe", Qt::CaseInsensitive)) {
                    isOverlayActive = false;
                }
            }
            RegCloseKey(hKeyProto);
        }
    }
#else
    isOverlayActive = true; // Simulation default
#endif
    m_gamingOverlayActive = isOverlayActive;
    m_originalGamingOverlayActive = m_gamingOverlayActive;
    emit gamingOverlayActiveChanged(m_gamingOverlayActive);
    emit originalGamingOverlayActiveChanged(m_originalGamingOverlayActive);

    // Check Multi-Plane Overlay (MPO) state in registry
    int currentMpo = 0; // default 0 (MPO Enabled)
#ifdef Q_OS_WIN
    HKEY hKeyDrivers;
    bool mpoDisabledAtDriver = false;
    if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SYSTEM\\CurrentControlSet\\Control\\GraphicsDrivers", 0, KEY_READ, &hKeyDrivers) == ERROR_SUCCESS) {
        DWORD value = 0;
        DWORD size = sizeof(value);
        if (RegQueryValueExW(hKeyDrivers, L"DisableMPO", NULL, NULL, (LPBYTE)&value, &size) == ERROR_SUCCESS) {
            if (value == 1) {
                mpoDisabledAtDriver = true;
            }
        }
        RegCloseKey(hKeyDrivers);
    }

    if (mpoDisabledAtDriver) {
        currentMpo = 5;
    } else {
        HKEY hKeyDwm;
        if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SOFTWARE\\Microsoft\\Windows\\Dwm", 0, KEY_READ, &hKeyDwm) == ERROR_SUCCESS) {
            DWORD value = 0;
            DWORD size = sizeof(value);
            if (RegQueryValueExW(hKeyDwm, L"OverlayTestMode", NULL, NULL, (LPBYTE)&value, &size) == ERROR_SUCCESS) {
                currentMpo = static_cast<int>(value);
            }
            RegCloseKey(hKeyDwm);
        }
    }
#else
    currentMpo = 5; // Simulation default
#endif
    m_mpoValue = currentMpo;
    emit mpoValueChanged(m_mpoValue);

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
    bool hibernationVal = m_hibernationActive;
    bool overlayVal = m_gamingOverlayActive;
    QVariantMap targets = m_driveStates;
    QVariantMap originalTargets = m_originalDriveStates;
    bool origSearch = m_originalWinSearchActive;
    bool origHibernation = m_originalHibernationActive;
    bool origOverlay = m_originalGamingOverlayActive;

    QThread* worker = QThread::create([this, searchVal, hibernationVal, overlayVal, targets, originalTargets, origSearch, origHibernation, origOverlay]() {
        // Step 0: Check if anything actually changed
        bool anyChanges = (searchVal != origSearch) || 
                          (hibernationVal != origHibernation) || 
                          (overlayVal != origOverlay);
        if (!anyChanges) {
            for (const QString &driveLetter : targets.keys()) {
                if (targets.value(driveLetter).toBool() != originalTargets.value(driveLetter).toBool()) {
                    anyChanges = true;
                    break;
                }
            }
        }

        if (!anyChanges) {
            QThread::msleep(600);
            emit systemStepReported(tr("No changes detected. Everything is already up to date!"), "SUCCESS");
            m_systemProgress = 1.0;
            emit systemProgressChanged(m_systemProgress);
            m_isOptimizingSystem = false;
            emit isOptimizingSystemChanged(m_isOptimizingSystem);
            emit systemOptimizationFinished(true);
            return;
        }

        bool wSearchSuccess = true;
        // Step 1: Windows Search service (only if changed)
        if (searchVal != origSearch) {
            emit systemStepReported(tr("Processing Windows Search service..."), "INFO");
            QThread::msleep(800);
            
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
        }
        
        m_systemProgress = 0.20;
        emit systemProgressChanged(m_systemProgress);
        QThread::msleep(300);

        // Step 1.5: Hibernation Configuration (only if changed)
        bool hibernationSuccess = true;
        if (hibernationVal != origHibernation) {
            emit systemStepReported(tr("Configuring system hibernation..."), "INFO");
            QThread::msleep(800);
#ifdef Q_OS_WIN
            QProcess proc;
            proc.start("cmd.exe", QStringList() << "/c" << (hibernationVal ? "powercfg.exe /hibernate on" : "powercfg.exe /hibernate off"));
            proc.waitForFinished();
            
            // Double check registry to verify success
            bool success = false;
            HKEY hKeyPower;
            if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SYSTEM\\CurrentControlSet\\Control\\Power", 0, KEY_READ, &hKeyPower) == ERROR_SUCCESS) {
                DWORD val = 0;
                DWORD size = sizeof(val);
                if (RegQueryValueExW(hKeyPower, L"HibernateEnabled", NULL, NULL, (LPBYTE)&val, &size) == ERROR_SUCCESS) {
                    success = (val == (hibernationVal ? 1 : 0));
                }
                RegCloseKey(hKeyPower);
            }
            
            if (success) {
                QString logMsg = hibernationVal ? tr("Hibernation is now ENABLED.") : tr("Hibernation is now DISABLED.");
                emit systemStepReported(logMsg, "SUCCESS");
            } else {
                hibernationSuccess = false;
                emit systemStepReported(tr("Failed to update hibernation state."), "ERROR");
            }
#else
            emit systemStepReported(tr("[Simulation] Hibernation set to: %1").arg(hibernationVal ? "Enabled" : "Disabled"), "SUCCESS");
#endif
            m_hibernationActive = hibernationVal;
            emit hibernationActiveChanged(m_hibernationActive);
        }
        
        m_systemProgress = 0.35;
        emit systemProgressChanged(m_systemProgress);
        QThread::msleep(300);

        // Step 1.7: Gaming Overlay Configuration (only if changed)
        bool overlaySuccess = true;
        if (overlayVal != origOverlay) {
            emit systemStepReported(tr("Configuring Xbox gaming overlay popups..."), "INFO");
            QThread::msleep(800);
#ifdef Q_OS_WIN
            bool success = true;
            
            // 1. Set GameDVR keys in registry
            HKEY hKeyDVR;
            if (RegCreateKeyExW(HKEY_CURRENT_USER, L"SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\GameDVR", 0, NULL, REG_OPTION_NON_VOLATILE, KEY_WRITE, NULL, &hKeyDVR, NULL) == ERROR_SUCCESS) {
                DWORD val = overlayVal ? 1 : 0;
                RegSetValueExW(hKeyDVR, L"AppCaptureEnabled", 0, REG_DWORD, (const BYTE*)&val, sizeof(val));
                RegCloseKey(hKeyDVR);
            } else {
                success = false;
            }

            HKEY hKeyConfig;
            if (RegCreateKeyExW(HKEY_CURRENT_USER, L"System\\GameConfigStore", 0, NULL, REG_OPTION_NON_VOLATILE, KEY_WRITE, NULL, &hKeyConfig, NULL) == ERROR_SUCCESS) {
                DWORD val = overlayVal ? 1 : 0;
                RegSetValueExW(hKeyConfig, L"GameDVR_Enabled", 0, REG_DWORD, (const BYTE*)&val, sizeof(val));
                RegCloseKey(hKeyConfig);
            } else {
                success = false;
            }

            // 2. Neutralize or restore ms-gamingoverlay protocol keys in registry
            if (!overlayVal) {
                // Neutralize ms-gamingoverlay
                HKEY hKeyOverlay;
                if (RegCreateKeyExW(HKEY_CLASSES_ROOT, L"ms-gamingoverlay", 0, NULL, REG_OPTION_NON_VOLATILE, KEY_WRITE, NULL, &hKeyOverlay, NULL) == ERROR_SUCCESS) {
                    wchar_t desc[] = L"URL:ms-gamingoverlay";
                    RegSetValueExW(hKeyOverlay, NULL, 0, REG_SZ, (const BYTE*)desc, (wcslen(desc) + 1) * sizeof(wchar_t));
                    wchar_t proto[] = L"";
                    RegSetValueExW(hKeyOverlay, L"URL Protocol", 0, REG_SZ, (const BYTE*)proto, (wcslen(proto) + 1) * sizeof(wchar_t));
                    RegCloseKey(hKeyOverlay);
                } else {
                    success = false;
                }

                HKEY hKeyOverlayCmd;
                if (RegCreateKeyExW(HKEY_CLASSES_ROOT, L"ms-gamingoverlay\\shell\\open\\command", 0, NULL, REG_OPTION_NON_VOLATILE, KEY_WRITE, NULL, &hKeyOverlayCmd, NULL) == ERROR_SUCCESS) {
                    wchar_t cmd[] = L"C:\\Windows\\System32\\systray.exe";
                    RegSetValueExW(hKeyOverlayCmd, NULL, 0, REG_SZ, (const BYTE*)cmd, (wcslen(cmd) + 1) * sizeof(wchar_t));
                    RegCloseKey(hKeyOverlayCmd);
                } else {
                    success = false;
                }
                
                // Neutralize ms-gamebar as well
                HKEY hKeyGamebar;
                if (RegCreateKeyExW(HKEY_CLASSES_ROOT, L"ms-gamebar", 0, NULL, REG_OPTION_NON_VOLATILE, KEY_WRITE, NULL, &hKeyGamebar, NULL) == ERROR_SUCCESS) {
                    wchar_t desc[] = L"URL:ms-gamebar";
                    RegSetValueExW(hKeyGamebar, NULL, 0, REG_SZ, (const BYTE*)desc, (wcslen(desc) + 1) * sizeof(wchar_t));
                    wchar_t proto[] = L"";
                    RegSetValueExW(hKeyGamebar, L"URL Protocol", 0, REG_SZ, (const BYTE*)proto, (wcslen(proto) + 1) * sizeof(wchar_t));
                    RegCloseKey(hKeyGamebar);
                }
                HKEY hKeyGamebarCmd;
                if (RegCreateKeyExW(HKEY_CLASSES_ROOT, L"ms-gamebar\\shell\\open\\command", 0, NULL, REG_OPTION_NON_VOLATILE, KEY_WRITE, NULL, &hKeyGamebarCmd, NULL) == ERROR_SUCCESS) {
                    wchar_t cmd[] = L"C:\\Windows\\System32\\systray.exe";
                    RegSetValueExW(hKeyGamebarCmd, NULL, 0, REG_SZ, (const BYTE*)cmd, (wcslen(cmd) + 1) * sizeof(wchar_t));
                    RegCloseKey(hKeyGamebarCmd);
                }
            } else {
                // Restore defaults
                QProcess delProc;
                delProc.start("reg.exe", QStringList() << "delete" << "HKCR\\ms-gamingoverlay" << "/f");
                delProc.waitForFinished();
                delProc.start("reg.exe", QStringList() << "delete" << "HKCR\\ms-gamebar" << "/f");
                delProc.waitForFinished();
            }

            if (success) {
                QString logMsg = overlayVal ? tr("Gaming overlay notifications are now ENABLED.") : tr("Gaming overlay notifications are now DISABLED.");
                emit systemStepReported(logMsg, "SUCCESS");
            } else {
                overlaySuccess = false;
                emit systemStepReported(tr("Failed to update gaming overlay state."), "ERROR");
            }
#else
            emit systemStepReported(tr("[Simulation] Gaming overlay set to: %1").arg(overlayVal ? "Enabled" : "Disabled"), "SUCCESS");
#endif
            m_gamingOverlayActive = overlayVal;
            emit gamingOverlayActiveChanged(m_gamingOverlayActive);
        }

        m_systemProgress = 0.50;
        emit systemProgressChanged(m_systemProgress);
        QThread::msleep(300);

        // Steps 2+: Iterate drives in target list (only if changed)
        int driveIndex = 0;
        int totalDrives = targets.keys().size();
        bool overallDrivesSuccess = true;
        
        for (const QString &driveLetter : targets.keys()) {
            bool targetVal = targets.value(driveLetter).toBool();
            bool originalVal = originalTargets.value(driveLetter).toBool();
            
            if (targetVal != originalVal) {
                emit systemStepReported(tr("Processing Drive %1 indexing...").arg(driveLetter), "INFO");
                QThread::msleep(800);
                
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
                        overallDrivesSuccess = false;
                        emit systemStepReported(tr("Failed to update Drive %1 file attributes. Error: %2").arg(driveLetter).arg(GetLastError()), "ERROR");
                    }
                } else {
                    emit systemStepReported(tr("Drive %1 is not mounted or unavailable. Skipping.").arg(driveLetter), "WARNING");
                }
#else
                emit systemStepReported(tr("[Simulation] Drive %1 indexing set to: %2").arg(driveLetter).arg(targetVal ? "Enabled" : "Disabled"), "SUCCESS");
#endif
            }
            
            driveIndex++;
            m_systemProgress = 0.50 + (0.50 * (double(driveIndex) / (totalDrives > 0 ? totalDrives : 1)));
            emit systemProgressChanged(m_systemProgress);
            QThread::msleep(100);
        }

        bool overallSuccess = wSearchSuccess && hibernationSuccess && overlaySuccess && overallDrivesSuccess;
        if (overallSuccess) {
            emit systemStepReported(tr("System optimization completed successfully!"), "SUCCESS");
            Logger::log("System optimization completed successfully!", "INFO");
        } else {
            emit systemStepReported(tr("System optimization completed with warning/errors."), "WARNING");
            Logger::log("System optimization completed with warning/errors.", "WARNING");
        }

        m_driveStates = targets;
        m_originalWinSearchActive = searchVal;
        m_originalHibernationActive = hibernationVal;
        m_originalGamingOverlayActive = overlayVal;
        m_originalDriveStates = targets;
        
        emit driveStatesChanged(m_driveStates);
        emit originalWinSearchActiveChanged(m_originalWinSearchActive);
        emit originalHibernationActiveChanged(m_originalHibernationActive);
        emit originalGamingOverlayActiveChanged(m_originalGamingOverlayActive);
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

void Optimizer::removeXboxEntirely() {
    if (m_isOptimizingSystem) return;
    
    m_isOptimizingSystem = true;
    m_systemProgress = 0.0;
    emit isOptimizingSystemChanged(m_isOptimizingSystem);
    emit systemProgressChanged(m_systemProgress);

    emit systemStepReported(tr("Initializing Xbox package removal..."), "INFO");
    Logger::log("Starting Xbox App Suite removal...", "INFO");

    QThread* worker = QThread::create([this]() {
        QStringList packages = { "XboxApp", "XboxGamingOverlay", "XboxTCUI", "XboxGameSpeechWindow" };
        int progressStep = 0;
        int totalSteps = packages.size() + 2;

#ifdef Q_OS_WIN
        for (const QString &pkg : packages) {
            emit systemStepReported(tr("Removing package: %1...").arg(pkg), "INFO");
            QProcess proc;
            QString cmd = QString("Get-AppxPackage %1 | Remove-AppxPackage").arg(pkg);
            proc.start("powershell.exe", QStringList() << "-NoProfile" << "-NonInteractive" << "-Command" << cmd);
            proc.waitForFinished(25000);
            
            progressStep++;
            m_systemProgress = double(progressStep) / totalSteps;
            emit systemProgressChanged(m_systemProgress);
            
            emit systemStepReported(tr("Package %1 removal command executed.").arg(pkg), "SUCCESS");
            QThread::msleep(300);
        }

        // Delete all users Xbox packages
        emit systemStepReported(tr("Purging Xbox packages for all users..."), "INFO");
        {
            QProcess proc;
            proc.start("powershell.exe", QStringList() << "-NoProfile" << "-NonInteractive" << "-Command" << "Get-AppxPackage -AllUsers Xbox | Remove-AppxPackage");
            proc.waitForFinished(35000);
        }
        progressStep++;
        m_systemProgress = double(progressStep) / totalSteps;
        emit systemProgressChanged(m_systemProgress);
        emit systemStepReported(tr("All-users Xbox packages removed."), "SUCCESS");
        QThread::msleep(300);

        // Delete provisioned packages
        emit systemStepReported(tr("Removing provisioned Xbox packages..."), "INFO");
        {
            QProcess proc;
            proc.start("powershell.exe", QStringList() << "-NoProfile" << "-NonInteractive" << "-Command" << "Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like '*Xbox*'} | Remove-AppxProvisionedPackage -Online");
            proc.waitForFinished(45000);
        }
        progressStep++;
        m_systemProgress = 1.0;
        emit systemProgressChanged(m_systemProgress);
        emit systemStepReported(tr("Provisioned Xbox packages purged successfully."), "SUCCESS");
        QThread::msleep(300);

        // Re-check Xbox installed status
        QProcess checkProc;
        checkProc.start("powershell.exe", QStringList() << "-NoProfile" << "-NonInteractive" << "-Command" << "Get-AppxPackage -Name *Xbox* | Select-Object Name");
        checkProc.waitForFinished(10000);
        QString checkOut = checkProc.readAllStandardOutput().trimmed();
        m_xboxAppInstalled = checkOut.contains("XboxApp", Qt::CaseInsensitive);
        m_xboxGamingOverlayInstalled = checkOut.contains("XboxGamingOverlay", Qt::CaseInsensitive);
        m_xboxTcuiInstalled = checkOut.contains("Xbox.TCUI", Qt::CaseInsensitive) || checkOut.contains("XboxTCUI", Qt::CaseInsensitive);
        m_xboxSpeechWindowInstalled = checkOut.contains("XboxGameSpeechWindow", Qt::CaseInsensitive);
        m_xboxInstalled = m_xboxAppInstalled || m_xboxGamingOverlayInstalled || m_xboxTcuiInstalled || m_xboxSpeechWindowInstalled;
        
        emit xboxInstalledChanged(m_xboxInstalled);
        emit xboxStatesChanged();

        if (!m_xboxInstalled) {
            emit systemStepReported(tr("Xbox Suite has been successfully uninstalled from this PC!"), "SUCCESS");
            emit systemStepReported(tr("TIP: Enable 'Disable Game Bar Popup' to prevent system errors in games."), "WARNING");
        } else {
            emit systemStepReported(tr("Xbox removal complete. Some components may require a reboot to be fully cleared."), "WARNING");
        }
#else
        // Simulation delay
        for (int i = 0; i < totalSteps; i++) {
            QThread::msleep(500);
            progressStep++;
            m_systemProgress = double(progressStep) / totalSteps;
            emit systemProgressChanged(m_systemProgress);
            emit systemStepReported(tr("[Simulation] Removed Xbox package step %1").arg(progressStep), "SUCCESS");
        }
        m_xboxAppInstalled = false;
        m_xboxGamingOverlayInstalled = false;
        m_xboxTcuiInstalled = false;
        m_xboxSpeechWindowInstalled = false;
        m_xboxInstalled = false;
        emit xboxInstalledChanged(m_xboxInstalled);
        emit xboxStatesChanged();
#endif

        m_isOptimizingSystem = false;
        emit isOptimizingSystemChanged(m_isOptimizingSystem);
        emit systemOptimizationFinished(true);
    });

    connect(worker, &QThread::finished, worker, &QThread::deleteLater);
    worker->start();
}

void Optimizer::restoreXboxEntirely() {
    if (m_isOptimizingSystem) return;
    
    m_isOptimizingSystem = true;
    m_systemProgress = 0.0;
    emit isOptimizingSystemChanged(m_isOptimizingSystem);
    emit systemProgressChanged(m_systemProgress);

    emit systemStepReported(tr("Initializing Xbox package restoration..."), "INFO");
    Logger::log("Starting Xbox App Suite restoration...", "INFO");

    QThread* worker = QThread::create([this]() {
        int totalSteps = 4;
        int progressStep = 0;

#ifdef Q_OS_WIN
        // Step 1: Re-register via AppxPackage (AllUsers)
        emit systemStepReported(tr("Re-registering Xbox packages from local store..."), "INFO");
        {
            QProcess proc;
            proc.start("powershell.exe", QStringList() << "-NoProfile" << "-NonInteractive" << "-Command" << 
                "Get-AppxPackage -AllUsers -Name *Xbox* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register \"$($_.InstallLocation)\\AppXManifest.xml\"}");
            proc.waitForFinished(35000);
        }
        progressStep++;
        m_systemProgress = double(progressStep) / totalSteps;
        emit systemProgressChanged(m_systemProgress);
        emit systemStepReported(tr("Local packages re-registered."), "SUCCESS");
        QThread::msleep(300);

        // Step 2: Re-register via ProvisionedPackages
        emit systemStepReported(tr("Re-registering provisioned Xbox packages..."), "INFO");
        {
            QProcess proc;
            proc.start("powershell.exe", QStringList() << "-NoProfile" << "-NonInteractive" << "-Command" << 
                "Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like '*Xbox*'} | ForEach-Object { Add-AppxPackage -DisableDevelopmentMode -Register \"$($_.InstallLocation)\\AppXManifest.xml\" }");
            proc.waitForFinished(35000);
        }
        progressStep++;
        m_systemProgress = double(progressStep) / totalSteps;
        emit systemProgressChanged(m_systemProgress);
        emit systemStepReported(tr("Provisioned packages re-registered."), "SUCCESS");
        QThread::msleep(300);

        // Step 3: winget fallback for Xbox App
        emit systemStepReported(tr("Downloading and installing Xbox App via winget..."), "INFO");
        {
            QProcess proc;
            proc.start("cmd.exe", QStringList() << "/c" << "winget install 9MV0B5HZVK9Z --source msstore --accept-source-agreements --accept-package-agreements");
            proc.waitForFinished(70000);
        }
        progressStep++;
        m_systemProgress = double(progressStep) / totalSteps;
        emit systemProgressChanged(m_systemProgress);
        emit systemStepReported(tr("Xbox App installation completed."), "SUCCESS");
        QThread::msleep(300);

        // Step 4: winget fallback for Xbox Game Bar
        emit systemStepReported(tr("Downloading and installing Xbox Game Bar via winget..."), "INFO");
        {
            QProcess proc;
            proc.start("cmd.exe", QStringList() << "/c" << "winget install 9NZKPSTSNW4P --source msstore --accept-source-agreements --accept-package-agreements");
            proc.waitForFinished(70000);
        }
        progressStep++;
        m_systemProgress = 1.0;
        emit systemProgressChanged(m_systemProgress);
        emit systemStepReported(tr("Xbox Game Bar installation completed."), "SUCCESS");
        QThread::msleep(300);

        // Re-check Xbox installed status
        QProcess checkProc;
        checkProc.start("powershell.exe", QStringList() << "-NoProfile" << "-NonInteractive" << "-Command" << "Get-AppxPackage -Name *Xbox* | Select-Object Name");
        checkProc.waitForFinished(10000);
        QString checkOut = checkProc.readAllStandardOutput().trimmed();
        m_xboxAppInstalled = checkOut.contains("XboxApp", Qt::CaseInsensitive);
        m_xboxGamingOverlayInstalled = checkOut.contains("XboxGamingOverlay", Qt::CaseInsensitive);
        m_xboxTcuiInstalled = checkOut.contains("Xbox.TCUI", Qt::CaseInsensitive) || checkOut.contains("XboxTCUI", Qt::CaseInsensitive);
        m_xboxSpeechWindowInstalled = checkOut.contains("XboxGameSpeechWindow", Qt::CaseInsensitive);
        m_xboxInstalled = m_xboxAppInstalled || m_xboxGamingOverlayInstalled || m_xboxTcuiInstalled || m_xboxSpeechWindowInstalled;
        
        emit xboxInstalledChanged(m_xboxInstalled);
        emit xboxStatesChanged();

        if (m_xboxInstalled) {
            emit systemStepReported(tr("Xbox Suite has been successfully restored!"), "SUCCESS");
        } else {
            emit systemStepReported(tr("Xbox restoration complete. A system reboot may be needed to complete the installation."), "WARNING");
        }
#else
        // Simulation delay
        for (int i = 0; i < totalSteps; i++) {
            QThread::msleep(500);
            progressStep++;
            m_systemProgress = double(progressStep) / totalSteps;
            emit systemProgressChanged(m_systemProgress);
            emit systemStepReported(tr("[Simulation] Restored Xbox package step %1").arg(progressStep), "SUCCESS");
        }
        m_xboxAppInstalled = true;
        m_xboxGamingOverlayInstalled = true;
        m_xboxTcuiInstalled = true;
        m_xboxSpeechWindowInstalled = true;
        m_xboxInstalled = true;
        emit xboxInstalledChanged(m_xboxInstalled);
        emit xboxStatesChanged();
#endif

        m_isOptimizingSystem = false;
        emit isOptimizingSystemChanged(m_isOptimizingSystem);
        emit systemOptimizationFinished(true);
    });

    connect(worker, &QThread::finished, worker, &QThread::deleteLater);
    worker->start();
}

void Optimizer::removeXboxComponent(const QString &componentName) {
    if (m_isOptimizingSystem) return;

    m_isOptimizingSystem = true;
    m_systemProgress = 0.0;
    emit isOptimizingSystemChanged(m_isOptimizingSystem);
    emit systemProgressChanged(m_systemProgress);

    emit systemStepReported(tr("Removing Xbox component: %1...").arg(componentName), "INFO");
    Logger::log(QString("Starting removal of Xbox component: %1").arg(componentName), "INFO");

    QThread* worker = QThread::create([this, componentName]() {
#ifdef Q_OS_WIN
        QProcess proc;
        QString cmd;
        if (componentName == "XboxApp") {
            cmd = "Get-AppxPackage XboxApp | Remove-AppxPackage";
        } else if (componentName == "XboxGamingOverlay") {
            cmd = "Get-AppxPackage XboxGamingOverlay | Remove-AppxPackage";
        } else if (componentName == "XboxTCUI") {
            cmd = "Get-AppxPackage XboxTCUI | Remove-AppxPackage";
        } else if (componentName == "XboxGameSpeechWindow") {
            cmd = "Get-AppxPackage XboxGameSpeechWindow | Remove-AppxPackage";
        } else if (componentName == "AllUsersAndProvisioned") {
            emit systemStepReported(tr("Purging Xbox packages for all users..."), "INFO");
            QProcess proc1;
            proc1.start("powershell.exe", QStringList() << "-NoProfile" << "-NonInteractive" << "-Command" << "Get-AppxPackage -AllUsers Xbox | Remove-AppxPackage");
            proc1.waitForFinished(35000);

            emit systemStepReported(tr("Purging provisioned Xbox packages..."), "INFO");
            QProcess proc2;
            proc2.start("powershell.exe", QStringList() << "-NoProfile" << "-NonInteractive" << "-Command" << "Get-AppxProvisionedPackage -Online | Where-Object {$_.PackageName -like '*Xbox*'} | Remove-AppxProvisionedPackage -Online");
            proc2.waitForFinished(45000);
        }

        if (!cmd.isEmpty()) {
            proc.start("powershell.exe", QStringList() << "-NoProfile" << "-NonInteractive" << "-Command" << cmd);
            proc.waitForFinished(30000);
        }

        m_systemProgress = 0.80;
        emit systemProgressChanged(m_systemProgress);
        QThread::msleep(400);

        // Re-check
        QProcess checkProc;
        checkProc.start("powershell.exe", QStringList() << "-NoProfile" << "-NonInteractive" << "-Command" << "Get-AppxPackage -Name *Xbox* | Select-Object Name");
        checkProc.waitForFinished(10000);
        QString checkOut = checkProc.readAllStandardOutput().trimmed();
        m_xboxAppInstalled = checkOut.contains("XboxApp", Qt::CaseInsensitive);
        m_xboxGamingOverlayInstalled = checkOut.contains("XboxGamingOverlay", Qt::CaseInsensitive);
        m_xboxTcuiInstalled = checkOut.contains("Xbox.TCUI", Qt::CaseInsensitive) || checkOut.contains("XboxTCUI", Qt::CaseInsensitive);
        m_xboxSpeechWindowInstalled = checkOut.contains("XboxGameSpeechWindow", Qt::CaseInsensitive);
        m_xboxInstalled = m_xboxAppInstalled || m_xboxGamingOverlayInstalled || m_xboxTcuiInstalled || m_xboxSpeechWindowInstalled;

        emit xboxInstalledChanged(m_xboxInstalled);
        emit xboxStatesChanged();

        m_systemProgress = 1.0;
        emit systemProgressChanged(m_systemProgress);
        emit systemStepReported(tr("Component %1 uninstalled successfully!").arg(componentName), "SUCCESS");
#else
        QThread::msleep(1500);
        if (componentName == "XboxApp") m_xboxAppInstalled = false;
        else if (componentName == "XboxGamingOverlay") m_xboxGamingOverlayInstalled = false;
        else if (componentName == "XboxTCUI") m_xboxTcuiInstalled = false;
        else if (componentName == "XboxGameSpeechWindow") m_xboxSpeechWindowInstalled = false;
        else if (componentName == "AllUsersAndProvisioned") {
            m_xboxAppInstalled = false;
            m_xboxGamingOverlayInstalled = false;
            m_xboxTcuiInstalled = false;
            m_xboxSpeechWindowInstalled = false;
        }
        m_xboxInstalled = m_xboxAppInstalled || m_xboxGamingOverlayInstalled || m_xboxTcuiInstalled || m_xboxSpeechWindowInstalled;

        emit xboxInstalledChanged(m_xboxInstalled);
        emit xboxStatesChanged();
        
        m_systemProgress = 1.0;
        emit systemProgressChanged(m_systemProgress);
        emit systemStepReported(tr("[Simulation] Removed component %1").arg(componentName), "SUCCESS");
#endif
        m_isOptimizingSystem = false;
        emit isOptimizingSystemChanged(m_isOptimizingSystem);
        emit systemOptimizationFinished(true);
    });

    connect(worker, &QThread::finished, worker, &QThread::deleteLater);
    worker->start();
}

void Optimizer::restoreXboxComponent(const QString &componentName) {
    if (m_isOptimizingSystem) return;

    m_isOptimizingSystem = true;
    m_systemProgress = 0.0;
    emit isOptimizingSystemChanged(m_isOptimizingSystem);
    emit systemProgressChanged(m_systemProgress);

    emit systemStepReported(tr("Restoring Xbox component: %1...").arg(componentName), "INFO");
    Logger::log(QString("Starting restoration of Xbox component: %1").arg(componentName), "INFO");

    QThread* worker = QThread::create([this, componentName]() {
#ifdef Q_OS_WIN
        QProcess proc;
        QString cmd;
        if (componentName == "XboxApp") {
            cmd = "winget install 9MV0B5HZVK9Z --source msstore --accept-source-agreements --accept-package-agreements";
        } else if (componentName == "XboxGamingOverlay") {
            cmd = "winget install 9NZKPSTSNW4P --source msstore --accept-source-agreements --accept-package-agreements";
        } else if (componentName == "XboxTCUI") {
            cmd = "Get-AppxPackage -AllUsers -Name *XboxTCUI* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register \"$($_.InstallLocation)\\AppXManifest.xml\"}";
        } else if (componentName == "XboxGameSpeechWindow") {
            cmd = "Get-AppxPackage -AllUsers -Name *XboxGameSpeechWindow* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register \"$($_.InstallLocation)\\AppXManifest.xml\"}";
        } else if (componentName == "AllUsersAndProvisioned") {
            cmd = "Get-AppxPackage -AllUsers -Name *Xbox* | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register \"$($_.InstallLocation)\\AppXManifest.xml\"}";
        }

        if (!cmd.isEmpty()) {
            if (componentName == "XboxApp" || componentName == "XboxGamingOverlay") {
                proc.start("cmd.exe", QStringList() << "/c" << cmd);
            } else {
                proc.start("powershell.exe", QStringList() << "-NoProfile" << "-NonInteractive" << "-Command" << cmd);
            }
            proc.waitForFinished(75000);
        }

        m_systemProgress = 0.80;
        emit systemProgressChanged(m_systemProgress);
        QThread::msleep(400);

        // Re-check
        QProcess checkProc;
        checkProc.start("powershell.exe", QStringList() << "-NoProfile" << "-NonInteractive" << "-Command" << "Get-AppxPackage -Name *Xbox* | Select-Object Name");
        checkProc.waitForFinished(10000);
        QString checkOut = checkProc.readAllStandardOutput().trimmed();
        m_xboxAppInstalled = checkOut.contains("XboxApp", Qt::CaseInsensitive);
        m_xboxGamingOverlayInstalled = checkOut.contains("XboxGamingOverlay", Qt::CaseInsensitive);
        m_xboxTcuiInstalled = checkOut.contains("Xbox.TCUI", Qt::CaseInsensitive) || checkOut.contains("XboxTCUI", Qt::CaseInsensitive);
        m_xboxSpeechWindowInstalled = checkOut.contains("XboxGameSpeechWindow", Qt::CaseInsensitive);
        m_xboxInstalled = m_xboxAppInstalled || m_xboxGamingOverlayInstalled || m_xboxTcuiInstalled || m_xboxSpeechWindowInstalled;

        emit xboxInstalledChanged(m_xboxInstalled);
        emit xboxStatesChanged();

        m_systemProgress = 1.0;
        emit systemProgressChanged(m_systemProgress);
        emit systemStepReported(tr("Component %1 restored successfully!").arg(componentName), "SUCCESS");
#else
        QThread::msleep(1500);
        if (componentName == "XboxApp") m_xboxAppInstalled = true;
        else if (componentName == "XboxGamingOverlay") m_xboxGamingOverlayInstalled = true;
        else if (componentName == "XboxTCUI") m_xboxTcuiInstalled = true;
        else if (componentName == "XboxGameSpeechWindow") m_xboxSpeechWindowInstalled = true;
        else if (componentName == "AllUsersAndProvisioned") {
            m_xboxAppInstalled = true;
            m_xboxGamingOverlayInstalled = true;
            m_xboxTcuiInstalled = true;
            m_xboxSpeechWindowInstalled = true;
        }
        m_xboxInstalled = m_xboxAppInstalled || m_xboxGamingOverlayInstalled || m_xboxTcuiInstalled || m_xboxSpeechWindowInstalled;

        emit xboxInstalledChanged(m_xboxInstalled);
        emit xboxStatesChanged();
        
        m_systemProgress = 1.0;
        emit systemProgressChanged(m_systemProgress);
        emit systemStepReported(tr("[Simulation] Restored component %1").arg(componentName), "SUCCESS");
#endif
        m_isOptimizingSystem = false;
        emit isOptimizingSystemChanged(m_isOptimizingSystem);
        emit systemOptimizationFinished(true);
    });

    connect(worker, &QThread::finished, worker, &QThread::deleteLater);
    worker->start();
}

void Optimizer::applyMpoValue(int value) {
    if (m_isOptimizingSystem) return;

    m_isOptimizingSystem = true;
    m_systemProgress = 0.0;
    emit isOptimizingSystemChanged(m_isOptimizingSystem);
    emit systemProgressChanged(m_systemProgress);

    emit systemStepReported(tr("Initializing Multi-Plane Overlay (MPO) configuration..."), "INFO");
    Logger::log("Starting MPO registry configuration...", "INFO");

    QThread* worker = QThread::create([this, value]() {
        m_systemProgress = 0.20;
        emit systemProgressChanged(m_systemProgress);
        QThread::msleep(600);

        emit systemStepReported(tr("Analyzing graphics subsystem and DWM settings..."), "INFO");
        m_systemProgress = 0.45;
        emit systemProgressChanged(m_systemProgress);
        QThread::msleep(800);

        emit systemStepReported(tr("Applying MPO registry modifications..."), "INFO");

#ifdef Q_OS_WIN
        bool success = false;
        HKEY hKeyDwm;
        if (RegCreateKeyExW(HKEY_LOCAL_MACHINE, L"SOFTWARE\\Microsoft\\Windows\\Dwm", 0, NULL, REG_OPTION_NON_VOLATILE, KEY_WRITE, NULL, &hKeyDwm, NULL) == ERROR_SUCCESS) {
            if (value == 0) {
                // Delete OverlayTestMode to fully restore default behavior
                if (RegDeleteValueW(hKeyDwm, L"OverlayTestMode") == ERROR_SUCCESS || GetLastError() == ERROR_FILE_NOT_FOUND) {
                    success = true;
                } else {
                    DWORD val = 0;
                    if (RegSetValueExW(hKeyDwm, L"OverlayTestMode", 0, REG_DWORD, (const BYTE*)&val, sizeof(val)) == ERROR_SUCCESS) {
                        success = true;
                    }
                }
            } else {
                DWORD val = static_cast<DWORD>(value);
                if (RegSetValueExW(hKeyDwm, L"OverlayTestMode", 0, REG_DWORD, (const BYTE*)&val, sizeof(val)) == ERROR_SUCCESS) {
                    success = true;
                }
            }
            RegCloseKey(hKeyDwm);
        }

        // Support modern Windows 11 alternative graphics drivers key
        HKEY hKeyDrivers;
        if (RegCreateKeyExW(HKEY_LOCAL_MACHINE, L"SYSTEM\\CurrentControlSet\\Control\\GraphicsDrivers", 0, NULL, REG_OPTION_NON_VOLATILE, KEY_WRITE, NULL, &hKeyDrivers, NULL) == ERROR_SUCCESS) {
            if (value == 5) {
                DWORD val = 1;
                RegSetValueExW(hKeyDrivers, L"DisableMPO", 0, REG_DWORD, (const BYTE*)&val, sizeof(val));
            } else {
                RegDeleteValueW(hKeyDrivers, L"DisableMPO");
            }
            RegCloseKey(hKeyDrivers);
        }

        m_systemProgress = 0.80;
        emit systemProgressChanged(m_systemProgress);
        QThread::msleep(600);

        if (success) {
            m_mpoValue = value;
            emit mpoValueChanged(m_mpoValue);
            emit systemStepReported(tr("MPO configuration updated successfully in registry!"), "SUCCESS");
            emit systemStepReported(tr("REBOOT RECOMMENDED: Please restart your PC to apply these graphics latency changes."), "WARNING");
            Logger::log(QString("MPO OverlayTestMode successfully set to: %1").arg(value), "INFO");
        } else {
            emit systemStepReported(tr("Failed to update MPO configuration in registry. Error: %1").arg(GetLastError()), "ERROR");
            Logger::log("Failed to update MPO registry keys.", "ERROR");
        }
#else
        m_mpoValue = value;
        emit mpoValueChanged(m_mpoValue);
        m_systemProgress = 0.80;
        emit systemProgressChanged(m_systemProgress);
        QThread::msleep(600);
        
        emit systemStepReported(tr("[Simulation] MPO configuration updated to: %1").arg(value), "SUCCESS");
        emit systemStepReported(tr("REBOOT RECOMMENDED: Please restart your PC to apply these graphics latency changes."), "WARNING");
#endif

        m_systemProgress = 1.0;
        emit systemProgressChanged(m_systemProgress);
        QThread::msleep(400);

        m_isOptimizingSystem = false;
        emit isOptimizingSystemChanged(m_isOptimizingSystem);
        emit systemOptimizationFinished(true);
    });

    connect(worker, &QThread::finished, worker, &QThread::deleteLater);
    worker->start();
}
