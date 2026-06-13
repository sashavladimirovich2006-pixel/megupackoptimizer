#include "power_usb_manager.h"
#include "logger.h"

#include <QProcess>
#include <QRegularExpression>
#include <QSettings>
#include <QMap>
#include <QCoreApplication>
#include <QThread>

#ifdef Q_OS_WIN
#include <windows.h>
#include <powrprof.h>
#include <objbase.h>
#pragma comment(lib, "powrprof.lib")
#endif

QVariantList PowerUsbManager::loadPowerSchemes(bool &isUltimateUnlocked, QString &activeSchemeGuidStr) {
    QVariantList schemesList;
    isUltimateUnlocked = false;
    activeSchemeGuidStr = "";

#ifdef Q_OS_WIN
    GUID activeGuid;
    GUID *pActiveGuid = NULL;
    DWORD activeErr = PowerGetActiveScheme(NULL, &pActiveGuid);
    if (activeErr == ERROR_SUCCESS && pActiveGuid != NULL) {
        activeGuid = *pActiveGuid;
        wchar_t activeGuidStr[64] = {0};
        StringFromGUID2(activeGuid, activeGuidStr, 64);
        activeSchemeGuidStr = QString::fromWCharArray(activeGuidStr).toUpper();
        LocalFree(pActiveGuid);
    }

    DWORD index = 0;
    GUID schemeGuid;
    DWORD bufferSize = sizeof(GUID);
    const GUID ultimateGuid = { 0xe9a22b95, 0xe3b0, 0x4b87, { 0xa1, 0x77, 0x72, 0x89, 0x78, 0xed, 0x60, 0x22 } };

    while (PowerEnumerate(NULL, NULL, NULL, ACCESS_SCHEME, index, (UCHAR*)&schemeGuid, &bufferSize) == ERROR_SUCCESS) {
        wchar_t guidStr[64] = {0};
        StringFromGUID2(schemeGuid, guidStr, 64);
        QString guidQStr = QString::fromWCharArray(guidStr).toUpper();

        // Get friendly name
        UCHAR friendlyName[256] = {0};
        DWORD friendlyNameSize = sizeof(friendlyName);
        PowerReadFriendlyName(NULL, &schemeGuid, NULL, NULL, friendlyName, &friendlyNameSize);
        QString name = QString::fromWCharArray((const wchar_t*)friendlyName);
        if (name.isEmpty()) {
            name = guidQStr;
        }

        bool isActive = (activeErr == ERROR_SUCCESS && IsEqualGUID(schemeGuid, activeGuid));
        bool isUltimate = IsEqualGUID(schemeGuid, ultimateGuid) || name.contains("Ultimate Performance") || name.contains("Ultimate") || name.contains("Максимальная производительность");
        if (isUltimate) {
            isUltimateUnlocked = true;
        }

        QVariantMap schemeMap;
        schemeMap["name"] = name;
        schemeMap["guid"] = guidQStr;
        schemeMap["isActive"] = isActive;
        schemeMap["isUltimate"] = isUltimate;
        schemesList.append(schemeMap);

        index++;
        bufferSize = sizeof(GUID);
    }
#else
    // Simulation fallbacks for non-Windows (or debugging)
    QVariantMap balanced;
    balanced["name"] = "Balanced (Збалансований)";
    balanced["guid"] = "{381B4222-F694-41F0-9685-FF5BB260DF2E}";
    balanced["isActive"] = true;
    balanced["isUltimate"] = false;

    QVariantMap highPerf;
    highPerf["name"] = "High performance (Висока продуктивність)";
    highPerf["guid"] = "{8C5E7FDA-E8BF-4A96-9A85-A6E23A8C635C}";
    highPerf["isActive"] = false;
    highPerf["isUltimate"] = false;

    schemesList.append(balanced);
    schemesList.append(highPerf);

    isUltimateUnlocked = false; // By default hidden in simulation
    activeSchemeGuidStr = "{381B4222-F694-41F0-9685-FF5BB260DF2E}";
#endif

    return schemesList;
}

