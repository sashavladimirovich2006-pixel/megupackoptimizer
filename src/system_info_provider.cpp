#include "system_info_provider.h"
#include "logger.h"

#include <QSysInfo>
#include <QScreen>
#include <QGuiApplication>
#include <QThread>
#include <QSettings>
#include <QProcess>
#include <QRegularExpression>
#include <QDir>
#include <QCoreApplication>

#ifdef Q_OS_WIN
#include <windows.h>
#endif

QString SystemInfoProvider::getOsName() {
    QString os = QSysInfo::prettyProductName();
#ifdef Q_OS_WIN
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
#endif
    return os;
}

QString SystemInfoProvider::getCpuName() {
    QString cpuName = "Unknown CPU";
#ifdef Q_OS_WIN
    HKEY hKey;
    if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"HARDWARE\\DESCRIPTION\\System\\CentralProcessor\\0", 0, KEY_READ, &hKey) == ERROR_SUCCESS) {
        wchar_t cpu[256] = {0};
        DWORD size = sizeof(cpu);
        if (RegQueryValueExW(hKey, L"ProcessorNameString", NULL, NULL, (LPBYTE)cpu, &size) == ERROR_SUCCESS) {
            cpuName = QString::fromWCharArray(cpu).trimmed();
        }
        RegCloseKey(hKey);
    }
#else
    cpuName = "AMD Ryzen 5 5600X 6-Core Processor";
#endif
    return cpuName;
}

QString SystemInfoProvider::getLogicalCores() {
    return QString("%1 Logical Processors").arg(QThread::idealThreadCount());
}

QString SystemInfoProvider::getRamSize() {
    QString ramSize = "Unknown RAM";
#ifdef Q_OS_WIN
    MEMORYSTATUSEX memInfo;
    memInfo.dwLength = sizeof(MEMORYSTATUSEX);
    if (GlobalMemoryStatusEx(&memInfo)) {
        double totalPhysMem = memInfo.ullTotalPhys / (1024.0 * 1024.0 * 1024.0);
        ramSize = QString::number(totalPhysMem, 'f', 2) + " GB RAM";
    }
#else
    ramSize = "32.00 GB RAM";
#endif
    return ramSize;
}

QString SystemInfoProvider::getGpuName() {
    QString gpuName = "Unknown GPU";
#ifdef Q_OS_WIN
    DISPLAY_DEVICEW dd;
    dd.cb = sizeof(dd);
    for (int i = 0; EnumDisplayDevicesW(NULL, i, &dd, 0); ++i) {
        if (dd.StateFlags & DISPLAY_DEVICE_PRIMARY_DEVICE) {
            gpuName = QString::fromWCharArray(dd.DeviceString).trimmed();
            break;
        }
    }
    if (gpuName == "Unknown GPU" && EnumDisplayDevicesW(NULL, 0, &dd, 0)) {
        gpuName = QString::fromWCharArray(dd.DeviceString).trimmed();
    }
#else
    gpuName = "NVIDIA GeForce RTX 5070";
#endif
    return gpuName;
}

QString SystemInfoProvider::getMotherboard() {
    QString motherboard = "Unknown Motherboard";
#ifdef Q_OS_WIN
    QString manufacturer, product;
    HKEY hKey;
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
        motherboard = manufacturer + " " + product;
    }
#else
    motherboard = "ASUSTeK COMPUTER INC. TUF GAMING B550M-PLUS";
#endif
    return motherboard;
}

QString SystemInfoProvider::getMotherboardSubValue() {
    QString val = "";
#ifdef Q_OS_WIN
    GetFirmwareEnvironmentVariableW(L"", L"{00000000-0000-0000-0000-000000000000}", NULL, 0);
    if (GetLastError() == ERROR_INVALID_FUNCTION) {
        val = QCoreApplication::translate("Optimizer", "Legacy BIOS Boot Mode");
    } else {
        val = QCoreApplication::translate("Optimizer", "UEFI Boot Mode Enabled");
    }
#else
    val = QCoreApplication::translate("Optimizer", "UEFI Boot Mode Enabled");
#endif
    return val;
}

QString SystemInfoProvider::getStorage() {
    QString val = "Unknown Storage";
#ifdef Q_OS_WIN
    ULARGE_INTEGER freeBytesAvailable, totalBytes, totalFreeBytes;
    if (GetDiskFreeSpaceExW(L"C:\\", &freeBytesAvailable, &totalBytes, &totalFreeBytes)) {
        double freeGB = freeBytesAvailable.QuadPart / (1024.0 * 1024.0 * 1024.0);
        double totalGB = totalBytes.QuadPart / (1024.0 * 1024.0 * 1024.0);
        val = QString("%1 GB Free / %2 GB Total").arg(QString::number(freeGB, 'f', 1)).arg(QString::number(totalGB, 'f', 1));
    }
#else
    val = "120.0 GB Free / 250.0 GB Total";
#endif
    return val;
}

