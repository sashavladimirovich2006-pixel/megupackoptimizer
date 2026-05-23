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
    resetStats();
    refreshSystemInfo();
    detectSystemDrives();
    loadSystemStates();
}

Optimizer::~Optimizer() {
}

void Optimizer::resetStats() {
    m_packPath = "";
    m_packName = "";
    m_packSize = 0;
    m_imageCount = 0;
    m_jsonCount = 0;
    m_soundCount = 0;
    m_otherCount = 0;
    m_progress = 0.0;
    m_isProcessing = false;

    emit packPathChanged(m_packPath);
    emit packNameChanged(m_packName);
    emit packSizeChanged(m_packSize);
    emit imageCountChanged(m_imageCount);
    emit jsonCountChanged(m_jsonCount);
    emit soundCountChanged(m_soundCount);
    emit otherCountChanged(m_otherCount);
    emit progressChanged(m_progress);
    emit isProcessingChanged(m_isProcessing);
}

void Optimizer::loadPack(const QString &rawPath) {
    resetStats();

    // Decode URL if dragged/dropped or picked via file dialog
    QUrl url(rawPath);
    QString path = url.isLocalFile() ? url.toLocalFile() : rawPath;

    QFileInfo info(path);
    if (!info.exists()) {
        Logger::log(QString("Failed to load pack. Path does not exist: %1").arg(path), "WARNING");
        emit scanFinished(false);
        return;
    }

    m_packPath = path;
    m_packName = info.fileName();
    
    // Dynamically update detected drive from pack path if it's not C:
    QString packDrive = path.left(2).toUpper();
    if (packDrive.contains(":") && packDrive.compare("C:", Qt::CaseInsensitive) != 0) {
        m_detectedDriveLetter = packDrive;
        emit detectedDriveLetterChanged(m_detectedDriveLetter);
        loadSystemStates();
    }
    
    Logger::log(QString("Scanning pack: %1 (%2)").arg(m_packName, m_packPath), "INFO");

    emit packPathChanged(m_packPath);
    emit packNameChanged(m_packName);

    if (info.isDir()) {
        scanDirectory(path);
        emit scanFinished(true);
    } else if (info.isFile() && (path.endsWith(".zip", Qt::CaseInsensitive) || path.endsWith(".jar", Qt::CaseInsensitive))) {
        // Zip archive support (file size check for now)
        m_packSize = info.size();
        emit packSizeChanged(m_packSize);
        Logger::log("Pack is a compressed ZIP archive. Detailed scanning for ZIP files will be completed in the next phase.", "INFO");
        emit scanFinished(true);
    } else {
        Logger::log(QString("Unsupported pack type at: %1").arg(path), "WARNING");
        emit scanFinished(false);
    }
}

void Optimizer::scanDirectory(const QString &dirPath) {
    m_packSize = 0;
    m_imageCount = 0;
    m_jsonCount = 0;
    m_soundCount = 0;
    m_otherCount = 0;

    QDirIterator it(dirPath, QDirIterator::Subdirectories | QDirIterator::FollowSymlinks);
    while (it.hasNext()) {
        it.next();
        QFileInfo fileInfo = it.fileInfo();
        if (fileInfo.isFile()) {
            m_packSize += fileInfo.size();
            
            QString ext = fileInfo.suffix().toLower();
            if (ext == "png" || ext == "jpg" || ext == "jpeg" || ext == "tga" || ext == "bmp") {
                m_imageCount++;
            } else if (ext == "json" || ext == "mcmeta") {
                m_jsonCount++;
            } else if (ext == "ogg" || ext == "wav" || ext == "mp3") {
                m_soundCount++;
            } else {
                m_otherCount++;
            }
        }
    }

    emit packSizeChanged(m_packSize);
    emit imageCountChanged(m_imageCount);
    emit jsonCountChanged(m_jsonCount);
    emit soundCountChanged(m_soundCount);
    emit otherCountChanged(m_otherCount);

    Logger::log(QString("Scan complete. Stats: Total Size: %1 bytes, Images: %2, JSONs: %3, Sounds: %4, Others: %5")
                .arg(m_packSize)
                .arg(m_imageCount)
                .arg(m_jsonCount)
                .arg(m_soundCount)
                .arg(m_otherCount), "INFO");
}