QVariantList PowerUsbManager::loadUsbDevices(bool &anyUsbPowerSaving) {
    QVariantList usbList;
    anyUsbPowerSaving = false;

#ifdef Q_OS_WIN
    // Query ground-truth WMI states first to get accurate active state
    QMap<QString, bool> wmiStates;
    QProcess wmiProc;
    wmiProc.start("powershell.exe", QStringList() 
        << "-NoProfile" 
        << "-NonInteractive" 
        << "-ExecutionPolicy" << "Bypass" 
        << "-Command" 
        << "Get-CimInstance -ClassName MSPower_DeviceEnable -Namespace root\\WMI | Where-Object { $_.InstanceName -like 'USB*' } | ForEach-Object { $id = $_.InstanceName; if ($id.Length -gt 2) { $id = $id.Substring(0, $id.Length - 2); $drv = (Get-ItemProperty -Path ('HKLM:\\SYSTEM\\CurrentControlSet\\Enum\\' + $id) -ErrorAction SilentlyContinue).Driver; if ($drv) { Write-Output ($drv + '=' + $_.Enable) } } }");
    if (wmiProc.waitForFinished(8000)) {
        QString output = QString::fromUtf8(wmiProc.readAllStandardOutput()).trimmed();
        QStringList lines = output.split('\n', Qt::SkipEmptyParts);
        for (const QString &line : lines) {
            QString trimmed = line.trimmed();
            int eqIdx = trimmed.indexOf('=');
            if (eqIdx != -1) {
                QString drv = trimmed.left(eqIdx).trimmed().toLower();
                QString stateStr = trimmed.mid(eqIdx + 1).trimmed();
                bool active = (stateStr.compare("True", Qt::CaseInsensitive) == 0);
                wmiStates[drv] = active;
            }
        }
    }

    HKEY hKeyClass;
    if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SYSTEM\\CurrentControlSet\\Control\\Class\\{36fc9e60-c465-11cf-8056-444553540000}", 0, KEY_READ, &hKeyClass) == ERROR_SUCCESS) {
        wchar_t subkeyName[256];
        DWORD index = 0;
        DWORD subkeyNameSize = 256;
        while (RegEnumKeyExW(hKeyClass, index, subkeyName, &subkeyNameSize, NULL, NULL, NULL, NULL) == ERROR_SUCCESS) {
            HKEY hKeySub;
            QString subkeyPath = QString("SYSTEM\\CurrentControlSet\\Control\\Class\\{36fc9e60-c465-11cf-8056-444553540000}\\%1").arg(QString::fromWCharArray(subkeyName));
            std::wstring wSubkeyPath = subkeyPath.toStdWString();
            if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, wSubkeyPath.c_str(), 0, KEY_READ, &hKeySub) == ERROR_SUCCESS) {
                wchar_t driverDesc[512] = {0};
                DWORD descSize = sizeof(driverDesc);
                if (RegQueryValueExW(hKeySub, L"DriverDesc", NULL, NULL, (LPBYTE)driverDesc, &descSize) == ERROR_SUCCESS) {
                    QString desc = QString::fromWCharArray(driverDesc);
                    if (desc.contains("USB 3", Qt::CaseInsensitive) || desc.contains("Root Hub", Qt::CaseInsensitive)) {
                        DWORD pnpCaps = 0;
                        DWORD capsSize = sizeof(pnpCaps);
                        bool hasCaps = (RegQueryValueExW(hKeySub, L"PnPCapabilities", NULL, NULL, (LPBYTE)&pnpCaps, &capsSize) == ERROR_SUCCESS);
                        
                        int braceIdx = subkeyPath.indexOf('{');
                        QString relativeKey = (braceIdx != -1) ? subkeyPath.mid(braceIdx) : subkeyPath;
                        QString relKeyLower = relativeKey.toLower();
                        
                        bool powerSaving = true; // default enabled
                        if (wmiStates.contains(relKeyLower)) {
                            powerSaving = wmiStates[relKeyLower];
                        } else {
                            if (hasCaps && pnpCaps == 24) {
                                powerSaving = false;
                            }
                        }
                        
                        QVariantMap deviceMap;
                        deviceMap["name"] = desc;
                        deviceMap["subkeyPath"] = subkeyPath;
                        deviceMap["powerSavingActive"] = powerSaving;
                        usbList.append(deviceMap);
                    }
                }
                RegCloseKey(hKeySub);
            }
            subkeyNameSize = 256;
            index++;
        }
        RegCloseKey(hKeyClass);
    }