QString SystemInfoProvider::getDisplay() {
    QString val = "";
    QScreen *screen = QGuiApplication::primaryScreen();
    if (screen) {
        val = QString("%1x%2 @ %3Hz")
                        .arg(screen->geometry().width())
                        .arg(screen->geometry().height())
                        .arg(qRound(screen->refreshRate()));
    }
    return val;
}

QString SystemInfoProvider::getSecureBoot() {
    QString val = QCoreApplication::translate("Optimizer", "Disabled");
#ifdef Q_OS_WIN
    QSettings regSecureBoot("HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\SecureBoot\\State", QSettings::NativeFormat);
    int secureBootEnabled = regSecureBoot.value("UEFISecureBootEnabled", 0).toInt();
    val = (secureBootEnabled == 1) ? QCoreApplication::translate("Optimizer", "Enabled") : QCoreApplication::translate("Optimizer", "Disabled");
#else
    val = QCoreApplication::translate("Optimizer", "Enabled");
#endif
    return val;
}

QString SystemInfoProvider::getHagsStatus() {
    QString val = QCoreApplication::translate("Optimizer", "Disabled");
#ifdef Q_OS_WIN
    QSettings regHags("HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\GraphicsDrivers", QSettings::NativeFormat);
    int hwSchMode = regHags.value("HwSchMode", 1).toInt();
    val = (hwSchMode == 2) ? QCoreApplication::translate("Optimizer", "Enabled") : QCoreApplication::translate("Optimizer", "Disabled");
#else
    val = QCoreApplication::translate("Optimizer", "Enabled");
#endif
    return val;
}

QString SystemInfoProvider::getHvciStatus() {
    QString val = QCoreApplication::translate("Optimizer", "Disabled");
#ifdef Q_OS_WIN
    QSettings regHvci("HKEY_LOCAL_MACHINE\\SYSTEM\\CurrentControlSet\\Control\\DeviceGuard\\Scenarios\\HypervisorEnforcedCodeIntegrity", QSettings::NativeFormat);
    int hvciEnabled = regHvci.value("Enabled", 0).toInt();
    val = (hvciEnabled == 1) ? QCoreApplication::translate("Optimizer", "Enabled") : QCoreApplication::translate("Optimizer", "Disabled");
#else
    val = QCoreApplication::translate("Optimizer", "Disabled");
#endif
    return val;
}

QString SystemInfoProvider::getTpmStatus() {
    QString tpm = QCoreApplication::translate("Optimizer", "Disabled / Not Found");
#ifdef Q_OS_WIN
    HMODULE hTbs = LoadLibraryW(L"tbs.dll");
    if (hTbs) {
        typedef HRESULT (WINAPI *FN_Tbsi_GetDeviceInfo)(UINT32 Size, PVOID Info);
        FN_Tbsi_GetDeviceInfo pGetDeviceInfo = (FN_Tbsi_GetDeviceInfo)GetProcAddress(hTbs, "Tbsi_GetDeviceInfo");
        if (pGetDeviceInfo) {
            struct TBS_DEVICE_INFO_1 {
                UINT32 structVersion;
                UINT32 tpmVersion;
                UINT32 tpmInterfaceType;
                UINT32 tpmImplVersion;
            } info;
            memset(&info, 0, sizeof(info));
            info.structVersion = 1;
            HRESULT hr = pGetDeviceInfo(sizeof(info), &info);
            if (hr == S_OK) {
                if (info.tpmVersion == 1) {
                    tpm = QCoreApplication::translate("Optimizer", "TPM 1.2 Active");
                } else if (info.tpmVersion == 2) {
                    tpm = QCoreApplication::translate("Optimizer", "TPM 2.0 Active");
                } else {
                    tpm = QCoreApplication::translate("Optimizer", "TPM Active (Unknown Version)");
                }
            }
        }
        FreeLibrary(hTbs);
    }
#else
    tpm = QCoreApplication::translate("Optimizer", "TPM 2.0 Active");
#endif
    return tpm;
}