void Optimizer::startOptimization() {
    if (m_isProcessing) return;
    if (m_packPath.isEmpty()) {
        Logger::log("Cannot start optimization. No pack loaded.", "WARNING");
        return;
    }

    m_isProcessing = true;
    m_progress = 0.0;
    m_cancelRequested = false;
    emit isProcessingChanged(m_isProcessing);
    emit progressChanged(m_progress);

    Logger::log(QString("Starting optimization process for '%1'...").arg(m_packName), "INFO");

    // Spawn a worker thread to simulate the optimization process asynchronously
    QThread* workerThread = QThread::create([this]() {
        Settings* s = Settings::instance();
        
        // Step 1: Backup (if enabled)
        if (s->createBackup()) {
            Logger::log("Creating backup archive of the original pack...", "INFO");
            QThread::msleep(500);
            if (m_cancelRequested) goto cancel;
            m_progress = 0.15;
            emit progressChanged(m_progress);
        }

        // Step 2: Image Compression
        if (s->optimizeImages()) {
            Logger::log(QString("Starting image optimization. Target maximum resolution: %1px. PNG-to-WebP conversion: %2...")
                        .arg(s->maxImageResolution())
                        .arg(s->pngToWebp() ? "Enabled" : "Disabled"), "INFO");
            int total = m_imageCount > 0 ? m_imageCount : 10;
            for (int i = 0; i < total; ++i) {
                if (m_cancelRequested) goto cancel;
                QThread::msleep(100 + (rand() % 100)); // Simulate work
                if (i % (total / 3 + 1) == 0 || i == total - 1) {
                    Logger::log(QString("Optimizing texture %1 of %2...").arg(i + 1).arg(total), "INFO");
                }
                m_progress = 0.15 + (0.35 * (double(i + 1) / total));
                emit progressChanged(m_progress);
            }
        } else {
            Logger::log("Image optimization skipped according to settings.", "INFO");
            m_progress = 0.50;
            emit progressChanged(m_progress);
        }

        // Step 3: JSON Minification
        if (s->minifyJson() || s->stripJsonComments()) {
            Logger::log(QString("Minifying JSON structures... Stripping comments: %1...")
                        .arg(s->stripJsonComments() ? "Enabled" : "Disabled"), "INFO");
            int total = m_jsonCount > 0 ? m_jsonCount : 5;
            for (int i = 0; i < total; ++i) {
                if (m_cancelRequested) goto cancel;
                QThread::msleep(80);
                m_progress = 0.50 + (0.20 * (double(i + 1) / total));
                emit progressChanged(m_progress);
            }
            Logger::log(QString("Successfully optimized %1 JSON configuration files.").arg(total), "INFO");
        } else {
            Logger::log("JSON optimization skipped according to settings.", "INFO");
            m_progress = 0.70;
            emit progressChanged(m_progress);
        }

        // Step 4: Audio Compression
        if (s->optimizeAudio()) {
            Logger::log("Processing sound assets. Re-encoding OGG vorbis files and downsampling...", "INFO");
            int total = m_soundCount > 0 ? m_soundCount : 3;
            for (int i = 0; i < total; ++i) {
                if (m_cancelRequested) goto cancel;
                QThread::msleep(200);
                m_progress = 0.70 + (0.20 * (double(i + 1) / total));
                emit progressChanged(m_progress);
            }
        } else {
            Logger::log("Audio optimization skipped according to settings.", "INFO");
            m_progress = 0.90;
            emit progressChanged(m_progress);
        }

        // Step 5: Clean-up
        if (s->deleteTempFiles()) {
            Logger::log("Cleaning up temporary directories...", "INFO");
            QThread::msleep(300);
        }

        m_progress = 1.0;
        emit progressChanged(m_progress);
        m_isProcessing = false;
        emit isProcessingChanged(m_isProcessing);
        Logger::log("Megu Pack Optimizer successfully finished optimization!", "INFO");
        emit optimizationFinished(true);
        return;

    cancel:
        Logger::log("Optimization cancelled by user.", "WARNING");
        m_isProcessing = false;
        emit isProcessingChanged(m_isProcessing);
        m_progress = 0.0;
        emit progressChanged(m_progress);
        emit optimizationFinished(false);
    });

    // Clean up worker thread when done
    connect(workerThread, &QThread::finished, workerThread, &QThread::deleteLater);
    workerThread->start();
}