#else
    // Simulation fallbacks for other OS developers
    QVariantMap dev1;
    dev1["name"] = "Intel(R) USB 3.10 eXtensible Host Controller - 1.10 (Microsoft)";
    dev1["subkeyPath"] = "SYSTEM\\CurrentControlSet\\Control\\Class\\{36fc9e60-c465-11cf-8056-444553540000}\\0001";
    dev1["powerSavingActive"] = true;
    
    QVariantMap dev2;
    dev2["name"] = "USB Root Hub (USB 3.0)";
    dev2["subkeyPath"] = "SYSTEM\\CurrentControlSet\\Control\\Class\\{36fc9e60-c465-11cf-8056-444553540000}\\0002";
    dev2["powerSavingActive"] = true;

    usbList.append(dev1);
    usbList.append(dev2);
#endif

    for (const QVariant &dev : usbList) {
        if (dev.toMap()["powerSavingActive"].toBool()) {
            anyUsbPowerSaving = true;
            break;
        }
    }

    return usbList;
}

void PowerUsbManager::deleteUltimatePerformance(const QVariantList &powerSchemes) {
#ifdef Q_OS_WIN
    // 1. Find all Ultimate Performance scheme GUIDs in powerSchemes
    QStringList guidsToDelete;
    const QString standardUltimateGuidStr = "{E9A22B95-E3B0-4B87-A177-728978ED6022}";
    
    for (int i = 0; i < powerSchemes.size(); ++i) {
        QVariantMap map = powerSchemes[i].toMap();
        QString guid = map["guid"].toString().toUpper();
        QString name = map["name"].toString();
        bool isUltimate = (guid == standardUltimateGuidStr) || 
                          name.contains("Ultimate Performance") || 
                          name.contains("Ultimate") || 
                          name.contains("Максимальная производительность");
        if (isUltimate) {
            guidsToDelete.append(guid);
        }
    }
    
    // 2. Reset active scheme to Balanced if currently active is custom Ultimate
    GUID activeGuid;
    GUID *pActiveGuid = NULL;
    DWORD activeErr = PowerGetActiveScheme(NULL, &pActiveGuid);
    bool activeNeedsReset = false;
    if (activeErr == ERROR_SUCCESS && pActiveGuid != NULL) {
        activeGuid = *pActiveGuid;
        wchar_t activeGuidStr[64] = {0};
        StringFromGUID2(activeGuid, activeGuidStr, 64);
        QString activeSchemeStr = QString::fromWCharArray(activeGuidStr).toUpper();
        LocalFree(pActiveGuid);
        
        if (guidsToDelete.contains(activeSchemeStr)) {
            activeNeedsReset = true;
        }
    }
    
    if (activeNeedsReset) {
        const QString balancedGuidStr = "{381B4222-F694-41F0-9685-FF5BB260DF2E}";
        GUID balancedGuid;
        HRESULT hr = CLSIDFromString((LPCOLESTR)balancedGuidStr.utf16(), &balancedGuid);
        if (SUCCEEDED(hr)) {
            PowerSetActiveScheme(NULL, &balancedGuid);
            Logger::log("Reset active power scheme to Balanced before deleting Ultimate Performance scheme.", "INFO");
        }
    }
    
    // 3. Delete each Ultimate Performance scheme using powercfg.exe -delete
    for (const QString &guidStr : guidsToDelete) {
        QString cleanGuid = guidStr;
        cleanGuid.replace("{", "").replace("}", "");
        
        QProcess proc;
        proc.start("powercfg.exe", QStringList() << "-delete" << cleanGuid);
        proc.waitForFinished(4000);
        Logger::log(QString("Deleted custom Ultimate Performance scheme: %1").arg(guidStr), "INFO");
    }
#else
    Q_UNUSED(powerSchemes);
#endif
}