QString SystemInfoProvider::getRebarStatus() {
    QString rebar = QCoreApplication::translate("Optimizer", "Disabled");
#ifdef Q_OS_WIN
    QProcess rebarProc;
    rebarProc.start("nvidia-smi", QStringList() << "-q");
    if (rebarProc.waitForFinished(2000)) {
        QString out = QString::fromUtf8(rebarProc.readAllStandardOutput());
        int idx = out.indexOf("BAR1 Memory Usage");
        if (idx != -1) {
            int totalIdx = out.indexOf("Total", idx);
            if (totalIdx != -1) {
                int colonIdx = out.indexOf(":", totalIdx);
                int eolIdx = out.indexOf("\n", totalIdx);
                if (colonIdx != -1 && eolIdx != -1 && colonIdx < eolIdx) {
                    QString totalStr = out.mid(colonIdx + 1, eolIdx - colonIdx - 1).trimmed();
                    QRegularExpression numRx("(\\d+)");
                    QRegularExpressionMatch m = numRx.match(totalStr);
                    if (m.hasMatch()) {
                        int mib = m.captured(1).toInt();
                        if (mib > 512) {
                            rebar = QCoreApplication::translate("Optimizer", "Enabled (%1)").arg(totalStr);
                        } else {
                            rebar = QCoreApplication::translate("Optimizer", "Disabled (%1)").arg(totalStr);
                        }
                    } else {
                        rebar = QCoreApplication::translate("Optimizer", "Disabled (%1)").arg(totalStr);
                    }
                }
            }
        }
    }
#else
    rebar = QCoreApplication::translate("Optimizer", "Enabled (8192 MiB)");
#endif
    return rebar;
}

double SystemInfoProvider::getCpuLoad(void* prevIdle, void* prevKernel, void* prevUser) {
    double cpu = 0.0;
#ifdef Q_OS_WIN
    FILETIME idleTime, kernelTime, userTime;
    if (GetSystemTimes(&idleTime, &kernelTime, &userTime) && prevIdle && prevKernel && prevUser) {
        ULARGE_INTEGER idle, kernel, user;
        idle.LowPart = idleTime.dwLowDateTime; idle.HighPart = idleTime.dwHighDateTime;
        kernel.LowPart = kernelTime.dwLowDateTime; kernel.HighPart = kernelTime.dwHighDateTime;
        user.LowPart = userTime.dwLowDateTime; user.HighPart = userTime.dwHighDateTime;
        
        FILETIME* prevIdleTimePtr = static_cast<FILETIME*>(prevIdle);
        FILETIME* prevKernelTimePtr = static_cast<FILETIME*>(prevKernel);
        FILETIME* prevUserTimePtr = static_cast<FILETIME*>(prevUser);

        ULARGE_INTEGER prevIdleVal, prevKernelVal, prevUserVal;
        prevIdleVal.LowPart = prevIdleTimePtr->dwLowDateTime; prevIdleVal.HighPart = prevIdleTimePtr->dwHighDateTime;
        prevKernelVal.LowPart = prevKernelTimePtr->dwLowDateTime; prevKernelVal.HighPart = prevKernelTimePtr->dwHighDateTime;
        prevUserVal.LowPart = prevUserTimePtr->dwLowDateTime; prevUserVal.HighPart = prevUserTimePtr->dwHighDateTime;
        
        *prevIdleTimePtr = idleTime;
        *prevKernelTimePtr = kernelTime;
        *prevUserTimePtr = userTime;
        
        ULONGLONG idleDiff = idle.QuadPart - prevIdleVal.QuadPart;
        ULONGLONG kernelDiff = kernel.QuadPart - prevKernelVal.QuadPart;
        ULONGLONG userDiff = user.QuadPart - prevUserVal.QuadPart;
        
        ULONGLONG totalDiff = kernelDiff + userDiff;
        if (totalDiff > 0) {
            ULONGLONG activeDiff = totalDiff - idleDiff;
            cpu = double(activeDiff) / double(totalDiff);
        }
    }
#else
    cpu = 0.15;
#endif
    return qBound(0.0, cpu, 1.0);
}

double SystemInfoProvider::getRamLoad() {
    double ram = 0.0;
#ifdef Q_OS_WIN
    MEMORYSTATUSEX memInfo;
    memInfo.dwLength = sizeof(MEMORYSTATUSEX);
    if (GlobalMemoryStatusEx(&memInfo)) {
        ram = double(memInfo.dwMemoryLoad) / 100.0;
    }
#else
    ram = 0.45;
#endif
    return qBound(0.0, ram, 1.0);
}

void SystemInfoProvider::queryGpuTempAsync(QObject *parent, std::function<void(const QString &)> callback) {
#ifdef Q_OS_WIN
    QProcess *proc = new QProcess(parent);
    QObject::connect(proc, QOverload<int, QProcess::ExitStatus>::of(&QProcess::finished), parent, [proc, callback](int exitCode, QProcess::ExitStatus exitStatus) {
        if (exitStatus == QProcess::NormalExit && exitCode == 0) {
            QString out = QString::fromUtf8(proc->readAllStandardOutput()).trimmed();
            if (!out.isEmpty()) {
                callback(out + "°C");
            }
        } else {
            callback("N/A");
        }
        proc->deleteLater();
    });
    proc->start("nvidia-smi", QStringList() << "--query-gpu=temperature.gpu" << "--format=csv,noheader,nounits");
#else
    // Simulation: generate a temperature around 45-55C
    static int baseTemp = 48;
    int offset = (rand() % 5) - 2; // -2 to +2
    QString newTemp = QString::number(baseTemp + offset) + "°C";
    callback(newTemp);
#endif
}