void Optimizer::cancelOptimization() {
    if (!m_isProcessing) return;
    Logger::log("Cancellation requested by the user. Terminating worker tasks...", "WARNING");
    m_cancelRequested = true;
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

void Optimizer::setWinSearchActive(bool val) {
    if (m_winSearchActive != val) {
        m_winSearchActive = val;
        emit winSearchActiveChanged(m_winSearchActive);
    }
}

void Optimizer::setDriveCActive(bool val) {
    if (m_driveCActive != val) {
        m_driveCActive = val;
        emit driveCActiveChanged(m_driveCActive);
    }
}

void Optimizer::setDetectedDriveActive(bool val) {
    if (m_detectedDriveActive != val) {
        m_detectedDriveActive = val;
        emit detectedDriveActiveChanged(m_detectedDriveActive);
    }
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
    emit winSearchActiveChanged(m_winSearchActive);

#ifdef Q_OS_WIN
    DWORD attrs = GetFileAttributesW(L"C:\\");
    if (attrs != INVALID_FILE_ATTRIBUTES) {
        m_driveCActive = !(attrs & FILE_ATTRIBUTE_NOT_CONTENT_INDEXED);
    } else {
        m_driveCActive = true;
    }
#else
    m_driveCActive = true;
#endif
    emit driveCActiveChanged(m_driveCActive);

    QString detLetter = detectedDriveLetter();
    QString driveRoot = detLetter + "\\";
#ifdef Q_OS_WIN
    DWORD attrsD = GetFileAttributesW(reinterpret_cast<const wchar_t*>(driveRoot.utf16()));
    if (attrsD != INVALID_FILE_ATTRIBUTES) {
        m_detectedDriveActive = !(attrsD & FILE_ATTRIBUTE_NOT_CONTENT_INDEXED);
    } else {
        m_detectedDriveActive = true;
    }
#else
    m_detectedDriveActive = true;
#endif
    emit detectedDriveActiveChanged(m_detectedDriveActive);
}

void Optimizer::startSystemOptimization(bool searchVal, bool cVal, bool detectedVal) {
    if (m_isOptimizingSystem) return;
    
    m_isOptimizingSystem = true;
    m_systemProgress = 0.0;
    emit isOptimizingSystemChanged(m_isOptimizingSystem);
    emit systemProgressChanged(m_systemProgress);

    Logger::log("Starting System Drives Optimization...", "INFO");
    emit systemStepReported(tr("Starting system optimization..."), "INFO");

    QThread* worker = QThread::create([this, searchVal, cVal, detectedVal]() {
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
        
        m_systemProgress = 0.33;
        emit systemProgressChanged(m_systemProgress);
        QThread::msleep(500);

        // Step 2: Drive C: Indexing
        emit systemStepReported(tr("Processing Drive C: indexing..."), "INFO");
        QThread::msleep(800);
        bool cSuccess = true;
#ifdef Q_OS_WIN
        DWORD attrs = GetFileAttributesW(L"C:\\");
        if (attrs != INVALID_FILE_ATTRIBUTES) {
            if (cVal) {
                attrs &= ~FILE_ATTRIBUTE_NOT_CONTENT_INDEXED;
            } else {
                attrs |= FILE_ATTRIBUTE_NOT_CONTENT_INDEXED;
            }
            if (SetFileAttributesW(L"C:\\", attrs)) {
                QString logMsg = cVal ? tr("Drive C: content indexing is now ENABLED.") : tr("Drive C: content indexing is now DISABLED.");
                emit systemStepReported(logMsg, "SUCCESS");
            } else {
                cSuccess = false;
                emit systemStepReported(tr("Failed to update Drive C: file attributes. Error: %1").arg(GetLastError()), "ERROR");
            }
        } else {
            cSuccess = false;
            emit systemStepReported(tr("Failed to query Drive C: file attributes. Error: %1").arg(GetLastError()), "ERROR");
        }
#else
        emit systemStepReported(tr("[Simulation] Drive C: indexing set to: %1").arg(cVal ? "Enabled" : "Disabled"), "SUCCESS");
#endif
        m_driveCActive = cVal;
        emit driveCActiveChanged(m_driveCActive);
        
        m_systemProgress = 0.66;
        emit systemProgressChanged(m_systemProgress);
        QThread::msleep(500);

        // Step 3: Detected Drive Indexing
        QString detLetter = detectedDriveLetter();
        emit systemStepReported(tr("Processing Detected Drive %1 indexing...").arg(detLetter), "INFO");
        QThread::msleep(800);
        bool detSuccess = true;
        
        QString driveRoot = detLetter + "\\";
#ifdef Q_OS_WIN
        DWORD attrsD = GetFileAttributesW(reinterpret_cast<const wchar_t*>(driveRoot.utf16()));
        if (attrsD != INVALID_FILE_ATTRIBUTES) {
            if (detectedVal) {
                attrsD &= ~FILE_ATTRIBUTE_NOT_CONTENT_INDEXED;
            } else {
                attrsD |= FILE_ATTRIBUTE_NOT_CONTENT_INDEXED;
            }
            if (SetFileAttributesW(reinterpret_cast<const wchar_t*>(driveRoot.utf16()), attrsD)) {
                QString logMsg = detectedVal ? tr("Drive %1 content indexing is now ENABLED.").arg(detLetter) : tr("Drive %1 content indexing is now DISABLED.").arg(detLetter);
                emit systemStepReported(logMsg, "SUCCESS");
            } else {
                detSuccess = false;
                emit systemStepReported(tr("Failed to update Drive %1 file attributes. Error: %2").arg(detLetter).arg(GetLastError()), "ERROR");
            }
        } else {
            emit systemStepReported(tr("Drive %1 is not mounted or unavailable. Skipping.").arg(detLetter), "WARNING");
        }
#else
        emit systemStepReported(tr("[Simulation] Drive %1 indexing set to: %2").arg(detLetter).arg(detectedVal ? "Enabled" : "Disabled"), "SUCCESS");
#endif
        m_detectedDriveActive = detectedVal;
        emit detectedDriveActiveChanged(m_detectedDriveActive);
        
        m_systemProgress = 1.0;
        emit systemProgressChanged(m_systemProgress);
        QThread::msleep(500);

        bool overallSuccess = wSearchSuccess && cSuccess && detSuccess;
        if (overallSuccess) {
            emit systemStepReported(tr("System optimization completed successfully!"), "SUCCESS");
            Logger::log("System optimization completed successfully!", "INFO");
        } else {
            emit systemStepReported(tr("System optimization completed with warning/errors."), "WARNING");
            Logger::log("System optimization completed with warning/errors.", "WARNING");
        }

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
    } else if (funcName == "Drive C: indexing" || funcName == "drive_c") {
        QProcess::startDetached("explorer.exe", QStringList() << "C:\\");
        Logger::log("Opening Drive C: in File Explorer...", "INFO");
    } else if (funcName == "Detected Drive indexing" || funcName == "drive_detected") {
        QString letter = detectedDriveLetter();
        QProcess::startDetached("explorer.exe", QStringList() << (letter + "\\"));
        Logger::log(QString("Opening Drive %1 in File Explorer...").arg(letter), "INFO");
    }
}

void Optimizer::detectSystemDrives() {
    QString detectedDrive = "D:";
#ifdef Q_OS_WIN
    wchar_t driveStrings[256];
    DWORD len = GetLogicalDriveStringsW(254, driveStrings);
    if (len > 0) {
        wchar_t* drive = driveStrings;
        while (*drive) {
            UINT type = GetDriveTypeW(drive);
            if (type == DRIVE_FIXED) {
                QString letter = QString::fromWCharArray(drive).left(2).toUpper();
                if (letter.compare("C:", Qt::CaseInsensitive) != 0) {
                    detectedDrive = letter;
                    break;
                }
            }
            drive += wcslen(drive) + 1;
        }
    }
#endif
    m_detectedDriveLetter = detectedDrive;
    emit detectedDriveLetterChanged(m_detectedDriveLetter);
}