bool PowerUsbManager::setUsbPowerSavingRegistry(const QString &subkeyPath, bool active) {
    bool ok = false;
#ifdef Q_OS_WIN
    std::wstring wSubkey = subkeyPath.toStdWString();
    HKEY hKeySub;
    if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, wSubkey.c_str(), 0, KEY_SET_VALUE, &hKeySub) == ERROR_SUCCESS) {
        if (active) {
            // Enable power saving (delete PnPCapabilities value or set to 0)
            LSTATUS status = RegDeleteValueW(hKeySub, L"PnPCapabilities");
            if (status != ERROR_SUCCESS && status != ERROR_FILE_NOT_FOUND) {
                DWORD zero = 0;
                RegSetValueExW(hKeySub, L"PnPCapabilities", 0, REG_DWORD, (LPBYTE)&zero, sizeof(zero));
            }
            ok = true;
        } else {
            // Disable power saving (write 24 / 0x18)
            DWORD pnpVal = 24;
            if (RegSetValueExW(hKeySub, L"PnPCapabilities", 0, REG_DWORD, (LPBYTE)&pnpVal, sizeof(pnpVal)) == ERROR_SUCCESS) {
                ok = true;
            }
        }
        RegCloseKey(hKeySub);
    }
#else
    Q_UNUSED(subkeyPath);
    Q_UNUSED(active);
    ok = true;
#endif
    return ok;
}

bool PowerUsbManager::applyPowerScheme(const QString &targetPowerSchemeGuid, 
                                     const QString &activePowerSchemeGuid, 
                                     bool deleteUltimateStaged, 
                                     QString &finalActiveSchemeGuid,
                                     std::function<void(const QString&, const QString&)> reportStep) {
    bool success = true;
    QString finalTargetPowerSchemeVal = targetPowerSchemeGuid;
    finalActiveSchemeGuid = activePowerSchemeGuid;

#ifdef Q_OS_WIN
    const QString ultimateGuidStr = "{E9A22B95-E3B0-4B87-A177-728978ED6022}";
    
    // 1. Delete Ultimate Performance scheme if staged
    if (deleteUltimateStaged) {
        GUID schemeGuid;
        DWORD bufferSize = sizeof(GUID);
        DWORD index = 0;
        QStringList guidsToDelete;
        
        while (PowerEnumerate(NULL, NULL, NULL, ACCESS_SCHEME, index, (UCHAR*)&schemeGuid, &bufferSize) == ERROR_SUCCESS) {
            wchar_t guidStr[64] = {0};
            StringFromGUID2(schemeGuid, guidStr, 64);
            QString guidQStr = QString::fromWCharArray(guidStr).toUpper();
            
            UCHAR friendlyName[256] = {0};
            DWORD friendlyNameSize = sizeof(friendlyName);
            PowerReadFriendlyName(NULL, &schemeGuid, NULL, NULL, friendlyName, &friendlyNameSize);
            QString name = QString::fromWCharArray((const wchar_t*)friendlyName);
            
            bool isUltimate = (guidQStr == ultimateGuidStr) || 
                              name.contains("Ultimate Performance") || 
                              name.contains("Ultimate") || 
                              name.contains("Максимальная производительность");
            if (isUltimate) {
                guidsToDelete.append(guidQStr);
            }
            index++;
            bufferSize = sizeof(GUID);
        }
        
        for (const QString &guidStr : guidsToDelete) {
            QString cleanGuid = guidStr;
            cleanGuid.replace("{", "").replace("}", "");
            QProcess proc;
            proc.start("powercfg.exe", QStringList() << "-delete" << cleanGuid);
            proc.waitForFinished(4000);
            Logger::log(QString("Deleted custom Ultimate Performance scheme during optimization: %1").arg(guidStr), "INFO");
        }
        
        finalActiveSchemeGuid = finalTargetPowerSchemeVal;
        reportStep(QCoreApplication::translate("Optimizer", "Ultimate Performance scheme deleted from system."), "SUCCESS");
        success = false; // Skip activation since we just deleted it
    } 
    // 2. Unlock Ultimate Performance scheme if targeted and not yet present
    else if (finalTargetPowerSchemeVal == ultimateGuidStr) {
        GUID schemeGuid;
        DWORD bufferSize = sizeof(GUID);
        DWORD index = 0;
        bool found = false;
        const GUID ultimateGuid = { 0xe9a22b95, 0xe3b0, 0x4b87, { 0xa1, 0x77, 0x72, 0x89, 0x78, 0xed, 0x60, 0x22 } };
        while (PowerEnumerate(NULL, NULL, NULL, ACCESS_SCHEME, index, (UCHAR*)&schemeGuid, &bufferSize) == ERROR_SUCCESS) {
            if (IsEqualGUID(schemeGuid, ultimateGuid)) {
                found = true;
                break;
            }
            index++;
            bufferSize = sizeof(GUID);
        }
        
        if (!found) {
            index = 0;
            bufferSize = sizeof(GUID);
            GUID customUltGuid;
            while (PowerEnumerate(NULL, NULL, NULL, ACCESS_SCHEME, index, (UCHAR*)&customUltGuid, &bufferSize) == ERROR_SUCCESS) {
                UCHAR friendlyName[256] = {0};
                DWORD friendlyNameSize = sizeof(friendlyName);
                PowerReadFriendlyName(NULL, &customUltGuid, NULL, NULL, friendlyName, &friendlyNameSize);
                QString name = QString::fromWCharArray((const wchar_t*)friendlyName);
                if (name.contains("Ultimate Performance") || name.contains("Ultimate") || name.contains("Максимальная производительность")) {
                    wchar_t customUltGuidStr[64] = {0};
                    StringFromGUID2(customUltGuid, customUltGuidStr, 64);
                    finalTargetPowerSchemeVal = QString::fromWCharArray(customUltGuidStr).toUpper();
                    found = true;
                    break;
                }
                index++;
                bufferSize = sizeof(GUID);
            }
        }
        
        if (!found) {
            QProcess proc;
            proc.start("powercfg.exe", QStringList() << "-duplicatescheme" << "e9a22b95-e3b0-4b87-a177-728978ed6022");
            bool finished = proc.waitForFinished(8000);
            if (finished && proc.exitCode() == 0) {
                Logger::log("Successfully duplicated standard Ultimate Performance power scheme.", "INFO");
            } else {
                Logger::log("Ultimate Performance scheme template not supported. Falling back to duplicating High Performance...", "WARNING");
                
                QProcess fallbackProc;
                fallbackProc.start("powercfg.exe", QStringList() << "-duplicatescheme" << "8c5e7fda-e8bf-4a96-9a85-a6e23a8c635c");
                if (fallbackProc.waitForFinished(8000) && fallbackProc.exitCode() == 0) {
                    QString output = QString::fromLocal8Bit(fallbackProc.readAllStandardOutput());
                    QRegularExpression re("([a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12})");
                    QRegularExpressionMatch match = re.match(output);
                    if (match.hasMatch()) {
                        QString newGuidStr = match.captured(1);
                        QProcess renameProc;
                        renameProc.start("powercfg.exe", QStringList() << "-changename" << newGuidStr << "Ultimate Performance");
                        renameProc.waitForFinished(3000);
                        
                        finalTargetPowerSchemeVal = "{" + newGuidStr.toUpper() + "}";
                        Logger::log(QString("Created custom Ultimate Performance scheme by duplicating High Performance: %1").arg(finalTargetPowerSchemeVal), "INFO");
                    } else {
                        success = false;
                        reportStep(QCoreApplication::translate("Optimizer", "Failed to duplicate High Performance power scheme."), "ERROR");
                        Logger::log("Failed to parse GUID from duplicatescheme output.", "ERROR");
                    }
                } else {
                    success = false;
                    reportStep(QCoreApplication::translate("Optimizer", "Failed to duplicate High Performance power scheme."), "ERROR");
                    Logger::log("Failed to run duplicatescheme for High Performance.", "ERROR");
                }
            }
        }
    }
    
    // 3. Set the active scheme
    if (success) {
        GUID guid;
        HRESULT hr = CLSIDFromString((LPCOLESTR)finalTargetPowerSchemeVal.utf16(), &guid);
        if (SUCCEEDED(hr)) {
            DWORD err = PowerSetActiveScheme(NULL, &guid);
            if (err == ERROR_SUCCESS) {
                UCHAR friendlyName[256] = {0};
                DWORD friendlyNameSize = sizeof(friendlyName);
                PowerReadFriendlyName(NULL, &guid, NULL, NULL, friendlyName, &friendlyNameSize);
                QString name = QString::fromWCharArray((const wchar_t*)friendlyName);
                if (name.isEmpty()) name = finalTargetPowerSchemeVal;
                
                finalActiveSchemeGuid = finalTargetPowerSchemeVal;
                reportStep(QCoreApplication::translate("Optimizer", "Power plan changed to: %1").arg(name), "SUCCESS");
                Logger::log(QString("Power scheme successfully set active: %1").arg(name), "INFO");
            } else {
                success = false;
                reportStep(QCoreApplication::translate("Optimizer", "Failed to change power scheme."), "ERROR");
                Logger::log(QString("Failed to set active scheme: %1").arg(err), "ERROR");
            }
        } else {
            success = false;
            reportStep(QCoreApplication::translate("Optimizer", "Failed to change power scheme."), "ERROR");
        }
    }
#else
    finalActiveSchemeGuid = targetPowerSchemeGuid;
    reportStep(QCoreApplication::translate("Optimizer", "[Simulation] Power plan changed to: %1").arg(targetPowerSchemeGuid), "SUCCESS");
    Q_UNUSED(deleteUltimateStaged);
#endif

    return success;
}

bool PowerUsbManager::applyUsbPowerSaving(const QVariantList &usbDevices, 
                                        const QVariantList &originalUsbDevices, 
                                        std::function<void(const QString&, const QString&)> reportStep) {
    bool ok = true;
    reportStep(QCoreApplication::translate("Optimizer", "Configuring USB 3.0 Power Saving..."), "INFO");
    QThread::msleep(800);

#ifdef Q_OS_WIN
    for (int i = 0; i < usbDevices.size(); ++i) {
        QVariantMap deviceMap = usbDevices[i].toMap();
        QString subkeyPath = deviceMap["subkeyPath"].toString();
        bool targetVal = deviceMap["powerSavingActive"].toBool();
        bool originalVal = (i < originalUsbDevices.size()) ? originalUsbDevices[i].toMap()["powerSavingActive"].toBool() : !targetVal;
        
        if (targetVal != originalVal) {
            QString name = deviceMap["name"].toString();
            QString stateStr = targetVal ? QCoreApplication::translate("Optimizer", "Enabled") : QCoreApplication::translate("Optimizer", "Disabled");
            reportStep(QCoreApplication::translate("Optimizer", "Setting USB power saving for '%1' to %2...").arg(name).arg(stateStr), "INFO");
            
            bool writeSuccess = setUsbPowerSavingRegistry(subkeyPath, targetVal);
            if (writeSuccess) {
                if (targetVal) {
                    reportStep(QCoreApplication::translate("Optimizer", "Power saving enabled for '%1'.").arg(name), "SUCCESS");
                } else {
                    reportStep(QCoreApplication::translate("Optimizer", "Power saving disabled for '%1'.").arg(name), "SUCCESS");
                }
            } else {
                ok = false;
                if (targetVal) {
                    reportStep(QCoreApplication::translate("Optimizer", "Failed to enable power saving for '%1'.").arg(name), "ERROR");
                } else {
                    reportStep(QCoreApplication::translate("Optimizer", "Failed to disable power saving for '%1'.").arg(name), "ERROR");
                }
            }
        }
    }
#else
    Q_UNUSED(usbDevices);
    Q_UNUSED(originalUsbDevices);
#endif

    return ok;
}
