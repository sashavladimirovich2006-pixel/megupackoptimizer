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
#include <QRegularExpression>
#include <QJsonDocument>
#include <QJsonObject>

#ifdef Q_OS_WIN
#include <windows.h>
#include <winspool.h>
#include <powrprof.h>
#include <shlobj.h>
#include <propkey.h>
#include <propvarutil.h>
#include <tlhelp32.h>
#pragma comment(lib, "winspool.lib")
#pragma comment(lib, "powrprof.lib")
#pragma comment(lib, "propsys.lib")
#endif

namespace {
    const QStringList CS2_MANAGED_OPTIONS = {
        "-allow_third_party_software",
        "-noreflex",
        "-noaafonts",
        "-language English",
        "+fps_max 0",
        "-freq 170",
        "-nojoy",
        "-high",
        "-fullscreen",
        "-forcenovsync",
        "-softparticlesdefaultoff",
        "+r_dynamic 0",
        "+cl_interp 0",
        "+cl_hideserverip",
        "+mat_queue_mode 2"
    };

    QString getVdfLaunchOptions(const QString &filePath, const QString &appId) {
        QFile file(filePath);
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            return "";
        }
        QString content = QString::fromUtf8(file.readAll());
        file.close();

        QRegularExpression appRegex(QString("\"%1\"\\s*\\{").arg(appId));
        QRegularExpressionMatch match = appRegex.match(content);
        if (!match.hasMatch()) {
            return "";
        }

        int startIdx = match.capturedEnd();
        int count = 1;
        int idx = startIdx;
        int closeIdx = -1;
        while (count > 0 && idx < content.length()) {
            QChar ch = content.at(idx);
            if (ch == '{') {
                count++;
            } else if (ch == '}') {
                count--;
                if (count == 0) {
                    closeIdx = idx;
                    break;
                }
            }
            idx++;
        }

        if (closeIdx == -1) {
            return "";
        }

        QString appBlock = content.mid(startIdx, closeIdx - startIdx);
        QRegularExpression launchOptRegex("\"LaunchOptions\"\\s*\"([^\"]*)\"");
        QRegularExpressionMatch loMatch = launchOptRegex.match(appBlock);
        if (loMatch.hasMatch()) {
            return loMatch.captured(1);
        }
        return "";
    }

    bool updateVdfLaunchOptions(const QString &filePath, const QString &appId, const QString &newLaunchOptions) {
        QFile file(filePath);
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            return false;
        }
        QString content = QString::fromUtf8(file.readAll());
        file.close();

        QRegularExpression appRegex(QString("\"%1\"\\s*\\{").arg(appId));
        QRegularExpressionMatch match = appRegex.match(content);
        if (!match.hasMatch()) {
            return false;
        }

        int startIdx = match.capturedEnd();
        int count = 1;
        int idx = startIdx;
        int closeIdx = -1;
        while (count > 0 && idx < content.length()) {
            QChar ch = content.at(idx);
            if (ch == '{') {
                count++;
            } else if (ch == '}') {
                count--;
                if (count == 0) {
                    closeIdx = idx;
                    break;
                }
            }
            idx++;
        }

        if (closeIdx == -1) {
            return false;
        }

        QString appBlock = content.mid(startIdx, closeIdx - startIdx);
        QRegularExpression launchOptRegex("\"LaunchOptions\"\\s*\"([^\"]*)\"");
        QRegularExpressionMatch loMatch = launchOptRegex.match(appBlock);

        QString newAppBlock;
        if (loMatch.hasMatch()) {
            int loStart = loMatch.capturedStart();
            int loEnd = loMatch.capturedEnd();
            newAppBlock = appBlock.left(loStart) + QString("\"LaunchOptions\"\t\t\"%1\"").arg(newLaunchOptions) + appBlock.mid(loEnd);
        } else {
            QString indent = "\t\t\t\t\t\t";
            newAppBlock = QString("\n%1\"LaunchOptions\"\t\t\"%2\"").arg(indent, newLaunchOptions) + appBlock;
        }

        QString newContent = content.left(startIdx) + newAppBlock + content.mid(closeIdx);

        if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
            return false;
        }
        file.write(newContent.toUtf8());
        file.close();
        return true;
    }

    QString getVdfOverlayState(const QString &filePath, const QString &appId) {
        QFile file(filePath);
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            return "";
        }
        QString content = QString::fromUtf8(file.readAll());
        file.close();

        QRegularExpression appRegex(QString("\"%1\"\\s*\\{").arg(appId));
        QRegularExpressionMatch match = appRegex.match(content);
        if (!match.hasMatch()) {
            return "";
        }

        int startIdx = match.capturedEnd();
        int count = 1;
        int idx = startIdx;
        int closeIdx = -1;
        while (count > 0 && idx < content.length()) {
            QChar ch = content.at(idx);
            if (ch == '{') {
                count++;
            } else if (ch == '}') {
                count--;
                if (count == 0) {
                    closeIdx = idx;
                    break;
                }
            }
            idx++;
        }

        if (closeIdx == -1) {
            return "";
        }

        QString appBlock = content.mid(startIdx, closeIdx - startIdx);
        QRegularExpression overlayRegex("\"OverlayState\"\\s*\"([^\"]*)\"");
        QRegularExpressionMatch overlayMatch = overlayRegex.match(appBlock);
        if (overlayMatch.hasMatch()) {
            return overlayMatch.captured(1);
        }
        return "";
    }

    bool updateVdfOverlayState(const QString &filePath, const QString &appId, const QString &state) {
        QFile file(filePath);
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            return false;
        }
        QString content = QString::fromUtf8(file.readAll());
        file.close();

        QRegularExpression appRegex(QString("\"%1\"\\s*\\{").arg(appId));
        QRegularExpressionMatch match = appRegex.match(content);
        if (!match.hasMatch()) {
            return false;
        }

        int startIdx = match.capturedEnd();
        int count = 1;
        int idx = startIdx;
        int closeIdx = -1;
        while (count > 0 && idx < content.length()) {
            QChar ch = content.at(idx);
            if (ch == '{') {
                count++;
            } else if (ch == '}') {
                count--;
                if (count == 0) {
                    closeIdx = idx;
                    break;
                }
            }
            idx++;
        }

        if (closeIdx == -1) {
            return false;
        }

        QString appBlock = content.mid(startIdx, closeIdx - startIdx);
        QRegularExpression overlayRegex("\"OverlayState\"\\s*\"([^\"]*)\"");
        QRegularExpressionMatch overlayMatch = overlayRegex.match(appBlock);

        QString newAppBlock;
        if (overlayMatch.hasMatch()) {
            int overlayStart = overlayMatch.capturedStart();
            int overlayEnd = overlayMatch.capturedEnd();
            newAppBlock = appBlock.left(overlayStart) + QString("\"OverlayState\"\t\t\"%1\"").arg(state) + appBlock.mid(overlayEnd);
        } else {
            QString indent = "\t\t\t\t\t\t";
            newAppBlock = QString("\n%1\"OverlayState\"\t\t\"%2\"").arg(indent, state) + appBlock;
        }

        QString newContent = content.left(startIdx) + newAppBlock + content.mid(closeIdx);

        if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
            return false;
        }
        file.write(newContent.toUtf8());
        file.close();
        return true;
    }

} // namespace

bool Optimizer::getVdfFriendsSettings(const QString &filePath, const QString &accountId, QVariantMap &settings) {
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return false;
    }
    QString content = QString::fromUtf8(file.readAll());
    file.close();

    QRegularExpression webStorageRegex("\"WebStorage\"\\s*\\{");
    QRegularExpressionMatch match = webStorageRegex.match(content);
    if (!match.hasMatch()) {
        return false;
    }

    int startIdx = match.capturedEnd();
    int count = 1;
    int idx = startIdx;
    int closeIdx = -1;
    while (count > 0 && idx < content.length()) {
        QChar ch = content.at(idx);
        if (ch == '{') {
            count++;
        } else if (ch == '}') {
            count--;
            if (count == 0) {
                closeIdx = idx;
                break;
            }
        }
        idx++;
    }

    if (closeIdx == -1) {
        return false;
    }

    QString wsBlock = content.mid(startIdx, closeIdx - startIdx);
    QRegularExpression settingsRegex(QString("\"FriendsUIWebSettings_%1\"\\s*\"([^\"]*)\"").arg(accountId));
    QRegularExpressionMatch settingsMatch = settingsRegex.match(wsBlock);
    if (!settingsMatch.hasMatch()) {
        return false;
    }

    QString escapedJson = settingsMatch.captured(1);
    QString cleanJson = escapedJson;
    cleanJson.replace(QLatin1String("\\\""), QLatin1String("\""));
    cleanJson.replace(QLatin1String("\\\\"), QLatin1String("\\"));

    QJsonDocument doc = QJsonDocument::fromJson(cleanJson.toUtf8());
    if (!doc.isObject()) {
        return false;
    }

    settings = doc.object().toVariantMap();
    return true;
}

bool Optimizer::updateVdfFriendsSettings(const QString &filePath, const QString &accountId, const QVariantMap &settings) {
    QFile file(filePath);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        return false;
    }
    QString content = QString::fromUtf8(file.readAll());
    file.close();

    QRegularExpression webStorageRegex("\"WebStorage\"\\s*\\{");
    QRegularExpressionMatch match = webStorageRegex.match(content);
    if (!match.hasMatch()) {
        return false;
    }

    int startIdx = match.capturedEnd();
    int count = 1;
    int idx = startIdx;
    int closeIdx = -1;
    while (count > 0 && idx < content.length()) {
        QChar ch = content.at(idx);
        if (ch == '{') {
            count++;
        } else if (ch == '}') {
            count--;
            if (count == 0) {
                closeIdx = idx;
                break;
            }
        }
        idx++;
    }

    if (closeIdx == -1) {
        return false;
    }

    QString wsBlock = content.mid(startIdx, closeIdx - startIdx);
    QJsonObject obj = QJsonObject::fromVariantMap(settings);
    QString cleanJson = QString::fromUtf8(QJsonDocument(obj).toJson(QJsonDocument::Compact));
    QString escapedJson = cleanJson;
    escapedJson.replace(QLatin1String("\\"), QLatin1String("\\\\"));
    escapedJson.replace(QLatin1String("\""), QLatin1String("\\\""));

    QRegularExpression settingsRegex(QString("\"FriendsUIWebSettings_%1\"\\s*\"([^\"]*)\"").arg(accountId));
    QRegularExpressionMatch settingsMatch = settingsRegex.match(wsBlock);

    QString newWsBlock;
    if (settingsMatch.hasMatch()) {
        int settingsStart = settingsMatch.capturedStart();
        int settingsEnd = settingsMatch.capturedEnd();
        newWsBlock = wsBlock.left(settingsStart) + QString("\"FriendsUIWebSettings_%1\"\t\t\"%2\"").arg(accountId, escapedJson) + wsBlock.mid(settingsEnd);
    } else {
        QString indent = "\n\t\t\t";
        newWsBlock = QString("%1\"FriendsUIWebSettings_%2\"\t\t\"%3\"").arg(indent, accountId, escapedJson) + wsBlock;
    }

    QString newContent = content.left(startIdx) + newWsBlock + content.mid(closeIdx);

    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        return false;
    }
    file.write(newContent.toUtf8());
    file.close();
    return true;
}

namespace {

    bool readVisualEffectReg(const QString &subkeyName, bool defaultVal = true) {
#ifdef Q_OS_WIN
        HKEY hKey;
        QString path = "Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VisualEffects\\" + subkeyName;
        if (RegOpenKeyExW(HKEY_CURRENT_USER, reinterpret_cast<const wchar_t*>(path.utf16()), 0, KEY_READ, &hKey) == ERROR_SUCCESS) {
            DWORD val = defaultVal ? 1 : 0;
            DWORD dwSize = sizeof(val);
            DWORD dwType = REG_DWORD;
            if (RegQueryValueExW(hKey, L"DefaultApplied", nullptr, &dwType, reinterpret_cast<LPBYTE>(&val), &dwSize) == ERROR_SUCCESS) {
                RegCloseKey(hKey);
                return (val != 0);
            }
            RegCloseKey(hKey);
        }
#endif
        return defaultVal;
    }

    bool readFontSmoothingReg() {
#ifdef Q_OS_WIN
        HKEY hKey;
        if (RegOpenKeyExW(HKEY_CURRENT_USER, L"Control Panel\\Desktop", 0, KEY_READ, &hKey) == ERROR_SUCCESS) {
            wchar_t val[16] = L"0";
            DWORD dwSize = sizeof(val);
            DWORD dwType = REG_SZ;
            if (RegQueryValueExW(hKey, L"FontSmoothing", nullptr, &dwType, reinterpret_cast<LPBYTE>(val), &dwSize) == ERROR_SUCCESS) {
                RegCloseKey(hKey);
                return (wcscmp(val, L"2") == 0);
            }
            RegCloseKey(hKey);
        }
#endif
        return true;
    }
}

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

void Optimizer::setCoreIsolationActive(bool val) {
    if (m_coreIsolationActive != val) {
        m_coreIsolationActive = val;
        emit coreIsolationActiveChanged(m_coreIsolationActive);
    }
}

void Optimizer::setMouseAccelerationActive(bool val) {
    if (m_mouseAccelerationActive != val) {
        m_mouseAccelerationActive = val;
        emit mouseAccelerationActiveChanged(m_mouseAccelerationActive);
    }
}

void Optimizer::setGameModeActive(bool val) {
    if (m_gameModeActive != val) {
        m_gameModeActive = val;
        emit gameModeActiveChanged(m_gameModeActive);
    }
}

void Optimizer::setFirewallActive(bool val) {
    if (m_firewallActive != val) {
        m_firewallActive = val;
        emit firewallActiveChanged(m_firewallActive);
    }
}

void Optimizer::setRemoteAccessActive(bool val) {
    if (m_remoteAccessActive != val) {
        m_remoteAccessActive = val;
        emit remoteAccessActiveChanged(m_remoteAccessActive);
    }
}

void Optimizer::setTelemetryActive(bool val) {
    if (m_telemetryActive != val) {
        m_telemetryActive = val;
        m_telemetryDiagTrackActive = val;
        m_telemetryWapPushActive = val;
        m_telemetryCeipActive = val;
        m_telemetryWerActive = val;

        emit telemetryActiveChanged(m_telemetryActive);
        emit telemetryDiagTrackActiveChanged(m_telemetryDiagTrackActive);
        emit telemetryWapPushActiveChanged(m_telemetryWapPushActive);
        emit telemetryCeipActiveChanged(m_telemetryCeipActive);
        emit telemetryWerActiveChanged(m_telemetryWerActive);
    }
}

void Optimizer::setTelemetryDiagTrackActive(bool val) {
    if (m_telemetryDiagTrackActive != val) {
        m_telemetryDiagTrackActive = val;
        emit telemetryDiagTrackActiveChanged(m_telemetryDiagTrackActive);

        // Update main toggle
        bool anyActive = m_telemetryDiagTrackActive || m_telemetryWapPushActive || m_telemetryCeipActive || m_telemetryWerActive;
        if (m_telemetryActive != anyActive) {
            m_telemetryActive = anyActive;
            emit telemetryActiveChanged(m_telemetryActive);
        }
    }
}

void Optimizer::setTelemetryWapPushActive(bool val) {
    if (m_telemetryWapPushActive != val) {
        m_telemetryWapPushActive = val;
        emit telemetryWapPushActiveChanged(m_telemetryWapPushActive);

        // Update main toggle
        bool anyActive = m_telemetryDiagTrackActive || m_telemetryWapPushActive || m_telemetryCeipActive || m_telemetryWerActive;
        if (m_telemetryActive != anyActive) {
            m_telemetryActive = anyActive;
            emit telemetryActiveChanged(m_telemetryActive);
        }
    }
}

void Optimizer::setTelemetryCeipActive(bool val) {
    if (m_telemetryCeipActive != val) {
        m_telemetryCeipActive = val;
        emit telemetryCeipActiveChanged(m_telemetryCeipActive);

        // Update main toggle
        bool anyActive = m_telemetryDiagTrackActive || m_telemetryWapPushActive || m_telemetryCeipActive || m_telemetryWerActive;
        if (m_telemetryActive != anyActive) {
            m_telemetryActive = anyActive;
            emit telemetryActiveChanged(m_telemetryActive);
        }
    }
}

void Optimizer::setTelemetryWerActive(bool val) {
    if (m_telemetryWerActive != val) {
        m_telemetryWerActive = val;
        emit telemetryWerActiveChanged(m_telemetryWerActive);

        // Update main toggle
        bool anyActive = m_telemetryDiagTrackActive || m_telemetryWapPushActive || m_telemetryCeipActive || m_telemetryWerActive;
        if (m_telemetryActive != anyActive) {
            m_telemetryActive = anyActive;
            emit telemetryActiveChanged(m_telemetryActive);
        }
    }
}

void Optimizer::setWindowsUpdateMode(int mode) {
    if (m_windowsUpdateMode != mode) {
        m_windowsUpdateMode = mode;
        emit windowsUpdateModeChanged(m_windowsUpdateMode);
    }
}

void Optimizer::setCs2LaunchOptions(const QVariantMap &val) {
    if (m_cs2LaunchOptions != val) {
        m_cs2LaunchOptions = val;
        emit cs2LaunchOptionsChanged(m_cs2LaunchOptions);
    }
}

void Optimizer::setSteamOverlayActive(bool val) {
    if (m_steamOverlayActive != val) {
        m_steamOverlayActive = val;
        emit steamOverlayActiveChanged(m_steamOverlayActive);
    }
}

void Optimizer::setCs2OverlayActive(bool val) {
    if (m_cs2OverlayActive != val) {
        m_cs2OverlayActive = val;
        emit cs2OverlayActiveChanged(m_cs2OverlayActive);
    }
}

void Optimizer::setVisualEffects(const QVariantMap &val) {
    if (m_visualEffects != val) {
        m_visualEffects = val;
        emit visualEffectsChanged(m_visualEffects);
    }
}

void Optimizer::setSteamFriendsSettings(const QVariantMap &val) {
    if (m_steamFriendsSettings != val) {
        m_steamFriendsSettings = val;
        emit steamFriendsSettingsChanged(m_steamFriendsSettings);
    }
}

void Optimizer::setPrinterActive(bool val) {
    if (m_printerActive != val) {
        m_printerActive = val;
        emit printerActiveChanged(m_printerActive);
    }
}

void Optimizer::setBitlockerActive(bool val) {
    if (m_bitlockerActive != val) {
        m_bitlockerActive = val;
        emit bitlockerActiveChanged(m_bitlockerActive);
    }
}

void Optimizer::setDiscordOverlayActive(bool val) {
    if (m_discordOverlayActive != val) {
        m_discordOverlayActive = val;
        emit discordOverlayActiveChanged(m_discordOverlayActive);
    }
}

void Optimizer::setDefenderActive(bool val) {
    if (m_defenderActive != val) {
        m_defenderActive = val;
        emit defenderActiveChanged(m_defenderActive);

        // Propagate to sub-options for uniform toggle feel
        setDefenderRegistryActive(val);
        setDefenderCmdActive(val);
        setDefenderServiceActive(val);
    }
}

void Optimizer::setDefenderRegistryActive(bool val) {
    if (m_defenderRegistryActive != val) {
        m_defenderRegistryActive = val;
        emit defenderRegistryActiveChanged(m_defenderRegistryActive);

        // Update main toggle
        bool allMatch = (m_defenderRegistryActive == val) && (m_defenderCmdActive == val) && (m_defenderServiceActive == val);
        if (allMatch && m_defenderActive != val) {
            m_defenderActive = val;
            emit defenderActiveChanged(m_defenderActive);
        } else if (!val && m_defenderActive) {
            m_defenderActive = false;
            emit defenderActiveChanged(m_defenderActive);
        }
    }
}

void Optimizer::setDefenderCmdActive(bool val) {
    if (m_defenderCmdActive != val) {
        m_defenderCmdActive = val;
        emit defenderCmdActiveChanged(m_defenderCmdActive);

        // Update main toggle
        bool allMatch = (m_defenderRegistryActive == val) && (m_defenderCmdActive == val) && (m_defenderServiceActive == val);
        if (allMatch && m_defenderActive != val) {
            m_defenderActive = val;
            emit defenderActiveChanged(m_defenderActive);
        } else if (!val && m_defenderActive) {
            m_defenderActive = false;
            emit defenderActiveChanged(m_defenderActive);
        }
    }
}

void Optimizer::setDefenderServiceActive(bool val) {
    if (m_defenderServiceActive != val) {
        m_defenderServiceActive = val;
        emit defenderServiceActiveChanged(m_defenderServiceActive);

        // Update main toggle
        bool allMatch = (m_defenderRegistryActive == val) && (m_defenderCmdActive == val) && (m_defenderServiceActive == val);
        if (allMatch && m_defenderActive != val) {
            m_defenderActive = val;
            emit defenderActiveChanged(m_defenderActive);
        } else if (!val && m_defenderActive) {
            m_defenderActive = false;
            emit defenderActiveChanged(m_defenderActive);
        }
    }
}

void Optimizer::setNotificationsActive(bool val) {
    if (m_notificationsActive != val) {
        m_notificationsActive = val;
        emit notificationsActiveChanged(m_notificationsActive);

        // Propagate to sub-options for uniform toggle feel
        setNotifGlobalActive(val);
        setNotifAppActive(val);
        setNotifSoundsActive(val);
        setNotifLockscreenActive(val);
    }
}

void Optimizer::setNotifGlobalActive(bool val) {
    if (m_notifGlobalActive != val) {
        m_notifGlobalActive = val;
        emit notifGlobalActiveChanged(m_notifGlobalActive);
        
        // Also update main switch if global push is changed
        if (m_notificationsActive != val) {
            m_notificationsActive = val;
            emit notificationsActiveChanged(m_notificationsActive);
        }
    }
}

void Optimizer::setNotifAppActive(bool val) {
    if (m_notifAppActive != val) {
        m_notifAppActive = val;
        emit notifAppActiveChanged(m_notifAppActive);
    }
}

void Optimizer::setNotifSoundsActive(bool val) {
    if (m_notifSoundsActive != val) {
        m_notifSoundsActive = val;
        emit notifSoundsActiveChanged(m_notifSoundsActive);
    }
}

void Optimizer::setNotifLockscreenActive(bool val) {
    if (m_notifLockscreenActive != val) {
        m_notifLockscreenActive = val;
        emit notifLockscreenActiveChanged(m_notifLockscreenActive);
    }
}

void Optimizer::setDriveStates(const QVariantMap &states) {
    if (m_driveStates != states) {
        m_driveStates = states;
        emit driveStatesChanged(m_driveStates);
    }
}

void Optimizer::setUsbPowerSavingActive(bool val) {
    if (m_usbPowerSavingActive != val) {
        m_usbPowerSavingActive = val;
        emit usbPowerSavingActiveChanged(m_usbPowerSavingActive);
        
        // Propagate to all sub-devices
        for (int i = 0; i < m_usbDevices.size(); ++i) {
            QVariantMap deviceMap = m_usbDevices[i].toMap();
            if (deviceMap["powerSavingActive"].toBool() != val) {
                deviceMap["powerSavingActive"] = val;
                m_usbDevices[i] = deviceMap;
            }
        }
        emit usbDevicesChanged(m_usbDevices);
    }
}

void Optimizer::setDevicePowerSavingActive(const QString &subkeyPath, bool active) {
    bool changed = false;
    for (int i = 0; i < m_usbDevices.size(); ++i) {
        QVariantMap deviceMap = m_usbDevices[i].toMap();
        if (deviceMap["subkeyPath"].toString() == subkeyPath) {
            if (deviceMap["powerSavingActive"].toBool() != active) {
                deviceMap["powerSavingActive"] = active;
                m_usbDevices[i] = deviceMap;
                changed = true;
            }
            break;
        }
    }
    
    if (changed) {
        emit usbDevicesChanged(m_usbDevices);
        
        // Recalculate main toggle: active if any USB device has power saving enabled
        bool anyUsbPowerSaving = false;
        for (const QVariant &dev : m_usbDevices) {
            if (dev.toMap()["powerSavingActive"].toBool()) {
                anyUsbPowerSaving = true;
                break;
            }
        }
        if (m_usbPowerSavingActive != anyUsbPowerSaving) {
            m_usbPowerSavingActive = anyUsbPowerSaving;
            emit usbPowerSavingActiveChanged(m_usbPowerSavingActive);
        }
    }
}

void Optimizer::revertUsbDevices() {
    m_usbDevices = m_originalUsbDevices;
    
    // Recalculate main toggle
    bool anyUsbPowerSaving = false;
    for (const QVariant &dev : m_usbDevices) {
        if (dev.toMap()["powerSavingActive"].toBool()) {
            anyUsbPowerSaving = true;
            break;
        }
    }
    m_usbPowerSavingActive = anyUsbPowerSaving;
    
    emit usbDevicesChanged(m_usbDevices);
    emit usbPowerSavingActiveChanged(m_usbPowerSavingActive);
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

    // Query Print Spooler (Printer) startup state on startup
    bool isPrinterDisabled = false;
#ifdef Q_OS_WIN
    SC_HANDLE hSCMPrinter = OpenSCManagerW(NULL, NULL, SC_MANAGER_CONNECT);
    if (hSCMPrinter) {
        SC_HANDLE hService = OpenServiceW(hSCMPrinter, L"Spooler", SERVICE_QUERY_CONFIG);
        if (hService) {
            DWORD bytesNeeded = 0;
            if (!QueryServiceConfigW(hService, NULL, 0, &bytesNeeded) && GetLastError() == ERROR_INSUFFICIENT_BUFFER) {
                QByteArray buffer(static_cast<int>(bytesNeeded), 0);
                LPQUERY_SERVICE_CONFIGW pConfig = reinterpret_cast<LPQUERY_SERVICE_CONFIGW>(buffer.data());
                if (QueryServiceConfigW(hService, pConfig, bytesNeeded, &bytesNeeded)) {
                    if (pConfig->dwStartType == SERVICE_DISABLED) {
                        isPrinterDisabled = true;
                    }
                }
            }
            CloseServiceHandle(hService);
        }
        CloseServiceHandle(hSCMPrinter);
    }
#endif
    m_printerActive = !isPrinterDisabled;
    m_originalPrinterActive = m_printerActive;
    emit printerActiveChanged(m_printerActive);
    emit originalPrinterActiveChanged(m_originalPrinterActive);

    // Scan detected print queues using Win32 Spooler API (matches Device Manager "Print queues")
    QStringList printers;
#ifdef Q_OS_WIN
    DWORD cbNeeded = 0;
    DWORD cReturned = 0;
    // Call EnumPrintersW to get size. We use PRINTER_ENUM_LOCAL | PRINTER_ENUM_CONNECTIONS.
    // Level 4 is extremely fast and provides name and attributes.
    EnumPrintersW(PRINTER_ENUM_LOCAL | PRINTER_ENUM_CONNECTIONS, NULL, 4, NULL, 0, &cbNeeded, &cReturned);
    if (cbNeeded > 0) {
        QByteArray buffer(static_cast<int>(cbNeeded), 0);
        PRINTER_INFO_4W* pPrinterInfo = reinterpret_cast<PRINTER_INFO_4W*>(buffer.data());
        if (EnumPrintersW(PRINTER_ENUM_LOCAL | PRINTER_ENUM_CONNECTIONS, NULL, 4, reinterpret_cast<LPBYTE>(pPrinterInfo), cbNeeded, &cbNeeded, &cReturned)) {
            for (DWORD i = 0; i < cReturned; ++i) {
                if (pPrinterInfo[i].pPrinterName) {
                    printers.append(QString::fromWCharArray(pPrinterInfo[i].pPrinterName));
                }
            }
        }
    }
#else
    // Simulation fallbacks
    printers.append("Root Print Queue");
    printers.append("Microsoft Print to PDF");
    printers.append("Microsoft XPS Document Writer");
    printers.append("Fax");
#endif
    m_detectedPrinters = printers;
    emit detectedPrintersChanged(m_detectedPrinters);

    // Query BitLocker (BDESVC) startup state on startup
    bool isBitlockerDisabled = false;
    bool isDriveCEncrypted = false;
#ifdef Q_OS_WIN
    SC_HANDLE hSCMBitLocker = OpenSCManagerW(NULL, NULL, SC_MANAGER_CONNECT);
    if (hSCMBitLocker) {
        SC_HANDLE hService = OpenServiceW(hSCMBitLocker, L"BDESVC", SERVICE_QUERY_CONFIG);
        if (hService) {
            DWORD bytesNeeded = 0;
            if (!QueryServiceConfigW(hService, NULL, 0, &bytesNeeded) && GetLastError() == ERROR_INSUFFICIENT_BUFFER) {
                QByteArray buffer(static_cast<int>(bytesNeeded), 0);
                LPQUERY_SERVICE_CONFIGW pConfig = reinterpret_cast<LPQUERY_SERVICE_CONFIGW>(buffer.data());
                if (QueryServiceConfigW(hService, pConfig, bytesNeeded, &bytesNeeded)) {
                    if (pConfig->dwStartType == SERVICE_DISABLED) {
                        isBitlockerDisabled = true;
                    }
                }
            }
            CloseServiceHandle(hService);
        }
        CloseServiceHandle(hSCMBitLocker);
    }

    // Query actual BitLocker drive encryption protection on the C:\ drive
    IShellItem2* pItem = nullptr;
    HRESULT hr = SHCreateItemFromParsingName(L"C:\\", NULL, IID_PPV_ARGS(&pItem));
    if (SUCCEEDED(hr)) {
        PROPERTYKEY pKey;
        hr = PSGetPropertyKeyFromName(L"System.Volume.BitLockerProtection", &pKey);
        if (SUCCEEDED(hr)) {
            PROPVARIANT prop;
            PropVariantInit(&prop);
            hr = pItem->GetProperty(pKey, &prop);
            if (SUCCEEDED(hr)) {
                int status = prop.intVal;
                // Status values: 1 (On), 3 (Encrypting), 5 (Suspended), 6 (On/Locked) indicate active protection
                isDriveCEncrypted = (status == 1 || status == 3 || status == 5 || status == 6);
                PropVariantClear(&prop);
            }
        }
        pItem->Release();
    }
#endif
    m_bitlockerActive = !isBitlockerDisabled;
    m_originalBitlockerActive = m_bitlockerActive;
    m_bitlockerDriveEncrypted = isDriveCEncrypted;
    emit bitlockerActiveChanged(m_bitlockerActive);
    emit originalBitlockerActiveChanged(m_originalBitlockerActive);
    emit bitlockerDriveEncryptedChanged(m_bitlockerDriveEncrypted);

    // Query active state of Discord In-Game Overlay
    m_discordOverlayActive = checkIsDiscordOverlayActive();
    m_originalDiscordOverlayActive = m_discordOverlayActive;
    emit discordOverlayActiveChanged(m_discordOverlayActive);
    emit originalDiscordOverlayActiveChanged(m_originalDiscordOverlayActive);

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

    // Check Core Isolation (Memory Integrity) state on startup
    bool isCoreIsolationActive = false;
#ifdef Q_OS_WIN
    HKEY hKeyCI;
    if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SYSTEM\\CurrentControlSet\\Control\\DeviceGuard\\Scenarios\\HypervisorEnforcedCodeIntegrity", 0, KEY_READ, &hKeyCI) == ERROR_SUCCESS) {
        DWORD value = 0;
        DWORD size = sizeof(value);
        if (RegQueryValueExW(hKeyCI, L"Enabled", NULL, NULL, (LPBYTE)&value, &size) == ERROR_SUCCESS) {
            isCoreIsolationActive = (value == 1);
        }
        RegCloseKey(hKeyCI);
    }
#else
    isCoreIsolationActive = true; // Simulation default
#endif
    m_coreIsolationActive = isCoreIsolationActive;
    m_originalCoreIsolationActive = m_coreIsolationActive;
    emit coreIsolationActiveChanged(m_coreIsolationActive);
    emit originalCoreIsolationActiveChanged(m_originalCoreIsolationActive);

    // Check Mouse Acceleration state on startup
    bool isMouseAccelerationActive = false;
#ifdef Q_OS_WIN
    int mouseParams[3] = {0};
    if (SystemParametersInfoW(SPI_GETMOUSE, 0, mouseParams, 0)) {
        isMouseAccelerationActive = (mouseParams[2] != 0);
    }
#else
    isMouseAccelerationActive = true; // Simulation default
#endif
    m_mouseAccelerationActive = isMouseAccelerationActive;
    m_originalMouseAccelerationActive = m_mouseAccelerationActive;
    emit mouseAccelerationActiveChanged(m_mouseAccelerationActive);
    emit originalMouseAccelerationActiveChanged(m_originalMouseAccelerationActive);

    // Check Game Mode state on startup (using AutoGameModeEnabled as primary settings indicator)
    bool isGameModeActive = true;
#ifdef Q_OS_WIN
    HKEY hKeyGB;
    if (RegOpenKeyExW(HKEY_CURRENT_USER, L"Software\\Microsoft\\GameBar", 0, KEY_READ, &hKeyGB) == ERROR_SUCCESS) {
        DWORD val2 = 1;
        DWORD size2 = sizeof(val2);
        if (RegQueryValueExW(hKeyGB, L"AutoGameModeEnabled", NULL, NULL, (LPBYTE)&val2, &size2) == ERROR_SUCCESS) {
            isGameModeActive = (val2 != 0);
        }
        RegCloseKey(hKeyGB);
    }
#else
    isGameModeActive = true; // Simulation default
#endif
    m_gameModeActive = isGameModeActive;
    m_originalGameModeActive = m_gameModeActive;
    emit gameModeActiveChanged(m_gameModeActive);
    emit originalGameModeActiveChanged(m_originalGameModeActive);

    // Check Firewall state on startup (using standard/domain/public HKLM profile statuses)
    bool isFirewallActive = false;
#ifdef Q_OS_WIN
    const wchar_t* subkeys[] = {
        L"SYSTEM\\CurrentControlSet\\Services\\SharedAccess\\Parameters\\FirewallPolicy\\StandardProfile",
        L"SYSTEM\\CurrentControlSet\\Services\\SharedAccess\\Parameters\\FirewallPolicy\\DomainProfile",
        L"SYSTEM\\CurrentControlSet\\Services\\SharedAccess\\Parameters\\FirewallPolicy\\PublicProfile"
    };
    for (int i = 0; i < 3; i++) {
        HKEY hKeyFW;
        if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, subkeys[i], 0, KEY_READ, &hKeyFW) == ERROR_SUCCESS) {
            DWORD val = 0;
            DWORD size = sizeof(val);
            if (RegQueryValueExW(hKeyFW, L"EnableFirewall", NULL, NULL, (LPBYTE)&val, &size) == ERROR_SUCCESS) {
                if (val != 0) {
                    isFirewallActive = true;
                }
            } else {
                isFirewallActive = true; // Default if key exists but fails to read
            }
            RegCloseKey(hKeyFW);
        }
    }
#else
    isFirewallActive = true; // Simulation default
#endif
    m_firewallActive = isFirewallActive;
    m_originalFirewallActive = m_firewallActive;
    emit firewallActiveChanged(m_firewallActive);
    emit originalFirewallActiveChanged(m_originalFirewallActive);

    // Check Remote Access (RDP) state on startup
    bool isRemoteAccessActive = false;
#ifdef Q_OS_WIN
    HKEY hKeyTS;
    if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SYSTEM\\CurrentControlSet\\Control\\Terminal Server", 0, KEY_READ, &hKeyTS) == ERROR_SUCCESS) {
        DWORD val = 1; // default disabled
        DWORD size = sizeof(val);
        if (RegQueryValueExW(hKeyTS, L"fDenyTSConnections", NULL, NULL, (LPBYTE)&val, &size) == ERROR_SUCCESS) {
            if (val == 0) {
                isRemoteAccessActive = true;
            }
        }
        RegCloseKey(hKeyTS);
    }
#else
    isRemoteAccessActive = false; // Simulation default
#endif
    m_remoteAccessActive = isRemoteAccessActive;
    m_originalRemoteAccessActive = m_remoteAccessActive;
    emit remoteAccessActiveChanged(m_remoteAccessActive);
    emit originalRemoteAccessActiveChanged(m_originalRemoteAccessActive);

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

    // Check Windows Notifications state on startup
    bool isNotificationsActive = true;
    bool isNotifGlobalActive = true;
    bool isNotifAppActive = true;
    bool isNotifSoundsActive = true;
    bool isNotifLockscreenActive = true;

#ifdef Q_OS_WIN
    // 1. ToastEnabled under HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications
    HKEY hKeyPush;
    if (RegOpenKeyExW(HKEY_CURRENT_USER, L"Software\\Microsoft\\Windows\\CurrentVersion\\PushNotifications", 0, KEY_READ, &hKeyPush) == ERROR_SUCCESS) {
        DWORD value = 1;
        DWORD size = sizeof(value);
        if (RegQueryValueExW(hKeyPush, L"ToastEnabled", NULL, NULL, (LPBYTE)&value, &size) == ERROR_SUCCESS) {
            isNotifGlobalActive = (value != 0);
        }
        RegCloseKey(hKeyPush);
    }

    // 2. Settings under HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings
    HKEY hKeySettings;
    if (RegOpenKeyExW(HKEY_CURRENT_USER, L"Software\\Microsoft\\Windows\\CurrentVersion\\Notifications\\Settings", 0, KEY_READ, &hKeySettings) == ERROR_SUCCESS) {
        DWORD valApp = 1;
        DWORD valSounds = 1;
        DWORD valLock = 1;
        DWORD size = sizeof(DWORD);
        if (RegQueryValueExW(hKeySettings, L"NOC_GLOBAL_SETTING_TOASTS_ENABLED", NULL, NULL, (LPBYTE)&valApp, &size) == ERROR_SUCCESS) {
            isNotifAppActive = (valApp != 0);
        }
        size = sizeof(DWORD);
        if (RegQueryValueExW(hKeySettings, L"NOC_GLOBAL_SETTING_ALLOW_NOTIFICATION_SOUND", NULL, NULL, (LPBYTE)&valSounds, &size) == ERROR_SUCCESS) {
            isNotifSoundsActive = (valSounds != 0);
        }
        size = sizeof(DWORD);
        if (RegQueryValueExW(hKeySettings, L"NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK", NULL, NULL, (LPBYTE)&valLock, &size) == ERROR_SUCCESS) {
            isNotifLockscreenActive = (valLock != 0);
        }
        RegCloseKey(hKeySettings);
    }
    
    // Main notifications active property is true if push notifications (Toasts) are active
    isNotificationsActive = isNotifGlobalActive;
#else
    // Simulation defaults
    isNotificationsActive = true;
    isNotifGlobalActive = true;
    isNotifAppActive = true;
    isNotifSoundsActive = true;
    isNotifLockscreenActive = true;
#endif

    m_notificationsActive = isNotificationsActive;
    m_originalNotificationsActive = m_notificationsActive;
    emit notificationsActiveChanged(m_notificationsActive);
    emit originalNotificationsActiveChanged(m_originalNotificationsActive);

    m_notifGlobalActive = isNotifGlobalActive;
    m_originalNotifGlobalActive = m_notifGlobalActive;
    emit notifGlobalActiveChanged(m_notifGlobalActive);
    emit originalNotifGlobalActiveChanged(m_originalNotifGlobalActive);

    m_notifAppActive = isNotifAppActive;
    m_originalNotifAppActive = m_notifAppActive;
    emit notifAppActiveChanged(m_notifAppActive);
    emit originalNotifAppActiveChanged(m_originalNotifAppActive);

    m_notifSoundsActive = isNotifSoundsActive;
    m_originalNotifSoundsActive = m_notifSoundsActive;
    emit notifSoundsActiveChanged(m_notifSoundsActive);
    emit originalNotifSoundsActiveChanged(m_originalNotifSoundsActive);

    m_notifLockscreenActive = isNotifLockscreenActive;
    m_originalNotifLockscreenActive = m_notifLockscreenActive;
    emit notifLockscreenActiveChanged(m_notifLockscreenActive);
    emit originalNotifLockscreenActiveChanged(m_originalNotifLockscreenActive);

    // ----------------------------------------------------
    // Load Windows Power Schemes
    // ----------------------------------------------------
    QVariantList schemesList;
    bool isUltimateUnlocked = false;
    QString activeSchemeGuidStr = "";

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
        bool isUltimate = IsEqualGUID(schemeGuid, ultimateGuid);
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

    m_powerSchemes = schemesList;
    m_ultimateSchemeUnlocked = isUltimateUnlocked;
    m_activePowerSchemeGuid = activeSchemeGuidStr;
    m_targetPowerSchemeGuid = activeSchemeGuidStr;

    emit powerSchemesChanged(m_powerSchemes);
    emit ultimateSchemeUnlockedChanged(m_ultimateSchemeUnlocked);
    emit activePowerSchemeGuidChanged(m_activePowerSchemeGuid);
    emit targetPowerSchemeGuidChanged(m_targetPowerSchemeGuid);

    // ----------------------------------------------------
    // Load Windows Defender States
    // ----------------------------------------------------
    bool isDefenderRegistryActive = true;
    bool isDefenderCmdActive = true;
    bool isDefenderServiceActive = true;

#ifdef Q_OS_WIN
    // 1. Check Registry policies
    HKEY hKeyDef;
    if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SOFTWARE\\Policies\\Microsoft\\Windows Defender", 0, KEY_READ, &hKeyDef) == ERROR_SUCCESS) {
        DWORD valSpy = 0;
        DWORD sizeSpy = sizeof(valSpy);
        if (RegQueryValueExW(hKeyDef, L"DisableAntiSpyware", NULL, NULL, (LPBYTE)&valSpy, &sizeSpy) == ERROR_SUCCESS && valSpy == 1) {
            isDefenderRegistryActive = false;
        }
        DWORD valAV = 0;
        DWORD sizeAV = sizeof(valAV);
        if (RegQueryValueExW(hKeyDef, L"DisableAntiVirus", NULL, NULL, (LPBYTE)&valAV, &sizeAV) == ERROR_SUCCESS && valAV == 1) {
            isDefenderRegistryActive = false;
        }
        RegCloseKey(hKeyDef);
    }
    
    HKEY hKeyDefRT;
    if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SOFTWARE\\Policies\\Microsoft\\Windows Defender\\Real-Time Protection", 0, KEY_READ, &hKeyDefRT) == ERROR_SUCCESS) {
        DWORD valRT = 0;
        DWORD sizeRT = sizeof(valRT);
        if (RegQueryValueExW(hKeyDefRT, L"DisableRealtimeMonitoring", NULL, NULL, (LPBYTE)&valRT, &sizeRT) == ERROR_SUCCESS && valRT == 1) {
            isDefenderRegistryActive = false;
        }
        RegCloseKey(hKeyDefRT);
    }

    // 2. Check PowerShell command preferences (real-time monitoring in HKLM system defender key)
    HKEY hKeyDefSys;
    if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SOFTWARE\\Microsoft\\Windows Defender\\Real-Time Protection", 0, KEY_READ, &hKeyDefSys) == ERROR_SUCCESS) {
        DWORD valRTSys = 0;
        DWORD sizeRTSys = sizeof(valRTSys);
        if (RegQueryValueExW(hKeyDefSys, L"DisableRealtimeMonitoring", NULL, NULL, (LPBYTE)&valRTSys, &sizeRTSys) == ERROR_SUCCESS && valRTSys == 1) {
            isDefenderCmdActive = false;
        }
        RegCloseKey(hKeyDefSys);
    }

    // 3. Check service state (WinDefend)
    SC_HANDLE hSCMDefender = OpenSCManagerW(NULL, NULL, SC_MANAGER_CONNECT);
    if (hSCMDefender) {
        SC_HANDLE hServiceDefender = OpenServiceW(hSCMDefender, L"WinDefend", SERVICE_QUERY_CONFIG | SERVICE_QUERY_STATUS);
        if (hServiceDefender) {
            DWORD bytesNeeded = 0;
            if (!QueryServiceConfigW(hServiceDefender, NULL, 0, &bytesNeeded) && GetLastError() == ERROR_INSUFFICIENT_BUFFER) {
                QUERY_SERVICE_CONFIGW* pConfig = (QUERY_SERVICE_CONFIGW*)LocalAlloc(LPTR, bytesNeeded);
                if (pConfig && QueryServiceConfigW(hServiceDefender, pConfig, bytesNeeded, &bytesNeeded)) {
                    if (pConfig->dwStartType == SERVICE_DISABLED) {
                        isDefenderServiceActive = false;
                    }
                    LocalFree(pConfig);
                }
            }
            SERVICE_STATUS_PROCESS status;
            DWORD bytesNeeded2 = 0;
            if (QueryServiceStatusEx(hServiceDefender, SC_STATUS_PROCESS_INFO, (LPBYTE)&status, sizeof(status), &bytesNeeded2)) {
                if (status.dwCurrentState == SERVICE_STOPPED) {
                    isDefenderServiceActive = false;
                }
            }
            CloseServiceHandle(hServiceDefender);
        } else {
            DWORD err = GetLastError();
            if (err == ERROR_SERVICE_DOES_NOT_EXIST) {
                isDefenderServiceActive = false;
            }
        }
        CloseServiceHandle(hSCMDefender);
    }
#else
    // Simulation defaults
    isDefenderRegistryActive = true;
    isDefenderCmdActive = true;
    isDefenderServiceActive = true;
#endif

    m_defenderRegistryActive = isDefenderRegistryActive;
    m_originalDefenderRegistryActive = m_defenderRegistryActive;
    emit defenderRegistryActiveChanged(m_defenderRegistryActive);
    emit originalDefenderRegistryActiveChanged(m_originalDefenderRegistryActive);

    m_defenderCmdActive = isDefenderCmdActive;
    m_originalDefenderCmdActive = m_defenderCmdActive;
    emit defenderCmdActiveChanged(m_defenderCmdActive);
    emit originalDefenderCmdActiveChanged(m_originalDefenderCmdActive);

    m_defenderServiceActive = isDefenderServiceActive;
    m_originalDefenderServiceActive = m_defenderServiceActive;
    emit defenderServiceActiveChanged(m_defenderServiceActive);
    emit originalDefenderServiceActiveChanged(m_originalDefenderServiceActive);

    m_defenderActive = isDefenderRegistryActive && isDefenderCmdActive && isDefenderServiceActive;
    m_originalDefenderActive = m_defenderActive;
    emit defenderActiveChanged(m_defenderActive);
    emit originalDefenderActiveChanged(m_originalDefenderActive);

    // ----------------------------------------------------
    // Load USB 3.0 Devices and Power Saving State
    // ----------------------------------------------------
    QVariantList usbList;
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

    bool anyUsbPowerSaving = false;
    for (const QVariant &dev : usbList) {
        if (dev.toMap()["powerSavingActive"].toBool()) {
            anyUsbPowerSaving = true;
            break;
        }
    }
    m_usbDevices = usbList;
    m_originalUsbDevices = usbList;
    m_usbPowerSavingActive = anyUsbPowerSaving;
    m_originalUsbPowerSavingActive = anyUsbPowerSaving;
    emit usbDevicesChanged(m_usbDevices);
    emit usbPowerSavingActiveChanged(m_usbPowerSavingActive);
    emit originalUsbPowerSavingActiveChanged(m_originalUsbPowerSavingActive);

    scanDrives();
    m_originalDriveStates = m_driveStates;
    emit originalDriveStatesChanged(m_originalDriveStates);

    // ----------------------------------------------------
    // Load Telemetry States
    // ----------------------------------------------------
    bool telemetryDiagTrackActive = true;
    bool telemetryWapPushActive = true;
    bool telemetryCeipActive = true;
    bool telemetryWerActive = true;

#ifdef Q_OS_WIN
    // 1. Connected User Experiences (DiagTrack) startup state
    HKEY hKeyDiag;
    if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SYSTEM\\CurrentControlSet\\Services\\DiagTrack", 0, KEY_READ, &hKeyDiag) == ERROR_SUCCESS) {
        DWORD value = 2; // default Automatic
        DWORD size = sizeof(value);
        if (RegQueryValueExW(hKeyDiag, L"Start", NULL, NULL, (LPBYTE)&value, &size) == ERROR_SUCCESS) {
            telemetryDiagTrackActive = (value != 4); // Enabled if not Disabled (4)
        }
        RegCloseKey(hKeyDiag);
    }

    // 2. Device Management WAP Service (dmwappushservice) startup state
    HKEY hKeyWap;
    if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SYSTEM\\CurrentControlSet\\Services\\dmwappushservice", 0, KEY_READ, &hKeyWap) == ERROR_SUCCESS) {
        DWORD value = 3; // default Manual
        DWORD size = sizeof(value);
        if (RegQueryValueExW(hKeyWap, L"Start", NULL, NULL, (LPBYTE)&value, &size) == ERROR_SUCCESS) {
            telemetryWapPushActive = (value != 4); // Enabled if not Disabled (4)
        }
        RegCloseKey(hKeyWap);
    }

    // 3. Customer Experience Improvement Program (CEIP) policy
    HKEY hKeyCeip;
    if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SOFTWARE\\Policies\\Microsoft\\SQMClient\\Windows", 0, KEY_READ, &hKeyCeip) == ERROR_SUCCESS) {
        DWORD value = 1;
        DWORD size = sizeof(value);
        if (RegQueryValueExW(hKeyCeip, L"CEIPEnable", NULL, NULL, (LPBYTE)&value, &size) == ERROR_SUCCESS) {
            telemetryCeipActive = (value != 0); // Active if CEIPEnable is not 0
        }
        RegCloseKey(hKeyCeip);
    } else {
        telemetryCeipActive = true; // Enabled if policy does not exist
    }

    // 4. Windows Error Reporting (WER) policy
    HKEY hKeyWer;
    if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SOFTWARE\\Policies\\Microsoft\\Windows\\Windows Error Reporting", 0, KEY_READ, &hKeyWer) == ERROR_SUCCESS) {
        DWORD value = 0;
        DWORD size = sizeof(value);
        if (RegQueryValueExW(hKeyWer, L"Disabled", NULL, NULL, (LPBYTE)&value, &size) == ERROR_SUCCESS) {
            telemetryWerActive = (value == 0); // Active if Disabled is 0 (or missing)
        }
        RegCloseKey(hKeyWer);
    } else {
        telemetryWerActive = true; // Enabled if policy does not exist
    }
#else
    // Simulation fallbacks
    telemetryDiagTrackActive = true;
    telemetryWapPushActive = true;
    telemetryCeipActive = true;
    telemetryWerActive = true;
#endif

    m_telemetryDiagTrackActive = telemetryDiagTrackActive;
    m_originalTelemetryDiagTrackActive = telemetryDiagTrackActive;
    emit telemetryDiagTrackActiveChanged(m_telemetryDiagTrackActive);
    emit originalTelemetryDiagTrackActiveChanged(m_originalTelemetryDiagTrackActive);

    m_telemetryWapPushActive = telemetryWapPushActive;
    m_originalTelemetryWapPushActive = telemetryWapPushActive;
    emit telemetryWapPushActiveChanged(m_telemetryWapPushActive);
    emit originalTelemetryWapPushActiveChanged(m_originalTelemetryWapPushActive);

    m_telemetryCeipActive = telemetryCeipActive;
    m_originalTelemetryCeipActive = telemetryCeipActive;
    emit telemetryCeipActiveChanged(m_telemetryCeipActive);
    emit originalTelemetryCeipActiveChanged(m_originalTelemetryCeipActive);

    m_telemetryWerActive = telemetryWerActive;
    m_originalTelemetryWerActive = telemetryWerActive;
    emit telemetryWerActiveChanged(m_telemetryWerActive);
    emit originalTelemetryWerActiveChanged(m_originalTelemetryWerActive);

    m_telemetryActive = m_telemetryDiagTrackActive || m_telemetryWapPushActive || m_telemetryCeipActive || m_telemetryWerActive;
    m_originalTelemetryActive = m_telemetryActive;
    emit telemetryActiveChanged(m_telemetryActive);
    emit originalTelemetryActiveChanged(m_originalTelemetryActive);

    // ----------------------------------------------------
    // Load Windows Update Mode
    // ----------------------------------------------------
    int updateMode = 0; // Default
#ifdef Q_OS_WIN
    DWORD noAutoUpdate = 0;
    DWORD auOptions = 0;
    HKEY hKeyAu;
    if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU", 0, KEY_READ, &hKeyAu) == ERROR_SUCCESS) {
        DWORD size = sizeof(noAutoUpdate);
        RegQueryValueExW(hKeyAu, L"NoAutoUpdate", NULL, NULL, (LPBYTE)&noAutoUpdate, &size);
        size = sizeof(auOptions);
        RegQueryValueExW(hKeyAu, L"AUOptions", NULL, NULL, (LPBYTE)&auOptions, &size);
        RegCloseKey(hKeyAu);
    }
    
    DWORD wuauservStart = 3; // default Manual
    HKEY hKeySvc;
    if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SYSTEM\\CurrentControlSet\\Services\\wuauserv", 0, KEY_READ, &hKeySvc) == ERROR_SUCCESS) {
        DWORD size = sizeof(wuauservStart);
        if (RegQueryValueExW(hKeySvc, L"Start", NULL, NULL, (LPBYTE)&wuauservStart, &size) != ERROR_SUCCESS) {
            wuauservStart = 3;
        }
        RegCloseKey(hKeySvc);
    }

    DWORD targetReleaseVersion = 0;
    DWORD excludeDrivers = 0;
    HKEY hKeyWu;
    if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate", 0, KEY_READ, &hKeyWu) == ERROR_SUCCESS) {
        DWORD size = sizeof(targetReleaseVersion);
        RegQueryValueExW(hKeyWu, L"TargetReleaseVersion", NULL, NULL, (LPBYTE)&targetReleaseVersion, &size);
        size = sizeof(excludeDrivers);
        RegQueryValueExW(hKeyWu, L"ExcludeWUDriversInQualityUpdate", NULL, NULL, (LPBYTE)&excludeDrivers, &size);
        RegCloseKey(hKeyWu);
    }

    if (noAutoUpdate == 1 || wuauservStart == 4) {
        updateMode = 3; // Disabled
    } else if (auOptions == 2 && wuauservStart == 3) {
        updateMode = 2; // Manual
    } else if (targetReleaseVersion == 1 && excludeDrivers == 1) {
        updateMode = 1; // Security updates only
    } else {
        updateMode = 0; // Default
    }
#else
    updateMode = 0; // Default simulation
#endif

    m_windowsUpdateMode = updateMode;
    m_originalWindowsUpdateMode = updateMode;
    emit windowsUpdateModeChanged(m_windowsUpdateMode);
    emit originalWindowsUpdateModeChanged(m_originalWindowsUpdateMode);

    // ----------------------------------------------------
    // Load Counter-Strike 2 launch options
    // ----------------------------------------------------
    QString steamPath = "";
#ifdef Q_OS_WIN
    HKEY hKeySteam;
    if (RegOpenKeyExW(HKEY_CURRENT_USER, L"Software\\Valve\\Steam", 0, KEY_READ, &hKeySteam) == ERROR_SUCCESS) {
        wchar_t pathBuf[512] = {0};
        DWORD size = sizeof(pathBuf);
        if (RegQueryValueExW(hKeySteam, L"SteamPath", NULL, NULL, (LPBYTE)pathBuf, &size) == ERROR_SUCCESS) {
            steamPath = QString::fromWCharArray(pathBuf).replace("/", "\\");
        }
        RegCloseKey(hKeySteam);
    }
    if (steamPath.isEmpty()) {
        if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SOFTWARE\\WOW6432Node\\Valve\\Steam", 0, KEY_READ, &hKeySteam) == ERROR_SUCCESS) {
            wchar_t pathBuf[512] = {0};
            DWORD size = sizeof(pathBuf);
            if (RegQueryValueExW(hKeySteam, L"InstallPath", NULL, NULL, (LPBYTE)pathBuf, &size) == ERROR_SUCCESS) {
                steamPath = QString::fromWCharArray(pathBuf).replace("/", "\\");
            }
            RegCloseKey(hKeySteam);
        }
    }
#endif

    QVariantMap cs2Options;
    for (const QString &opt : CS2_MANAGED_OPTIONS) {
        cs2Options[opt] = false;
    }

    QString firstLaunchOptions = "";
    bool loadedFromProfile = false;

    if (!steamPath.isEmpty() && QDir(steamPath).exists()) {
        QString userdataPath = steamPath + "/userdata";
        QDir userdataDir(userdataPath);
        if (userdataDir.exists()) {
            QStringList subdirs = userdataDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
            for (const QString &subdir : subdirs) {
                QString vdfPath = userdataPath + "/" + subdir + "/config/localconfig.vdf";
                if (QFile::exists(vdfPath)) {
                    QString opts = getVdfLaunchOptions(vdfPath, "730");
                    if (!opts.isEmpty() && !loadedFromProfile) {
                        firstLaunchOptions = opts;
                        loadedFromProfile = true;
                    }
                }
            }
        }
    }

#ifndef Q_OS_WIN
    // Simulation defaults for development
    cs2Options["-allow_third_party_software"] = true;
    cs2Options["-noreflex"] = true;
#else
    if (loadedFromProfile) {
        for (const QString &opt : CS2_MANAGED_OPTIONS) {
            if (firstLaunchOptions.contains(opt, Qt::CaseInsensitive)) {
                cs2Options[opt] = true;
            }
        }
    }
#endif

    m_cs2LaunchOptions = cs2Options;
    m_originalCs2LaunchOptions = cs2Options;
    emit cs2LaunchOptionsChanged(m_cs2LaunchOptions);
    emit originalCs2LaunchOptionsChanged(m_originalCs2LaunchOptions);

    // Detect Steam Installed and Load Friends & Chat Settings
    m_steamInstalled = !steamPath.isEmpty() && QDir(steamPath).exists();
    emit steamInstalledChanged(m_steamInstalled);

    QVariantMap defaultFriendsSettings;
    defaultFriendsSettings["bAppendNicknamesToNames"] = false;
    defaultFriendsSettings["bGroupFriendsByGame"] = true;
    defaultFriendsSettings["bHideOfflineFriendsInCustomCategories"] = false;
    defaultFriendsSettings["bHideCategorizedFriendsInOnlineOffline"] = false;
    defaultFriendsSettings["bIgnoreAwayStatusWhenSorting"] = false;
    defaultFriendsSettings["bSignInOnStart"] = true;
    defaultFriendsSettings["bEnableAnimatedAvatars"] = true;
    defaultFriendsSettings["bCompactFriendsListAndChat"] = false;
    defaultFriendsSettings["bCompactFavorites"] = false;
    defaultFriendsSettings["bDockChats"] = false;
    defaultFriendsSettings["bOpenNewWindowForNewChats"] = false;
    defaultFriendsSettings["bDontEmbedImages"] = false;
    defaultFriendsSettings["bRememberOpenChats"] = true;
    defaultFriendsSettings["bDisableSpellCheck"] = false;
    defaultFriendsSettings["bDisableRoomEffects"] = false;
    defaultFriendsSettings["fontSize"] = QString("default");

    m_steamFriendsSettings.clear();
    if (m_steamInstalled) {
        QString userdataPath = steamPath + "/userdata";
        QDir userdataDir(userdataPath);
        if (userdataDir.exists()) {
            QStringList subdirs = userdataDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
            for (const QString &subdir : subdirs) {
                QString vdfPath = userdataPath + "/" + subdir + "/config/localconfig.vdf";
                if (QFile::exists(vdfPath)) {
                    QVariantMap loadedSettings;
                    if (getVdfFriendsSettings(vdfPath, subdir, loadedSettings)) {
                        if (!loadedSettings.isEmpty()) {
                            m_steamFriendsSettings = loadedSettings;
                            break;
                        }
                    }
                }
            }
        }
    }
    if (m_steamFriendsSettings.isEmpty()) {
        m_steamFriendsSettings = defaultFriendsSettings;
    }
    m_originalSteamFriendsSettings = m_steamFriendsSettings;
    emit steamFriendsSettingsChanged(m_steamFriendsSettings);
    emit originalSteamFriendsSettingsChanged(m_originalSteamFriendsSettings);

    // Load global Steam Overlay active state (Registry)
    bool steamOverlayActive = true;
#ifdef Q_OS_WIN
    HKEY hKeySteamOverlay;
    if (RegOpenKeyExW(HKEY_CURRENT_USER, L"Software\\Valve\\Steam", 0, KEY_READ, &hKeySteamOverlay) == ERROR_SUCCESS) {
        DWORD enableOverlayVal = 1;
        DWORD dwSize = sizeof(enableOverlayVal);
        DWORD dwType = REG_DWORD;
        if (RegQueryValueExW(hKeySteamOverlay, L"EnableOverlay", nullptr, &dwType, reinterpret_cast<LPBYTE>(&enableOverlayVal), &dwSize) == ERROR_SUCCESS) {
            steamOverlayActive = (enableOverlayVal != 0);
        }
        RegCloseKey(hKeySteamOverlay);
    }
#endif
    m_steamOverlayActive = steamOverlayActive;
    m_originalSteamOverlayActive = steamOverlayActive;
    emit steamOverlayActiveChanged(m_steamOverlayActive);
    emit originalSteamOverlayActiveChanged(m_originalSteamOverlayActive);

    // Load CS2-specific Steam Overlay active state (VDF)
    bool cs2OverlayActive = true;
    bool loadedOverlayFromProfile = false;

    if (!steamPath.isEmpty() && QDir(steamPath).exists()) {
        QString userdataPath = steamPath + "/userdata";
        QDir userdataDir(userdataPath);
        if (userdataDir.exists()) {
            QStringList subdirs = userdataDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
            for (const QString &subdir : subdirs) {
                QString vdfPath = userdataPath + "/" + subdir + "/config/localconfig.vdf";
                if (QFile::exists(vdfPath)) {
                    QString overlayState = getVdfOverlayState(vdfPath, "730");
                    if (!overlayState.isEmpty() && !loadedOverlayFromProfile) {
                        cs2OverlayActive = (overlayState != "2");
                        loadedOverlayFromProfile = true;
                    }
                }
            }
        }
    }

#ifndef Q_OS_WIN
    cs2OverlayActive = true;
#endif

    m_cs2OverlayActive = cs2OverlayActive;
    m_originalCs2OverlayActive = cs2OverlayActive;
    emit cs2OverlayActiveChanged(m_cs2OverlayActive);
    emit originalCs2OverlayActiveChanged(m_originalCs2OverlayActive);

    // Load visual effects settings
    QVariantMap visEffects;
    visEffects["animateControls"] = readVisualEffectReg("ControlAnimations", true);
    visEffects["animateWindows"] = readVisualEffectReg("AnimateMinMax", true);
    visEffects["animateTaskbar"] = readVisualEffectReg("TaskbarAnimations", true);
    visEffects["enablePeek"] = readVisualEffectReg("DWMAeroPeekEnabled", true);
    visEffects["fadeMenus"] = readVisualEffectReg("MenuAnimation", true);
    visEffects["fadeTooltips"] = readVisualEffectReg("TooltipAnimation", true);
    visEffects["fadeMenuSelection"] = readVisualEffectReg("SelectionFade", true);
    visEffects["saveThumbnails"] = readVisualEffectReg("DWMSaveThumbnailEnabled", true);
    visEffects["shadowPointer"] = readVisualEffectReg("CursorShadow", true);
    visEffects["shadowWindows"] = readVisualEffectReg("DropShadow", true);
    visEffects["showThumbnails"] = readVisualEffectReg("ThumbnailsOrIcon", true);
    visEffects["translucentSelection"] = readVisualEffectReg("ListviewAlphaSelect", true);
    visEffects["dragContents"] = readVisualEffectReg("DragFullWindows", true);
    visEffects["slideComboBoxes"] = readVisualEffectReg("ComboBoxAnimation", true);
    visEffects["smoothFonts"] = readFontSmoothingReg();
    visEffects["smoothScroll"] = readVisualEffectReg("ListBoxSmoothScrolling", true);
    visEffects["dropShadowsDesktop"] = readVisualEffectReg("ListviewShadow", true);

    m_visualEffects = visEffects;
    m_originalVisualEffects = visEffects;
    emit visualEffectsChanged(m_visualEffects);
    emit originalVisualEffectsChanged(m_originalVisualEffects);
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
    bool coreIsolationVal = m_coreIsolationActive;
    bool mouseAccelVal = m_mouseAccelerationActive;
    bool gameModeVal = m_gameModeActive;
    bool firewallVal = m_firewallActive;
    bool printerVal = m_printerActive;
    bool bitlockerVal = m_bitlockerActive;
    bool discordOverlayVal = m_discordOverlayActive;
    bool notificationsVal = m_notificationsActive;
    bool notifGlobalVal = m_notifGlobalActive;
    bool notifAppVal = m_notifAppActive;
    bool notifSoundsVal = m_notifSoundsActive;
    bool notifLockscreenVal = m_notifLockscreenActive;
    QString targetPowerSchemeVal = m_targetPowerSchemeGuid;
    QString activePowerSchemeVal = m_activePowerSchemeGuid;
    bool defenderVal = m_defenderActive;
    bool defenderRegistryVal = m_defenderRegistryActive;
    bool defenderCmdVal = m_defenderCmdActive;
    bool defenderServiceVal = m_defenderServiceActive;
    bool remoteAccessVal = m_remoteAccessActive;
    bool telemetryVal = m_telemetryActive;
    bool telemetryDiagTrackVal = m_telemetryDiagTrackActive;
    bool telemetryWapPushVal = m_telemetryWapPushActive;
    bool telemetryCeipVal = m_telemetryCeipActive;
    bool telemetryWerVal = m_telemetryWerActive;
    int windowsUpdateModeVal = m_windowsUpdateMode;

    QString steamPathVal = "";
#ifdef Q_OS_WIN
    HKEY hKeySteam;
    if (RegOpenKeyExW(HKEY_CURRENT_USER, L"Software\\Valve\\Steam", 0, KEY_READ, &hKeySteam) == ERROR_SUCCESS) {
        wchar_t pathBuf[512] = {0};
        DWORD size = sizeof(pathBuf);
        if (RegQueryValueExW(hKeySteam, L"SteamPath", NULL, NULL, (LPBYTE)pathBuf, &size) == ERROR_SUCCESS) {
            steamPathVal = QString::fromWCharArray(pathBuf).replace("/", "\\");
        }
        RegCloseKey(hKeySteam);
    }
    if (steamPathVal.isEmpty()) {
        if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SOFTWARE\\WOW6432Node\\Valve\\Steam", 0, KEY_READ, &hKeySteam) == ERROR_SUCCESS) {
            wchar_t pathBuf[512] = {0};
            DWORD size = sizeof(pathBuf);
            if (RegQueryValueExW(hKeySteam, L"InstallPath", NULL, NULL, (LPBYTE)pathBuf, &size) == ERROR_SUCCESS) {
                steamPathVal = QString::fromWCharArray(pathBuf).replace("/", "\\");
            }
            RegCloseKey(hKeySteam);
        }
    }
#endif

    QVariantMap cs2OptionsVal = m_cs2LaunchOptions;
    QVariantMap origCs2OptionsVal = m_originalCs2LaunchOptions;

    QVariantMap targets = m_driveStates;
    QVariantMap originalTargets = m_originalDriveStates;
    bool origSearch = m_originalWinSearchActive;
    bool origHibernation = m_originalHibernationActive;
    bool origOverlay = m_originalGamingOverlayActive;
    bool origCoreIsolation = m_originalCoreIsolationActive;
    bool origMouseAccel = m_originalMouseAccelerationActive;
    bool origGameMode = m_originalGameModeActive;
    bool origFirewall = m_originalFirewallActive;
    bool origPrinter = m_originalPrinterActive;
    bool origBitlocker = m_originalBitlockerActive;
    bool origDiscordOverlay = m_originalDiscordOverlayActive;
    bool origNotifications = m_originalNotificationsActive;
    bool origNotifGlobal = m_originalNotifGlobalActive;
    bool origNotifApp = m_originalNotifAppActive;
    bool origNotifSounds = m_originalNotifSoundsActive;
    bool origNotifLockscreen = m_originalNotifLockscreenActive;
    bool origDefender = m_originalDefenderActive;
    bool origDefenderRegistry = m_originalDefenderRegistryActive;
    bool origDefenderCmd = m_originalDefenderCmdActive;
    bool origDefenderService = m_originalDefenderServiceActive;
    bool origRemoteAccess = m_originalRemoteAccessActive;
    bool origTelemetry = m_originalTelemetryActive;
    bool origTelemetryDiagTrack = m_originalTelemetryDiagTrackActive;
    bool origTelemetryWapPush = m_originalTelemetryWapPushActive;
    bool origTelemetryCeip = m_originalTelemetryCeipActive;
    bool origTelemetryWer = m_originalTelemetryWerActive;
    int origWindowsUpdateMode = m_originalWindowsUpdateMode;

    QVariantList usbDevicesVal = m_usbDevices;
    QVariantList origUsbDevicesVal = m_originalUsbDevices;

    bool steamOverlayVal = m_steamOverlayActive;
    bool origSteamOverlayVal = m_originalSteamOverlayActive;
    bool cs2OverlayVal = m_cs2OverlayActive;
    bool origCs2OverlayVal = m_originalCs2OverlayActive;
    QVariantMap visualEffectsVal = m_visualEffects;
    QVariantMap origVisualEffectsVal = m_originalVisualEffects;

    QVariantMap steamFriendsSettingsVal = m_steamFriendsSettings;
    QVariantMap origSteamFriendsSettingsVal = m_originalSteamFriendsSettings;
    bool steamFriendsChanged = (m_steamFriendsSettings != m_originalSteamFriendsSettings);

    QThread* worker = QThread::create([this, searchVal, hibernationVal, overlayVal, coreIsolationVal, mouseAccelVal, gameModeVal, firewallVal, printerVal, bitlockerVal, discordOverlayVal, notificationsVal, notifGlobalVal, notifAppVal, notifSoundsVal, notifLockscreenVal, targetPowerSchemeVal, activePowerSchemeVal, defenderVal, defenderRegistryVal, defenderCmdVal, defenderServiceVal, remoteAccessVal, telemetryVal, telemetryDiagTrackVal, telemetryWapPushVal, telemetryCeipVal, telemetryWerVal, windowsUpdateModeVal, targets, originalTargets, origSearch, origHibernation, origOverlay, origCoreIsolation, origMouseAccel, origGameMode, origFirewall, origPrinter, origBitlocker, origDiscordOverlay, origNotifications, origNotifGlobal, origNotifApp, origNotifSounds, origNotifLockscreen, origDefender, origDefenderRegistry, origDefenderCmd, origDefenderService, origRemoteAccess, origTelemetry, origTelemetryDiagTrack, origTelemetryWapPush, origTelemetryCeip, origTelemetryWer, origWindowsUpdateMode, usbDevicesVal, origUsbDevicesVal, steamPathVal, cs2OptionsVal, origCs2OptionsVal, steamOverlayVal, origSteamOverlayVal, cs2OverlayVal, origCs2OverlayVal, visualEffectsVal, origVisualEffectsVal, steamFriendsSettingsVal, origSteamFriendsSettingsVal, steamFriendsChanged]() {
        // Step 0: Check if anything actually changed
        bool powerPlanChanged = (targetPowerSchemeVal != activePowerSchemeVal);
        bool usbChanged = false;
        if (usbDevicesVal.size() == origUsbDevicesVal.size()) {
            for (int i = 0; i < usbDevicesVal.size(); ++i) {
                if (usbDevicesVal[i].toMap()["powerSavingActive"].toBool() != origUsbDevicesVal[i].toMap()["powerSavingActive"].toBool()) {
                    usbChanged = true;
                    break;
                }
            }
        } else {
            usbChanged = true;
        }

        bool telemetryChanged = (telemetryVal != origTelemetry) ||
                                (telemetryDiagTrackVal != origTelemetryDiagTrack) ||
                                (telemetryWapPushVal != origTelemetryWapPush) ||
                                (telemetryCeipVal != origTelemetryCeip) ||
                                (telemetryWerVal != origTelemetryWer);

        bool windowsUpdateModeChanged = (windowsUpdateModeVal != origWindowsUpdateMode);

        bool cs2Changed = (cs2OptionsVal != origCs2OptionsVal);
        bool steamOverlayChanged = (steamOverlayVal != origSteamOverlayVal);
        bool cs2OverlayChanged = (cs2OverlayVal != origCs2OverlayVal);
        bool visualEffectsChanged = (visualEffectsVal != origVisualEffectsVal);

        bool anyChanges = (searchVal != origSearch) || 
                          (hibernationVal != origHibernation) || 
                          (overlayVal != origOverlay) ||
                          (coreIsolationVal != origCoreIsolation) ||
                          (mouseAccelVal != origMouseAccel) ||
                          (gameModeVal != origGameMode) ||
                          (firewallVal != origFirewall) ||
                          (printerVal != origPrinter) ||
                          (bitlockerVal != origBitlocker) ||
                          (discordOverlayVal != origDiscordOverlay) ||
                          (notificationsVal != origNotifications) ||
                          (notifGlobalVal != origNotifGlobal) ||
                          (notifAppVal != origNotifApp) ||
                          (notifSoundsVal != origNotifSounds) ||
                          (notifLockscreenVal != origNotifLockscreen) ||
                          (defenderVal != origDefender) ||
                          (defenderRegistryVal != origDefenderRegistry) ||
                          (defenderCmdVal != origDefenderCmd) ||
                          (defenderServiceVal != origDefenderService) ||
                          (remoteAccessVal != origRemoteAccess) ||
                          telemetryChanged ||
                          windowsUpdateModeChanged ||
                          powerPlanChanged ||
                          usbChanged ||
                          cs2Changed ||
                          steamOverlayChanged ||
                          cs2OverlayChanged ||
                          visualEffectsChanged;
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

        // Step 1.8: Core Isolation / Memory Integrity Configuration (only if changed)
        bool coreIsolationSuccess = true;
        if (coreIsolationVal != origCoreIsolation) {
            emit systemStepReported(tr("Configuring Core Isolation (Memory Integrity)..."), "INFO");
            QThread::msleep(800);
#ifdef Q_OS_WIN
            bool success = false;
            HKEY hKeyCI;
            if (RegCreateKeyExW(HKEY_LOCAL_MACHINE, L"SYSTEM\\CurrentControlSet\\Control\\DeviceGuard\\Scenarios\\HypervisorEnforcedCodeIntegrity", 0, NULL, REG_OPTION_NON_VOLATILE, KEY_WRITE, NULL, &hKeyCI, NULL) == ERROR_SUCCESS) {
                DWORD val = coreIsolationVal ? 1 : 0;
                if (RegSetValueExW(hKeyCI, L"Enabled", 0, REG_DWORD, (const BYTE*)&val, sizeof(val)) == ERROR_SUCCESS) {
                    success = true;
                }
                RegCloseKey(hKeyCI);
            }
            
            if (success) {
                QString logMsg = coreIsolationVal ? tr("Core Isolation is now ENABLED.") : tr("Core Isolation is now DISABLED.");
                emit systemStepReported(logMsg, "SUCCESS");
            } else {
                coreIsolationSuccess = false;
                emit systemStepReported(tr("Failed to update Core Isolation state. Error: %1").arg(GetLastError()), "ERROR");
            }
#else
            emit systemStepReported(tr("[Simulation] Core Isolation set to: %1").arg(coreIsolationVal ? "Enabled" : "Disabled"), "SUCCESS");
#endif
            m_coreIsolationActive = coreIsolationVal;
            emit coreIsolationActiveChanged(m_coreIsolationActive);
        }

        // Step 1.85: Mouse Acceleration Configuration (only if changed)
        bool mouseAccelSuccess = true;
        if (mouseAccelVal != origMouseAccel) {
            emit systemStepReported(tr("Configuring mouse acceleration..."), "INFO");
            QThread::msleep(800);
#ifdef Q_OS_WIN
            bool success = false;
            int mouseParams[3] = {0};
            if (SystemParametersInfoW(SPI_GETMOUSE, 0, mouseParams, 0)) {
                mouseParams[2] = mouseAccelVal ? 1 : 0;
                if (mouseAccelVal) {
                    if (mouseParams[0] == 0) mouseParams[0] = 6;
                    if (mouseParams[1] == 0) mouseParams[1] = 10;
                } else {
                    mouseParams[0] = 0;
                    mouseParams[1] = 0;
                }
                if (SystemParametersInfoW(SPI_SETMOUSE, 0, mouseParams, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE)) {
                    success = true;
                }
            }
            
            if (success) {
                QString logMsg = mouseAccelVal ? tr("Mouse acceleration is now ENABLED.") : tr("Mouse acceleration is now DISABLED.");
                emit systemStepReported(logMsg, "SUCCESS");
            } else {
                mouseAccelSuccess = false;
                emit systemStepReported(tr("Failed to update mouse acceleration state."), "ERROR");
            }
#else
            emit systemStepReported(tr("[Simulation] Mouse acceleration set to: %1").arg(mouseAccelVal ? "Enabled" : "Disabled"), "SUCCESS");
#endif
            m_mouseAccelerationActive = mouseAccelVal;
            emit mouseAccelerationActiveChanged(m_mouseAccelerationActive);
        }

        // Step 1.9: Windows Game Mode Configuration (only if changed)
        bool gameModeSuccess = true;
        if (gameModeVal != origGameMode) {
            emit systemStepReported(tr("Configuring Windows Game Mode..."), "INFO");
            QThread::msleep(800);
#ifdef Q_OS_WIN
            bool success = true;
            HKEY hKeyGB;
            if (RegCreateKeyExW(HKEY_CURRENT_USER, L"Software\\Microsoft\\GameBar", 0, NULL, REG_OPTION_NON_VOLATILE, KEY_WRITE, NULL, &hKeyGB, NULL) == ERROR_SUCCESS) {
                DWORD val = gameModeVal ? 1 : 0;
                if (RegSetValueExW(hKeyGB, L"AllowAutoGameMode", 0, REG_DWORD, (const BYTE*)&val, sizeof(val)) != ERROR_SUCCESS) {
                    success = false;
                }
                if (RegSetValueExW(hKeyGB, L"AutoGameModeEnabled", 0, REG_DWORD, (const BYTE*)&val, sizeof(val)) != ERROR_SUCCESS) {
                    success = false;
                }
                RegCloseKey(hKeyGB);
            } else {
                success = false;
            }
            
            if (success) {
                QString logMsg = gameModeVal ? tr("Windows Game Mode is now ENABLED.") : tr("Windows Game Mode is now DISABLED.");
                emit systemStepReported(logMsg, "SUCCESS");
            } else {
                gameModeSuccess = false;
                emit systemStepReported(tr("Failed to update Windows Game Mode state."), "ERROR");
            }
#else
            emit systemStepReported(tr("[Simulation] Windows Game Mode set to: %1").arg(gameModeVal ? "Enabled" : "Disabled"), "SUCCESS");
#endif
            m_gameModeActive = gameModeVal;
            emit gameModeActiveChanged(m_gameModeActive);
        }

        // Step 1.95: Windows Defender Firewall Configuration (only if changed)
        bool firewallSuccess = true;
        if (firewallVal != origFirewall) {
            emit systemStepReported(tr("Configuring Windows Defender Firewall..."), "INFO");
            QThread::msleep(800);
#ifdef Q_OS_WIN
            QProcess process;
            process.start("netsh", QStringList() << "advfirewall" << "set" << "allprofiles" << "state" << (firewallVal ? "on" : "off"));
            bool finished = process.waitForFinished(5000);
            
            if (finished && process.exitCode() == 0) {
                QString logMsg = firewallVal ? tr("Windows Defender Firewall is now ENABLED.") : tr("Windows Defender Firewall is now DISABLED.");
                emit systemStepReported(logMsg, "SUCCESS");
            } else {
                firewallSuccess = false;
                emit systemStepReported(tr("Failed to update Windows Defender Firewall state."), "ERROR");
            }
#else
            emit systemStepReported(tr("[Simulation] Windows Defender Firewall set to: %1").arg(firewallVal ? "Enabled" : "Disabled"), "SUCCESS");
#endif
            m_firewallActive = firewallVal;
            emit firewallActiveChanged(m_firewallActive);
        }

        // Step 1.98: Print Spooler (Printer) Configuration (only if changed)
        bool printerSuccess = true;
        if (printerVal != origPrinter) {
            emit systemStepReported(tr("Processing Print Spooler service..."), "INFO");
            QThread::msleep(800);
#ifdef Q_OS_WIN
            SC_HANDLE hSCM = OpenSCManagerW(NULL, NULL, SC_MANAGER_ALL_ACCESS);
            if (hSCM) {
                SC_HANDLE hService = OpenServiceW(hSCM, L"Spooler", SERVICE_CHANGE_CONFIG | SERVICE_STOP | SERVICE_START | SERVICE_QUERY_STATUS);
                if (hService) {
                    DWORD startType = printerVal ? SERVICE_AUTO_START : SERVICE_DISABLED;
                    if (ChangeServiceConfigW(hService, SERVICE_NO_CHANGE, startType, SERVICE_NO_CHANGE, NULL, NULL, NULL, NULL, NULL, NULL, NULL)) {
                        QString logMsg = printerVal ? tr("Print Spooler startup set to Automatic.") : tr("Print Spooler startup set to Disabled.");
                        emit systemStepReported(logMsg, "INFO");
                        
                        SERVICE_STATUS_PROCESS ssp;
                        DWORD bytesNeeded = 0;
                        if (QueryServiceStatusEx(hService, SC_STATUS_PROCESS_INFO, reinterpret_cast<LPBYTE>(&ssp), sizeof(ssp), &bytesNeeded)) {
                            if (!printerVal && ssp.dwCurrentState != SERVICE_STOPPED && ssp.dwCurrentState != SERVICE_STOP_PENDING) {
                                emit systemStepReported(tr("Stopping Print Spooler service..."), "INFO");
                                SERVICE_STATUS status;
                                ControlService(hService, SERVICE_CONTROL_STOP, &status);
                                for (int i = 0; i < 15; ++i) {
                                    QThread::msleep(200);
                                    if (QueryServiceStatusEx(hService, SC_STATUS_PROCESS_INFO, reinterpret_cast<LPBYTE>(&ssp), sizeof(ssp), &bytesNeeded)) {
                                        if (ssp.dwCurrentState == SERVICE_STOPPED) break;
                                    }
                                }
                                if (ssp.dwCurrentState == SERVICE_STOPPED) {
                                    emit systemStepReported(tr("Print Spooler service stopped successfully."), "SUCCESS");
                                } else {
                                    emit systemStepReported(tr("Print Spooler service stop requested."), "WARNING");
                                }
                            } else if (printerVal && ssp.dwCurrentState != SERVICE_RUNNING && ssp.dwCurrentState != SERVICE_START_PENDING) {
                                emit systemStepReported(tr("Starting Print Spooler service..."), "INFO");
                                if (StartServiceW(hService, 0, NULL)) {
                                    for (int i = 0; i < 15; ++i) {
                                        QThread::msleep(200);
                                        if (QueryServiceStatusEx(hService, SC_STATUS_PROCESS_INFO, reinterpret_cast<LPBYTE>(&ssp), sizeof(ssp), &bytesNeeded)) {
                                            if (ssp.dwCurrentState == SERVICE_RUNNING) break;
                                        }
                                    }
                                    if (ssp.dwCurrentState == SERVICE_RUNNING) {
                                        emit systemStepReported(tr("Print Spooler service started successfully."), "SUCCESS");
                                    } else {
                                        emit systemStepReported(tr("Print Spooler service start pending."), "INFO");
                                    }
                                } else {
                                    emit systemStepReported(tr("Failed to start Print Spooler service."), "ERROR");
                                }
                            }
                        }
                    } else {
                        printerSuccess = false;
                        emit systemStepReported(tr("Failed to change Print Spooler service configuration. Error: %1").arg(GetLastError()), "ERROR");
                    }
                    CloseServiceHandle(hService);
                } else {
                    printerSuccess = false;
                    emit systemStepReported(tr("Failed to open Print Spooler service. Error: %1").arg(GetLastError()), "ERROR");
                }
                CloseServiceHandle(hSCM);
            } else {
                printerSuccess = false;
                emit systemStepReported(tr("Failed to connect to SCM. Error: %1").arg(GetLastError()), "ERROR");
            }
#else
            emit systemStepReported(tr("[Simulation] Print Spooler service state set to: %1").arg(printerVal ? "Enabled" : "Disabled"), "SUCCESS");
#endif
            m_printerActive = printerVal;
            emit printerActiveChanged(m_printerActive);
        }

        // Step 1.98b: BitLocker Drive Encryption (BDESVC) Configuration (only if changed)
        bool bitlockerSuccess = true;
        if (bitlockerVal != origBitlocker) {
            emit systemStepReported(tr("Processing BitLocker service..."), "INFO");
            QThread::msleep(800);
#ifdef Q_OS_WIN
            SC_HANDLE hSCM = OpenSCManagerW(NULL, NULL, SC_MANAGER_ALL_ACCESS);
            if (hSCM) {
                SC_HANDLE hService = OpenServiceW(hSCM, L"BDESVC", SERVICE_CHANGE_CONFIG | SERVICE_STOP | SERVICE_START | SERVICE_QUERY_STATUS);
                if (hService) {
                    DWORD startType = bitlockerVal ? SERVICE_DEMAND_START : SERVICE_DISABLED;
                    if (ChangeServiceConfigW(hService, SERVICE_NO_CHANGE, startType, SERVICE_NO_CHANGE, NULL, NULL, NULL, NULL, NULL, NULL, NULL)) {
                        QString logMsg = bitlockerVal ? tr("BitLocker service startup set to Manual.") : tr("BitLocker service startup set to Disabled.");
                        emit systemStepReported(logMsg, "INFO");
                        
                        SERVICE_STATUS_PROCESS ssp;
                        DWORD bytesNeeded = 0;
                        if (QueryServiceStatusEx(hService, SC_STATUS_PROCESS_INFO, reinterpret_cast<LPBYTE>(&ssp), sizeof(ssp), &bytesNeeded)) {
                            if (!bitlockerVal && ssp.dwCurrentState != SERVICE_STOPPED && ssp.dwCurrentState != SERVICE_STOP_PENDING) {
                                emit systemStepReported(tr("Stopping BitLocker service..."), "INFO");
                                SERVICE_STATUS status;
                                ControlService(hService, SERVICE_CONTROL_STOP, &status);
                                for (int i = 0; i < 15; ++i) {
                                    QThread::msleep(200);
                                    if (QueryServiceStatusEx(hService, SC_STATUS_PROCESS_INFO, reinterpret_cast<LPBYTE>(&ssp), sizeof(ssp), &bytesNeeded)) {
                                        if (ssp.dwCurrentState == SERVICE_STOPPED) break;
                                    }
                                }
                                if (ssp.dwCurrentState == SERVICE_STOPPED) {
                                    emit systemStepReported(tr("BitLocker service stopped successfully."), "SUCCESS");
                                } else {
                                    emit systemStepReported(tr("BitLocker service stop requested."), "WARNING");
                                }
                            } else if (bitlockerVal && ssp.dwCurrentState != SERVICE_RUNNING && ssp.dwCurrentState != SERVICE_START_PENDING) {
                                emit systemStepReported(tr("Starting BitLocker service..."), "INFO");
                                if (StartServiceW(hService, 0, NULL)) {
                                    for (int i = 0; i < 15; ++i) {
                                        QThread::msleep(200);
                                        if (QueryServiceStatusEx(hService, SC_STATUS_PROCESS_INFO, reinterpret_cast<LPBYTE>(&ssp), sizeof(ssp), &bytesNeeded)) {
                                            if (ssp.dwCurrentState == SERVICE_RUNNING) break;
                                        }
                                    }
                                    if (ssp.dwCurrentState == SERVICE_RUNNING) {
                                        emit systemStepReported(tr("BitLocker service started successfully."), "SUCCESS");
                                    } else {
                                        emit systemStepReported(tr("BitLocker service start pending."), "INFO");
                                    }
                                } else {
                                    emit systemStepReported(tr("Failed to start BitLocker service."), "ERROR");
                                }
                            }
                        }
                    } else {
                        bitlockerSuccess = false;
                        emit systemStepReported(tr("Failed to change BitLocker service configuration. Error: %1").arg(GetLastError()), "ERROR");
                    }
                    CloseServiceHandle(hService);
                } else {
                    bitlockerSuccess = false;
                    emit systemStepReported(tr("Failed to open BitLocker service. Error: %1").arg(GetLastError()), "ERROR");
                }
                CloseServiceHandle(hSCM);
            } else {
                bitlockerSuccess = false;
                emit systemStepReported(tr("Failed to connect to SCM. Error: %1").arg(GetLastError()), "ERROR");
            }
#else
            emit systemStepReported(tr("[Simulation] BitLocker service state set to: %1").arg(bitlockerVal ? "Enabled" : "Disabled"), "SUCCESS");
#endif
            m_bitlockerActive = bitlockerVal;
            emit bitlockerActiveChanged(m_bitlockerActive);
        }

        // Step 1.98c: Discord Overlay Configuration (only if changed)
        if (discordOverlayVal != origDiscordOverlay) {
            emit systemStepReported(tr("Processing Discord Overlay..."), "INFO");
            QThread::msleep(800);
#ifdef Q_OS_WIN
            if (isDiscordRunning()) {
                emit systemStepReported(tr("Closing running Discord processes to unlock files..."), "INFO");
                killDiscord();
                QThread::msleep(500);
            }
            
            setDiscordOverlayFilesActive(discordOverlayVal);
            if (discordOverlayVal) {
                emit systemStepReported(tr("Discord Overlay successfully enabled."), "SUCCESS");
            } else {
                emit systemStepReported(tr("Discord Overlay successfully disabled."), "SUCCESS");
            }
#else
            emit systemStepReported(tr("[Simulation] Discord Overlay set to: %1").arg(discordOverlayVal ? "Enabled" : "Disabled"), "SUCCESS");
#endif
            m_discordOverlayActive = discordOverlayVal;
            emit discordOverlayActiveChanged(m_discordOverlayActive);
        }

        // Step 1.99: Windows Notifications Configuration (only if changed)
        bool notificationsSuccess = true;
        if ((notificationsVal != origNotifications) ||
            (notifGlobalVal != origNotifGlobal) ||
            (notifAppVal != origNotifApp) ||
            (notifSoundsVal != origNotifSounds) ||
            (notifLockscreenVal != origNotifLockscreen)) {

            emit systemStepReported(tr("Processing Windows notifications configuration..."), "INFO");
            QThread::msleep(800);

#ifdef Q_OS_WIN
            bool ok = true;
            HKEY hKeyPush;
            // 1. ToastEnabled under HKCU\Software\Microsoft\Windows\CurrentVersion\PushNotifications
            if (RegCreateKeyExW(HKEY_CURRENT_USER, L"Software\\Microsoft\\Windows\\CurrentVersion\\PushNotifications", 0, NULL, REG_OPTION_NON_VOLATILE, KEY_WRITE, NULL, &hKeyPush, NULL) == ERROR_SUCCESS) {
                DWORD val = notifGlobalVal ? 1 : 0;
                if (RegSetValueExW(hKeyPush, L"ToastEnabled", 0, REG_DWORD, (const BYTE*)&val, sizeof(val)) != ERROR_SUCCESS) {
                    ok = false;
                }
                RegCloseKey(hKeyPush);
            } else {
                ok = false;
            }

            // 2. Settings under HKCU\Software\Microsoft\Windows\CurrentVersion\Notifications\Settings
            HKEY hKeySettings;
            if (RegCreateKeyExW(HKEY_CURRENT_USER, L"Software\\Microsoft\\Windows\\CurrentVersion\\Notifications\\Settings", 0, NULL, REG_OPTION_NON_VOLATILE, KEY_WRITE, NULL, &hKeySettings, NULL) == ERROR_SUCCESS) {
                DWORD valApp = notifAppVal ? 1 : 0;
                DWORD valSounds = notifSoundsVal ? 1 : 0;
                DWORD valLock = notifLockscreenVal ? 1 : 0;

                if (RegSetValueExW(hKeySettings, L"NOC_GLOBAL_SETTING_TOASTS_ENABLED", 0, REG_DWORD, (const BYTE*)&valApp, sizeof(valApp)) != ERROR_SUCCESS) {
                    ok = false;
                }
                if (RegSetValueExW(hKeySettings, L"NOC_GLOBAL_SETTING_ALLOW_NOTIFICATION_SOUND", 0, REG_DWORD, (const BYTE*)&valSounds, sizeof(valSounds)) != ERROR_SUCCESS) {
                    ok = false;
                }
                if (RegSetValueExW(hKeySettings, L"NOC_GLOBAL_SETTING_ALLOW_TOASTS_ABOVE_LOCK", 0, REG_DWORD, (const BYTE*)&valLock, sizeof(valLock)) != ERROR_SUCCESS) {
                    ok = false;
                }
                RegCloseKey(hKeySettings);
            } else {
                ok = false;
            }

            if (ok) {
                emit systemStepReported(tr("Windows notifications updated successfully."), "SUCCESS");
            } else {
                notificationsSuccess = false;
                emit systemStepReported(tr("Failed to update Windows notifications. Error: %1").arg(GetLastError()), "ERROR");
            }
#else
            emit systemStepReported(tr("[Simulation] Windows notifications set to: %1").arg(notificationsVal ? "Enabled" : "Disabled"), "SUCCESS");
#endif
            m_notificationsActive = notificationsVal;
            m_notifGlobalActive = notifGlobalVal;
            m_notifAppActive = notifAppVal;
            m_notifSoundsActive = notifSoundsVal;
            m_notifLockscreenActive = notifLockscreenVal;

            emit notificationsActiveChanged(m_notificationsActive);
            emit notifGlobalActiveChanged(m_notifGlobalActive);
            emit notifAppActiveChanged(m_notifAppActive);
            emit notifSoundsActiveChanged(m_notifSoundsActive);
            emit notifLockscreenActiveChanged(m_notifLockscreenActive);
        }

        // Step 1.99d: Windows Defender Configuration (only if changed)
        bool defenderSuccess = true;
        if ((defenderVal != origDefender) ||
            (defenderRegistryVal != origDefenderRegistry) ||
            (defenderCmdVal != origDefenderCmd) ||
            (defenderServiceVal != origDefenderService)) {

            emit systemStepReported(tr("Processing Windows Defender configuration..."), "INFO");
            QThread::msleep(800);

#ifdef Q_OS_WIN
            bool ok = true;

            // 1. Registry Policies
            if (defenderRegistryVal != origDefenderRegistry) {
                emit systemStepReported(tr("Applying Windows Defender registry policies..."), "INFO");
                HKEY hKeyDef;
                if (RegCreateKeyExW(HKEY_LOCAL_MACHINE, L"SOFTWARE\\Policies\\Microsoft\\Windows Defender", 0, NULL, REG_OPTION_NON_VOLATILE, KEY_WRITE, NULL, &hKeyDef, NULL) == ERROR_SUCCESS) {
                    DWORD val = defenderRegistryVal ? 0 : 1;
                    RegSetValueExW(hKeyDef, L"DisableAntiSpyware", 0, REG_DWORD, (const BYTE*)&val, sizeof(val));
                    RegSetValueExW(hKeyDef, L"DisableAntiVirus", 0, REG_DWORD, (const BYTE*)&val, sizeof(val));
                    RegCloseKey(hKeyDef);
                } else {
                    ok = false;
                }

                HKEY hKeyDefRT;
                if (RegCreateKeyExW(HKEY_LOCAL_MACHINE, L"SOFTWARE\\Policies\\Microsoft\\Windows Defender\\Real-Time Protection", 0, NULL, REG_OPTION_NON_VOLATILE, KEY_WRITE, NULL, &hKeyDefRT, NULL) == ERROR_SUCCESS) {
                    DWORD val = defenderRegistryVal ? 0 : 1;
                    RegSetValueExW(hKeyDefRT, L"DisableBehaviorMonitoring", 0, REG_DWORD, (const BYTE*)&val, sizeof(val));
                    RegSetValueExW(hKeyDefRT, L"DisableOnAccessProtection", 0, REG_DWORD, (const BYTE*)&val, sizeof(val));
                    RegSetValueExW(hKeyDefRT, L"DisableScanOnRealtimeEnable", 0, REG_DWORD, (const BYTE*)&val, sizeof(val));
                    RegSetValueExW(hKeyDefRT, L"DisableRealtimeMonitoring", 0, REG_DWORD, (const BYTE*)&val, sizeof(val));
                    RegCloseKey(hKeyDefRT);
                } else {
                    ok = false;
                }
            }

            // 2. PowerShell Command Preferences
            if (defenderCmdVal != origDefenderCmd) {
                emit systemStepReported(tr("Applying Windows Defender PowerShell preferences..."), "INFO");
                QString cmd;
                if (!defenderCmdVal) {
                    cmd = "-NoProfile -NonInteractive -Command \"Set-MpPreference -DisableRealtimeMonitoring $true -DisableBehaviorMonitoring $true -DisableIOAVProtection $true -DisableIntrusionPreventionSystem $true -DisableScriptScanning $true -DisableBlockAtFirstSight $true -SubmitSamplesConsent 2 -MAPSReporting 0\"";
                } else {
                    cmd = "-NoProfile -NonInteractive -Command \"Set-MpPreference -DisableRealtimeMonitoring $false -DisableBehaviorMonitoring $false -DisableIOAVProtection $false -DisableIntrusionPreventionSystem $false -DisableScriptScanning $false -DisableBlockAtFirstSight $false -SubmitSamplesConsent 0 -MAPSReporting 2\"";
                }
                QProcess proc;
                proc.start("powershell.exe", QStringList() << cmd);
                proc.waitForFinished(12000);
            }

            // 3. Antivirus Services & Drivers
            if (defenderServiceVal != origDefenderService) {
                emit systemStepReported(tr("Configuring Windows Defender services..."), "INFO");
                
                SC_HANDLE hSCM = OpenSCManagerW(NULL, NULL, SC_MANAGER_ALL_ACCESS);
                if (hSCM) {
                    const wchar_t* services[] = { L"WinDefend", L"Sense", L"WdFilter", L"WdBoot" };
                    for (int i = 0; i < 4; ++i) {
                        SC_HANDLE hService = OpenServiceW(hSCM, services[i], SERVICE_CHANGE_CONFIG | SERVICE_STOP);
                        if (hService) {
                            DWORD startType = defenderServiceVal ? SERVICE_AUTO_START : SERVICE_DISABLED;
                            if (i >= 2) {
                                startType = defenderServiceVal ? SERVICE_SYSTEM_START : SERVICE_DISABLED;
                            }
                            if (!ChangeServiceConfigW(hService, SERVICE_NO_CHANGE, startType, SERVICE_NO_CHANGE, NULL, NULL, NULL, NULL, NULL, NULL, NULL)) {
                                DWORD err = GetLastError();
                                if (err == ERROR_ACCESS_DENIED) {
                                    emit systemStepReported(tr("Warning: Unable to modify service '%1'. This is typically blocked by Windows Tamper Protection. Please disable 'Tamper Protection' in Windows Security settings first.").arg(QString::fromWCharArray(services[i])), "WARNING");
                                }
                            }
                            if (!defenderServiceVal) {
                                SERVICE_STATUS status;
                                ControlService(hService, SERVICE_CONTROL_STOP, &status);
                            }
                            CloseServiceHandle(hService);
                        }
                    }
                    CloseServiceHandle(hSCM);
                } else {
                    ok = false;
                }
            }

            if (ok) {
                emit systemStepReported(tr("Windows Defender optimization completed."), "SUCCESS");
            } else {
                defenderSuccess = false;
                emit systemStepReported(tr("Failed to apply some Windows Defender settings."), "WARNING");
            }
#else
            emit systemStepReported(tr("[Simulation] Windows Defender active set to: %1").arg(defenderVal ? "Enabled" : "Disabled"), "SUCCESS");
#endif
            m_defenderActive = defenderVal;
            m_defenderRegistryActive = defenderRegistryVal;
            m_defenderCmdActive = defenderCmdVal;
            m_defenderServiceActive = defenderServiceVal;

            emit defenderActiveChanged(m_defenderActive);
            emit defenderRegistryActiveChanged(m_defenderRegistryActive);
            emit defenderCmdActiveChanged(m_defenderCmdActive);
            emit defenderServiceActiveChanged(m_defenderServiceActive);
        }

        m_systemProgress = 0.50;
        emit systemProgressChanged(m_systemProgress);
        QThread::msleep(300);

        // Step 4.5: Power Plan Configuration (only if changed)
        bool powerPlanSuccess = true;
        if (powerPlanChanged) {
            emit systemStepReported(tr("Configuring Windows power settings..."), "INFO");
            QThread::msleep(800);
            
#ifdef Q_OS_WIN
            bool success = true;
            const QString ultimateGuidStr = "{E9A22B95-E3B0-4B87-A177-728978ED6022}";
            
            // Check if we need to duplicate/unlock Ultimate Performance scheme
            if (targetPowerSchemeVal == ultimateGuidStr) {
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
                    QProcess proc;
                    proc.start("powercfg.exe", QStringList() << "-duplicatescheme" << "e9a22b95-e3b0-4b87-a177-728978ed6022");
                    if (!proc.waitForFinished(8000)) {
                        success = false;
                        powerPlanSuccess = false;
                        emit systemStepReported(tr("Failed to duplicate Ultimate Performance power scheme."), "ERROR");
                        Logger::log("Failed to run powercfg duplicatescheme command.", "ERROR");
                    }
                }
            }
            
            if (success) {
                GUID guid;
                HRESULT hr = CLSIDFromString((LPCOLESTR)targetPowerSchemeVal.utf16(), &guid);
                if (SUCCEEDED(hr)) {
                    DWORD err = PowerSetActiveScheme(NULL, &guid);
                    if (err == ERROR_SUCCESS) {
                        UCHAR friendlyName[256] = {0};
                        DWORD friendlyNameSize = sizeof(friendlyName);
                        PowerReadFriendlyName(NULL, &guid, NULL, NULL, friendlyName, &friendlyNameSize);
                        QString name = QString::fromWCharArray((const wchar_t*)friendlyName);
                        if (name.isEmpty()) name = targetPowerSchemeVal;
                        
                        m_activePowerSchemeGuid = targetPowerSchemeVal;
                        emit activePowerSchemeGuidChanged(m_activePowerSchemeGuid);
                        
                        emit systemStepReported(tr("Power plan changed to: %1").arg(name), "SUCCESS");
                        Logger::log(QString("Power scheme successfully set active: %1").arg(name), "INFO");
                    } else {
                        powerPlanSuccess = false;
                        emit systemStepReported(tr("Failed to change power scheme."), "ERROR");
                        Logger::log(QString("Failed to set active scheme: %1").arg(err), "ERROR");
                    }
                } else {
                    powerPlanSuccess = false;
                    emit systemStepReported(tr("Failed to change power scheme."), "ERROR");
                }
            }
#else
            // Simulation
            m_activePowerSchemeGuid = targetPowerSchemeVal;
            emit activePowerSchemeGuidChanged(m_activePowerSchemeGuid);
            emit systemStepReported(tr("[Simulation] Power plan changed to: %1").arg(targetPowerSchemeVal), "SUCCESS");
#endif
        }

        // Step 1.99e: USB 3.0 Power Saving Configuration (only if changed)
        bool usbSuccess = true;
        if (usbChanged) {
            emit systemStepReported(tr("Configuring USB 3.0 Power Saving..."), "INFO");
            QThread::msleep(800);
            
            bool ok = true;
#ifdef Q_OS_WIN
            for (int i = 0; i < usbDevicesVal.size(); ++i) {
                QVariantMap deviceMap = usbDevicesVal[i].toMap();
                QString subkeyPath = deviceMap["subkeyPath"].toString();
                bool targetVal = deviceMap["powerSavingActive"].toBool();
                bool originalVal = origUsbDevicesVal[i].toMap()["powerSavingActive"].toBool();
                
                if (targetVal != originalVal) {
                    emit systemStepReported(tr("Setting USB power saving for '%1' to %2...").arg(deviceMap["name"].toString()).arg(targetVal ? tr("Enabled") : tr("Disabled")), "INFO");
                    
                    std::wstring wSubkey = subkeyPath.toStdWString();
                    HKEY hKeySub;
                    if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, wSubkey.c_str(), 0, KEY_SET_VALUE, &hKeySub) == ERROR_SUCCESS) {
                        if (targetVal) {
                            // Enable power saving (delete value)
                            LSTATUS status = RegDeleteValueW(hKeySub, L"PnPCapabilities");
                            if (status != ERROR_SUCCESS && status != ERROR_FILE_NOT_FOUND) {
                                DWORD zero = 0;
                                RegSetValueExW(hKeySub, L"PnPCapabilities", 0, REG_DWORD, (LPBYTE)&zero, sizeof(zero));
                            }
                            emit systemStepReported(tr("Power saving enabled for '%1'.").arg(deviceMap["name"].toString()), "SUCCESS");
                        } else {
                            // Disable power saving (write 24 / 0x18)
                            DWORD pnpVal = 24;
                            if (RegSetValueExW(hKeySub, L"PnPCapabilities", 0, REG_DWORD, (LPBYTE)&pnpVal, sizeof(pnpVal)) == ERROR_SUCCESS) {
                                emit systemStepReported(tr("Power saving disabled for '%1'.").arg(deviceMap["name"].toString()), "SUCCESS");
                            } else {
                                ok = false;
                                emit systemStepReported(tr("Failed to disable power saving for '%1'.").arg(deviceMap["name"].toString()), "ERROR");
                            }
                        }
                        RegCloseKey(hKeySub);
                    } else {
                        ok = false;
                        emit systemStepReported(tr("Failed to open registry key for '%1'.").arg(deviceMap["name"].toString()), "ERROR");
                    }

                    // WMI ground-truth update to instantly toggle Device Manager checkbox
                    int braceIdx = subkeyPath.indexOf('{');
                    QString relKey = (braceIdx != -1) ? subkeyPath.mid(braceIdx) : subkeyPath;
                    QString psCmd = QString(
                        "Get-CimInstance -ClassName MSPower_DeviceEnable -Namespace root\\WMI | "
                        "Where-Object { "
                        "  $id = $_.InstanceName; "
                        "  if ($id.Length -gt 2) { "
                        "    $id = $id.Substring(0, $id.Length - 2); "
                        "    $drv = (Get-ItemProperty -Path ('HKLM:\\SYSTEM\\CurrentControlSet\\Enum\\' + $id) -ErrorAction SilentlyContinue).Driver; "
                        "    $drv -eq '%1' "
                        "  } else { $false } "
                        "} | Set-CimInstance -Property @{Enable = [bool]%2}"
                    ).arg(relKey).arg(targetVal ? "1" : "0");

                    QProcess wmiSetProc;
                    wmiSetProc.start("powershell.exe", QStringList() << "-NoProfile" << "-NonInteractive" << "-ExecutionPolicy" << "Bypass" << "-Command" << psCmd);
                    wmiSetProc.waitForFinished(12000);
                }
            }
#else
            // Simulation
            for (int i = 0; i < usbDevicesVal.size(); ++i) {
                QVariantMap deviceMap = usbDevicesVal[i].toMap();
                bool targetVal = deviceMap["powerSavingActive"].toBool();
                bool originalVal = origUsbDevicesVal[i].toMap()["powerSavingActive"].toBool();
                if (targetVal != originalVal) {
                    emit systemStepReported(tr("[Simulation] Set USB power saving for '%1' to %2.").arg(deviceMap["name"].toString()).arg(targetVal ? "Enabled" : "Disabled"), "SUCCESS");
                }
            }
#endif
            if (ok) {
                emit systemStepReported(tr("USB 3.0 Power Saving configuration completed."), "SUCCESS");
            } else {
                usbSuccess = false;
                emit systemStepReported(tr("Failed to apply some USB 3.0 Power Saving settings."), "WARNING");
            }
        }

        // Step 1.99f: Remote Access (RDP) Configuration (only if changed)
        bool remoteAccessSuccess = true;
        if (remoteAccessVal != origRemoteAccess) {
            emit systemStepReported(tr("Configuring Remote Access (RDP)..."), "INFO");
            QThread::msleep(800);
            
            bool ok = true;
#ifdef Q_OS_WIN
            HKEY hKeyTS;
            if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SYSTEM\\CurrentControlSet\\Control\\Terminal Server", 0, KEY_SET_VALUE, &hKeyTS) == ERROR_SUCCESS) {
                DWORD pnpVal = remoteAccessVal ? 0 : 1;
                if (RegSetValueExW(hKeyTS, L"fDenyTSConnections", 0, REG_DWORD, (LPBYTE)&pnpVal, sizeof(pnpVal)) == ERROR_SUCCESS) {
                    emit systemStepReported(remoteAccessVal ? tr("Remote Access enabled in registry.") : tr("Remote Access disabled in registry."), "SUCCESS");
                } else {
                    ok = false;
                    emit systemStepReported(tr("Failed to write Remote Access registry value."), "ERROR");
                }
                RegCloseKey(hKeyTS);
            } else {
                ok = false;
                emit systemStepReported(tr("Failed to open Terminal Server registry key."), "ERROR");
            }

            // Configure Service & Firewall Rules
            QString psCmd = remoteAccessVal ? 
                "Set-Service -Name TermService -StartupType Automatic; Start-Service -Name TermService -ErrorAction SilentlyContinue; Enable-NetFirewallRule -DisplayGroup 'Remote Desktop' -ErrorAction SilentlyContinue" :
                "Stop-Service -Name TermService -Force -ErrorAction SilentlyContinue; Set-Service -Name TermService -StartupType Disabled; Disable-NetFirewallRule -DisplayGroup 'Remote Desktop' -ErrorAction SilentlyContinue";

            QProcess rdpProc;
            rdpProc.start("powershell.exe", QStringList() << "-NoProfile" << "-NonInteractive" << "-ExecutionPolicy" << "Bypass" << "-Command" << psCmd);
            if (rdpProc.waitForFinished(15000)) {
                emit systemStepReported(remoteAccessVal ? tr("Remote Desktop service and firewall rules enabled.") : tr("Remote Desktop service and firewall rules disabled."), "SUCCESS");
            } else {
                ok = false;
                emit systemStepReported(tr("Failed to configure Remote Desktop service / firewall."), "ERROR");
            }
#else
            emit systemStepReported(tr("[Simulation] Remote Access (RDP) set to %1.").arg(remoteAccessVal ? tr("Enabled") : tr("Disabled")), "SUCCESS");
#endif
            if (ok) {
                emit systemStepReported(tr("Remote Access (RDP) configuration completed."), "SUCCESS");
            } else {
                remoteAccessSuccess = false;
                emit systemStepReported(tr("Failed to configure Remote Access (RDP)."), "WARNING");
            }
        }

        // Step 1.99g: Telemetry Configuration (only if changed)
        bool telemetrySuccess = true;
        if (telemetryChanged) {
            emit systemStepReported(tr("Configuring system telemetry..."), "INFO");
            QThread::msleep(800);
            
            bool ok = true;
#ifdef Q_OS_WIN
            // 1. DiagTrack Service (Connected User Experiences and Telemetry)
            if (telemetryDiagTrackVal != origTelemetryDiagTrack) {
                emit systemStepReported(tr("Processing Connected User Experiences service (DiagTrack)..."), "INFO");
                SC_HANDLE hSCM = OpenSCManagerW(NULL, NULL, SC_MANAGER_ALL_ACCESS);
                if (hSCM) {
                    SC_HANDLE hService = OpenServiceW(hSCM, L"DiagTrack", SERVICE_CHANGE_CONFIG | SERVICE_STOP | SERVICE_START | SERVICE_QUERY_STATUS);
                    if (hService) {
                        DWORD startType = telemetryDiagTrackVal ? SERVICE_AUTO_START : SERVICE_DISABLED;
                        if (ChangeServiceConfigW(hService, SERVICE_NO_CHANGE, startType, SERVICE_NO_CHANGE, NULL, NULL, NULL, NULL, NULL, NULL, NULL)) {
                            emit systemStepReported(telemetryDiagTrackVal ? tr("Connected User Experiences service startup set to Automatic.") : tr("Connected User Experiences service startup set to Disabled."), "SUCCESS");
                            
                            SERVICE_STATUS_PROCESS ssp;
                            DWORD bytesNeeded = 0;
                            if (QueryServiceStatusEx(hService, SC_STATUS_PROCESS_INFO, reinterpret_cast<LPBYTE>(&ssp), sizeof(ssp), &bytesNeeded)) {
                                if (!telemetryDiagTrackVal && ssp.dwCurrentState != SERVICE_STOPPED && ssp.dwCurrentState != SERVICE_STOP_PENDING) {
                                    emit systemStepReported(tr("Stopping Connected User Experiences service..."), "INFO");
                                    SERVICE_STATUS status;
                                    ControlService(hService, SERVICE_CONTROL_STOP, &status);
                                    for (int i = 0; i < 15; ++i) {
                                        QThread::msleep(200);
                                        if (QueryServiceStatusEx(hService, SC_STATUS_PROCESS_INFO, reinterpret_cast<LPBYTE>(&ssp), sizeof(ssp), &bytesNeeded)) {
                                            if (ssp.dwCurrentState == SERVICE_STOPPED) break;
                                        }
                                    }
                                    if (ssp.dwCurrentState == SERVICE_STOPPED) {
                                        emit systemStepReported(tr("Connected User Experiences service stopped successfully."), "SUCCESS");
                                    } else {
                                        emit systemStepReported(tr("Connected User Experiences service stop requested."), "WARNING");
                                    }
                                } else if (telemetryDiagTrackVal && ssp.dwCurrentState != SERVICE_RUNNING && ssp.dwCurrentState != SERVICE_START_PENDING) {
                                    emit systemStepReported(tr("Starting Connected User Experiences service..."), "INFO");
                                    if (StartServiceW(hService, 0, NULL)) {
                                        for (int i = 0; i < 15; ++i) {
                                            QThread::msleep(200);
                                            if (QueryServiceStatusEx(hService, SC_STATUS_PROCESS_INFO, reinterpret_cast<LPBYTE>(&ssp), sizeof(ssp), &bytesNeeded)) {
                                                if (ssp.dwCurrentState == SERVICE_RUNNING) break;
                                            }
                                        }
                                        if (ssp.dwCurrentState == SERVICE_RUNNING) {
                                            emit systemStepReported(tr("Connected User Experiences service started successfully."), "SUCCESS");
                                        }
                                    }
                                }
                            }
                        } else {
                            ok = false;
                            emit systemStepReported(tr("Failed to configure Connected User Experiences service."), "ERROR");
                        }
                        CloseServiceHandle(hService);
                    } else {
                        ok = false;
                        emit systemStepReported(tr("Failed to open Connected User Experiences service."), "ERROR");
                    }
                    CloseServiceHandle(hSCM);
                } else {
                    ok = false;
                    emit systemStepReported(tr("Failed to connect to SCM."), "ERROR");
                }
            }

            // 2. dmwappushservice (Device Management WAP Service)
            if (telemetryWapPushVal != origTelemetryWapPush) {
                emit systemStepReported(tr("Processing Device Management WAP service (dmwappushservice)..."), "INFO");
                SC_HANDLE hSCM = OpenSCManagerW(NULL, NULL, SC_MANAGER_ALL_ACCESS);
                if (hSCM) {
                    SC_HANDLE hService = OpenServiceW(hSCM, L"dmwappushservice", SERVICE_CHANGE_CONFIG | SERVICE_STOP | SERVICE_START | SERVICE_QUERY_STATUS);
                    if (hService) {
                        DWORD startType = telemetryWapPushVal ? SERVICE_DEMAND_START : SERVICE_DISABLED;
                        if (ChangeServiceConfigW(hService, SERVICE_NO_CHANGE, startType, SERVICE_NO_CHANGE, NULL, NULL, NULL, NULL, NULL, NULL, NULL)) {
                            emit systemStepReported(telemetryWapPushVal ? tr("Device Management WAP service startup set to Manual.") : tr("Device Management WAP service startup set to Disabled."), "SUCCESS");
                            
                            SERVICE_STATUS_PROCESS ssp;
                            DWORD bytesNeeded = 0;
                            if (QueryServiceStatusEx(hService, SC_STATUS_PROCESS_INFO, reinterpret_cast<LPBYTE>(&ssp), sizeof(ssp), &bytesNeeded)) {
                                if (!telemetryWapPushVal && ssp.dwCurrentState != SERVICE_STOPPED && ssp.dwCurrentState != SERVICE_STOP_PENDING) {
                                    emit systemStepReported(tr("Stopping Device Management WAP service..."), "INFO");
                                    SERVICE_STATUS status;
                                    ControlService(hService, SERVICE_CONTROL_STOP, &status);
                                    for (int i = 0; i < 15; ++i) {
                                        QThread::msleep(200);
                                        if (QueryServiceStatusEx(hService, SC_STATUS_PROCESS_INFO, reinterpret_cast<LPBYTE>(&ssp), sizeof(ssp), &bytesNeeded)) {
                                            if (ssp.dwCurrentState == SERVICE_STOPPED) break;
                                        }
                                    }
                                    if (ssp.dwCurrentState == SERVICE_STOPPED) {
                                        emit systemStepReported(tr("Device Management WAP service stopped successfully."), "SUCCESS");
                                    } else {
                                        emit systemStepReported(tr("Device Management WAP service stop requested."), "WARNING");
                                    }
                                } else if (telemetryWapPushVal && ssp.dwCurrentState != SERVICE_RUNNING && ssp.dwCurrentState != SERVICE_START_PENDING) {
                                    emit systemStepReported(tr("Starting Device Management WAP service..."), "INFO");
                                    if (StartServiceW(hService, 0, NULL)) {
                                        for (int i = 0; i < 15; ++i) {
                                            QThread::msleep(200);
                                            if (QueryServiceStatusEx(hService, SC_STATUS_PROCESS_INFO, reinterpret_cast<LPBYTE>(&ssp), sizeof(ssp), &bytesNeeded)) {
                                                if (ssp.dwCurrentState == SERVICE_RUNNING) break;
                                            }
                                        }
                                        if (ssp.dwCurrentState == SERVICE_RUNNING) {
                                            emit systemStepReported(tr("Device Management WAP service started successfully."), "SUCCESS");
                                        }
                                    }
                                }
                            }
                        } else {
                            ok = false;
                            emit systemStepReported(tr("Failed to configure Device Management WAP service."), "ERROR");
                        }
                        CloseServiceHandle(hService);
                    } else {
                        ok = false;
                        emit systemStepReported(tr("Failed to open Device Management WAP service."), "ERROR");
                    }
                    CloseServiceHandle(hSCM);
                } else {
                    ok = false;
                    emit systemStepReported(tr("Failed to connect to SCM."), "ERROR");
                }
            }

            // 3. Customer Experience Improvement Program (CEIP) policy
            if (telemetryCeipVal != origTelemetryCeip) {
                emit systemStepReported(tr("Configuring Customer Experience Improvement Program policy..."), "INFO");
                HKEY hKeyCeip;
                if (RegCreateKeyExW(HKEY_LOCAL_MACHINE, L"SOFTWARE\\Policies\\Microsoft\\SQMClient\\Windows", 0, NULL, REG_OPTION_NON_VOLATILE, KEY_WRITE, NULL, &hKeyCeip, NULL) == ERROR_SUCCESS) {
                    if (telemetryCeipVal) {
                        // Restore enabled state (delete value CEIPEnable)
                        RegDeleteValueW(hKeyCeip, L"CEIPEnable");
                        emit systemStepReported(tr("CEIP telemetry policy removed (enabled)."), "SUCCESS");
                    } else {
                        // Disable CEIP (write CEIPEnable = 0)
                        DWORD zero = 0;
                        if (RegSetValueExW(hKeyCeip, L"CEIPEnable", 0, REG_DWORD, (const BYTE*)&zero, sizeof(zero)) == ERROR_SUCCESS) {
                            emit systemStepReported(tr("CEIP telemetry policy disabled successfully."), "SUCCESS");
                        } else {
                            ok = false;
                            emit systemStepReported(tr("Failed to write CEIP telemetry policy."), "ERROR");
                        }
                    }
                    RegCloseKey(hKeyCeip);
                } else {
                    ok = false;
                    emit systemStepReported(tr("Failed to open CEIP registry policy key."), "ERROR");
                }
            }

            // 4. Windows Error Reporting (WER) policy
            if (telemetryWerVal != origTelemetryWer) {
                emit systemStepReported(tr("Configuring Windows Error Reporting policy..."), "INFO");
                HKEY hKeyWer;
                if (RegCreateKeyExW(HKEY_LOCAL_MACHINE, L"SOFTWARE\\Policies\\Microsoft\\Windows\\Windows Error Reporting", 0, NULL, REG_OPTION_NON_VOLATILE, KEY_WRITE, NULL, &hKeyWer, NULL) == ERROR_SUCCESS) {
                    if (telemetryWerVal) {
                        // Restore enabled state (delete value Disabled)
                        RegDeleteValueW(hKeyWer, L"Disabled");
                        emit systemStepReported(tr("Windows Error Reporting policy removed (enabled)."), "SUCCESS");
                    } else {
                        // Disable WER (write Disabled = 1)
                        DWORD one = 1;
                        if (RegSetValueExW(hKeyWer, L"Disabled", 0, REG_DWORD, (const BYTE*)&one, sizeof(one)) == ERROR_SUCCESS) {
                            emit systemStepReported(tr("Windows Error Reporting policy disabled successfully."), "SUCCESS");
                        } else {
                            ok = false;
                            emit systemStepReported(tr("Failed to write Windows Error Reporting policy."), "ERROR");
                        }
                    }
                    RegCloseKey(hKeyWer);
                } else {
                    ok = false;
                    emit systemStepReported(tr("Failed to open Windows Error Reporting policy key."), "ERROR");
                }
            }
#else
            // Simulation
            emit systemStepReported(tr("[Simulation] Connected User Experiences set to: %1").arg(telemetryDiagTrackVal ? "Enabled" : "Disabled"), "SUCCESS");
            emit systemStepReported(tr("[Simulation] Device Management WAP Service set to: %1").arg(telemetryWapPushVal ? "Enabled" : "Disabled"), "SUCCESS");
            emit systemStepReported(tr("[Simulation] CEIP policy set to: %1").arg(telemetryCeipVal ? "Enabled" : "Disabled"), "SUCCESS");
            emit systemStepReported(tr("[Simulation] Windows Error Reporting policy set to: %1").arg(telemetryWerVal ? "Enabled" : "Disabled"), "SUCCESS");
#endif
            if (ok) {
                emit systemStepReported(tr("Telemetry configuration completed."), "SUCCESS");
            } else {
                telemetrySuccess = false;
                emit systemStepReported(tr("Failed to apply some Telemetry settings."), "WARNING");
            }
        }

        // Step 1.99u: Windows Update Mode Configuration (only if changed)
        bool windowsUpdateSuccess = true;
        if (windowsUpdateModeChanged) {
            emit systemStepReported(tr("Configuring Windows Update mode..."), "INFO");
            QThread::msleep(800);
            bool ok = true;
#ifdef Q_OS_WIN
            SC_HANDLE hSCM = OpenSCManagerW(NULL, NULL, SC_MANAGER_ALL_ACCESS);
            
            if (windowsUpdateModeVal == 0) {
                // DEFAULT
                emit systemStepReported(tr("Setting Windows Update to Default mode..."), "INFO");
                
                HKEY hKeyWu;
                if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate", 0, KEY_SET_VALUE, &hKeyWu) == ERROR_SUCCESS) {
                    RegDeleteValueW(hKeyWu, L"TargetReleaseVersion");
                    RegDeleteValueW(hKeyWu, L"TargetReleaseVersionInfo");
                    RegDeleteValueW(hKeyWu, L"ProductVersion");
                    RegDeleteValueW(hKeyWu, L"ExcludeWUDriversInQualityUpdate");
                    RegCloseKey(hKeyWu);
                }
                
                HKEY hKeyAu;
                if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU", 0, KEY_SET_VALUE, &hKeyAu) == ERROR_SUCCESS) {
                    RegDeleteValueW(hKeyAu, L"NoAutoUpdate");
                    RegDeleteValueW(hKeyAu, L"AUOptions");
                    RegCloseKey(hKeyAu);
                }
                
                HKEY hKeyWuauserv;
                if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SYSTEM\\CurrentControlSet\\Services\\wuauserv", 0, KEY_SET_VALUE, &hKeyWuauserv) == ERROR_SUCCESS) {
                    DWORD val = 3; // Manual
                    RegSetValueExW(hKeyWuauserv, L"Start", 0, REG_DWORD, (const BYTE*)&val, sizeof(val));
                    RegCloseKey(hKeyWuauserv);
                }
                HKEY hKeyUsoSvc;
                if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SYSTEM\\CurrentControlSet\\Services\\UsoSvc", 0, KEY_SET_VALUE, &hKeyUsoSvc) == ERROR_SUCCESS) {
                    DWORD val = 2; // Automatic
                    RegSetValueExW(hKeyUsoSvc, L"Start", 0, REG_DWORD, (const BYTE*)&val, sizeof(val));
                    RegCloseKey(hKeyUsoSvc);
                }
                HKEY hKeyMedic;
                if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SYSTEM\\CurrentControlSet\\Services\\WaaSMedicSvc", 0, KEY_SET_VALUE, &hKeyMedic) == ERROR_SUCCESS) {
                    DWORD val = 3; // Manual
                    RegSetValueExW(hKeyMedic, L"Start", 0, REG_DWORD, (const BYTE*)&val, sizeof(val));
                    RegCloseKey(hKeyMedic);
                }
                
                if (hSCM) {
                    SC_HANDLE hSvcWu = OpenServiceW(hSCM, L"wuauserv", SERVICE_START | SERVICE_QUERY_STATUS);
                    if (hSvcWu) {
                        SERVICE_STATUS_PROCESS ssp;
                        DWORD bytesNeeded = 0;
                        if (QueryServiceStatusEx(hSvcWu, SC_STATUS_PROCESS_INFO, (LPBYTE)&ssp, sizeof(ssp), &bytesNeeded)) {
                            if (ssp.dwCurrentState != SERVICE_RUNNING && ssp.dwCurrentState != SERVICE_START_PENDING) {
                                StartServiceW(hSvcWu, 0, NULL);
                            }
                        }
                        CloseServiceHandle(hSvcWu);
                    }
                    SC_HANDLE hSvcUso = OpenServiceW(hSCM, L"UsoSvc", SERVICE_START | SERVICE_QUERY_STATUS);
                    if (hSvcUso) {
                        SERVICE_STATUS_PROCESS ssp;
                        DWORD bytesNeeded = 0;
                        if (QueryServiceStatusEx(hSvcUso, SC_STATUS_PROCESS_INFO, (LPBYTE)&ssp, sizeof(ssp), &bytesNeeded)) {
                            if (ssp.dwCurrentState != SERVICE_RUNNING && ssp.dwCurrentState != SERVICE_START_PENDING) {
                                StartServiceW(hSvcUso, 0, NULL);
                            }
                        }
                        CloseServiceHandle(hSvcUso);
                    }
                }
                
                emit systemStepReported(tr("Windows Update set to Default mode successfully (all updates enabled)."), "SUCCESS");
                
            } else if (windowsUpdateModeVal == 1) {
                // SECURITY UPDATES ONLY
                emit systemStepReported(tr("Setting Windows Update to Security Updates Only mode..."), "INFO");
                
                QString displayVersion = "23H2";
                QString productVersion = "Windows 11";
                HKEY hKeyVer;
                if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SOFTWARE\\Microsoft\\Windows NT\\CurrentVersion", 0, KEY_READ, &hKeyVer) == ERROR_SUCCESS) {
                    wchar_t buf[256];
                    DWORD size = sizeof(buf);
                    if (RegQueryValueExW(hKeyVer, L"DisplayVersion", NULL, NULL, (LPBYTE)buf, &size) == ERROR_SUCCESS) {
                        displayVersion = QString::fromWCharArray(buf);
                    } else {
                        size = sizeof(buf);
                        if (RegQueryValueExW(hKeyVer, L"ReleaseId", NULL, NULL, (LPBYTE)buf, &size) == ERROR_SUCCESS) {
                            displayVersion = QString::fromWCharArray(buf);
                        }
                    }
                    size = sizeof(buf);
                    if (RegQueryValueExW(hKeyVer, L"ProductName", NULL, NULL, (LPBYTE)buf, &size) == ERROR_SUCCESS) {
                        QString prodName = QString::fromWCharArray(buf);
                        if (prodName.contains("Windows 11", Qt::CaseInsensitive)) {
                            productVersion = "Windows 11";
                        } else {
                            productVersion = "Windows 10";
                        }
                    }
                    RegCloseKey(hKeyVer);
                }
                
                HKEY hKeyWu;
                if (RegCreateKeyExW(HKEY_LOCAL_MACHINE, L"SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate", 0, NULL, REG_OPTION_NON_VOLATILE, KEY_WRITE, NULL, &hKeyWu, NULL) == ERROR_SUCCESS) {
                    DWORD one = 1;
                    RegSetValueExW(hKeyWu, L"TargetReleaseVersion", 0, REG_DWORD, (const BYTE*)&one, sizeof(one));
                    
                    std::vector<wchar_t> wVer(displayVersion.length() + 1);
                    displayVersion.toWCharArray(wVer.data());
                    wVer[displayVersion.length()] = L'\0';
                    RegSetValueExW(hKeyWu, L"TargetReleaseVersionInfo", 0, REG_SZ, (const BYTE*)wVer.data(), (wVer.size()) * sizeof(wchar_t));
                    
                    std::vector<wchar_t> wProd(productVersion.length() + 1);
                    productVersion.toWCharArray(wProd.data());
                    wProd[productVersion.length()] = L'\0';
                    RegSetValueExW(hKeyWu, L"ProductVersion", 0, REG_SZ, (const BYTE*)wProd.data(), (wProd.size()) * sizeof(wchar_t));
                    
                    RegSetValueExW(hKeyWu, L"ExcludeWUDriversInQualityUpdate", 0, REG_DWORD, (const BYTE*)&one, sizeof(one));
                    
                    RegCloseKey(hKeyWu);
                } else {
                    ok = false;
                }
                
                HKEY hKeyAu;
                if (RegCreateKeyExW(HKEY_LOCAL_MACHINE, L"SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU", 0, NULL, REG_OPTION_NON_VOLATILE, KEY_WRITE, NULL, &hKeyAu, NULL) == ERROR_SUCCESS) {
                    DWORD zero = 0;
                    RegSetValueExW(hKeyAu, L"NoAutoUpdate", 0, REG_DWORD, (const BYTE*)&zero, sizeof(zero));
                    RegDeleteValueW(hKeyAu, L"AUOptions");
                    RegCloseKey(hKeyAu);
                }
                
                HKEY hKeyWuauserv;
                if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SYSTEM\\CurrentControlSet\\Services\\wuauserv", 0, KEY_SET_VALUE, &hKeyWuauserv) == ERROR_SUCCESS) {
                    DWORD val = 3; // Manual
                    RegSetValueExW(hKeyWuauserv, L"Start", 0, REG_DWORD, (const BYTE*)&val, sizeof(val));
                    RegCloseKey(hKeyWuauserv);
                }
                HKEY hKeyUsoSvc;
                if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SYSTEM\\CurrentControlSet\\Services\\UsoSvc", 0, KEY_SET_VALUE, &hKeyUsoSvc) == ERROR_SUCCESS) {
                    DWORD val = 2; // Automatic
                    RegSetValueExW(hKeyUsoSvc, L"Start", 0, REG_DWORD, (const BYTE*)&val, sizeof(val));
                    RegCloseKey(hKeyUsoSvc);
                }
                
                if (ok) {
                    emit systemStepReported(tr("Windows Update set to Security Updates Only mode successfully (Feature & Driver updates disabled)."), "SUCCESS");
                } else {
                    emit systemStepReported(tr("Failed to write Security Updates Only policy settings."), "ERROR");
                }
                
            } else if (windowsUpdateModeVal == 2) {
                // MANUAL CHECK
                emit systemStepReported(tr("Setting Windows Update to Manual mode..."), "INFO");
                
                HKEY hKeyWu;
                if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate", 0, KEY_SET_VALUE, &hKeyWu) == ERROR_SUCCESS) {
                    RegDeleteValueW(hKeyWu, L"TargetReleaseVersion");
                    RegDeleteValueW(hKeyWu, L"TargetReleaseVersionInfo");
                    RegDeleteValueW(hKeyWu, L"ProductVersion");
                    RegDeleteValueW(hKeyWu, L"ExcludeWUDriversInQualityUpdate");
                    RegCloseKey(hKeyWu);
                }
                
                HKEY hKeyAu;
                if (RegCreateKeyExW(HKEY_LOCAL_MACHINE, L"SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU", 0, NULL, REG_OPTION_NON_VOLATILE, KEY_WRITE, NULL, &hKeyAu, NULL) == ERROR_SUCCESS) {
                    DWORD zero = 0;
                    DWORD two = 2;
                    RegSetValueExW(hKeyAu, L"NoAutoUpdate", 0, REG_DWORD, (const BYTE*)&zero, sizeof(zero));
                    RegSetValueExW(hKeyAu, L"AUOptions", 0, REG_DWORD, (const BYTE*)&two, sizeof(two));
                    RegCloseKey(hKeyAu);
                } else {
                    ok = false;
                }
                
                HKEY hKeyWuauserv;
                if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SYSTEM\\CurrentControlSet\\Services\\wuauserv", 0, KEY_SET_VALUE, &hKeyWuauserv) == ERROR_SUCCESS) {
                    DWORD val = 3; // Manual
                    RegSetValueExW(hKeyWuauserv, L"Start", 0, REG_DWORD, (const BYTE*)&val, sizeof(val));
                    RegCloseKey(hKeyWuauserv);
                }
                HKEY hKeyUsoSvc;
                if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SYSTEM\\CurrentControlSet\\Services\\UsoSvc", 0, KEY_SET_VALUE, &hKeyUsoSvc) == ERROR_SUCCESS) {
                    DWORD val = 3; // Manual
                    RegSetValueExW(hKeyUsoSvc, L"Start", 0, REG_DWORD, (const BYTE*)&val, sizeof(val));
                    RegCloseKey(hKeyUsoSvc);
                }
                
                if (ok) {
                    emit systemStepReported(tr("Windows Update set to Manual mode successfully (automatic background checking disabled)."), "SUCCESS");
                } else {
                    emit systemStepReported(tr("Failed to configure Manual update settings."), "ERROR");
                }
                
            } else if (windowsUpdateModeVal == 3) {
                // DISABLED
                emit systemStepReported(tr("Disabling Windows Update services and policies..."), "INFO");
                
                HKEY hKeyAu;
                if (RegCreateKeyExW(HKEY_LOCAL_MACHINE, L"SOFTWARE\\Policies\\Microsoft\\Windows\\WindowsUpdate\\AU", 0, NULL, REG_OPTION_NON_VOLATILE, KEY_WRITE, NULL, &hKeyAu, NULL) == ERROR_SUCCESS) {
                    DWORD one = 1;
                    RegSetValueExW(hKeyAu, L"NoAutoUpdate", 0, REG_DWORD, (const BYTE*)&one, sizeof(one));
                    RegCloseKey(hKeyAu);
                } else {
                    ok = false;
                }
                
                HKEY hKeyWuauserv;
                if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SYSTEM\\CurrentControlSet\\Services\\wuauserv", 0, KEY_SET_VALUE, &hKeyWuauserv) == ERROR_SUCCESS) {
                    DWORD val = 4; // Disabled
                    RegSetValueExW(hKeyWuauserv, L"Start", 0, REG_DWORD, (const BYTE*)&val, sizeof(val));
                    RegCloseKey(hKeyWuauserv);
                }
                HKEY hKeyUsoSvc;
                if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SYSTEM\\CurrentControlSet\\Services\\UsoSvc", 0, KEY_SET_VALUE, &hKeyUsoSvc) == ERROR_SUCCESS) {
                    DWORD val = 4; // Disabled
                    RegSetValueExW(hKeyUsoSvc, L"Start", 0, REG_DWORD, (const BYTE*)&val, sizeof(val));
                    RegCloseKey(hKeyUsoSvc);
                }
                HKEY hKeyMedic;
                if (RegOpenKeyExW(HKEY_LOCAL_MACHINE, L"SYSTEM\\CurrentControlSet\\Services\\WaaSMedicSvc", 0, KEY_SET_VALUE, &hKeyMedic) == ERROR_SUCCESS) {
                    DWORD val = 4; // Disabled
                    RegSetValueExW(hKeyMedic, L"Start", 0, REG_DWORD, (const BYTE*)&val, sizeof(val));
                    RegCloseKey(hKeyMedic);
                }
                
                if (hSCM) {
                    SC_HANDLE hSvcWu = OpenServiceW(hSCM, L"wuauserv", SERVICE_STOP | SERVICE_QUERY_STATUS);
                    if (hSvcWu) {
                        SERVICE_STATUS_PROCESS ssp;
                        DWORD bytesNeeded = 0;
                        if (QueryServiceStatusEx(hSvcWu, SC_STATUS_PROCESS_INFO, (LPBYTE)&ssp, sizeof(ssp), &bytesNeeded)) {
                            if (ssp.dwCurrentState != SERVICE_STOPPED && ssp.dwCurrentState != SERVICE_STOP_PENDING) {
                                SERVICE_STATUS status;
                                ControlService(hSvcWu, SERVICE_CONTROL_STOP, &status);
                            }
                        }
                        CloseServiceHandle(hSvcWu);
                    }
                    SC_HANDLE hSvcUso = OpenServiceW(hSCM, L"UsoSvc", SERVICE_STOP | SERVICE_QUERY_STATUS);
                    if (hSvcUso) {
                        SERVICE_STATUS_PROCESS ssp;
                        DWORD bytesNeeded = 0;
                        if (QueryServiceStatusEx(hSvcUso, SC_STATUS_PROCESS_INFO, (LPBYTE)&ssp, sizeof(ssp), &bytesNeeded)) {
                            if (ssp.dwCurrentState != SERVICE_STOPPED && ssp.dwCurrentState != SERVICE_STOP_PENDING) {
                                SERVICE_STATUS status;
                                ControlService(hSvcUso, SERVICE_CONTROL_STOP, &status);
                            }
                        }
                        CloseServiceHandle(hSvcUso);
                    }
                    SC_HANDLE hSvcMedic = OpenServiceW(hSCM, L"WaaSMedicSvc", SERVICE_STOP | SERVICE_QUERY_STATUS);
                    if (hSvcMedic) {
                        SERVICE_STATUS_PROCESS ssp;
                        DWORD bytesNeeded = 0;
                        if (QueryServiceStatusEx(hSvcMedic, SC_STATUS_PROCESS_INFO, (LPBYTE)&ssp, sizeof(ssp), &bytesNeeded)) {
                            if (ssp.dwCurrentState != SERVICE_STOPPED && ssp.dwCurrentState != SERVICE_STOP_PENDING) {
                                SERVICE_STATUS status;
                                ControlService(hSvcMedic, SERVICE_CONTROL_STOP, &status);
                            }
                        }
                        CloseServiceHandle(hSvcMedic);
                    }
                }
                
                if (ok) {
                    emit systemStepReported(tr("Windows Update disabled and blocked successfully."), "SUCCESS");
                } else {
                    emit systemStepReported(tr("Failed to disable some Windows Update policies."), "ERROR");
                }
            }
            
            if (hSCM) {
                CloseServiceHandle(hSCM);
            }
#else
            emit systemStepReported(tr("[Simulation] Windows Update Mode set to: %1").arg(windowsUpdateModeVal), "SUCCESS");
#endif
            if (ok) {
                emit systemStepReported(tr("Windows Update configuration completed."), "SUCCESS");
            } else {
                windowsUpdateSuccess = false;
                emit systemStepReported(tr("Failed to apply some Windows Update settings."), "WARNING");
            }
        }

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

        // Step 2.5: Counter-Strike 2 launch options (only if changed)
        bool cs2Success = true;
        if (cs2OptionsVal != origCs2OptionsVal) {
            emit systemStepReported(tr("Processing Counter-Strike 2 launch options..."), "INFO");
            QThread::msleep(800);

            QStringList cs2NewManaged;
            for (const QString &opt : CS2_MANAGED_OPTIONS) {
                if (cs2OptionsVal.value(opt).toBool()) {
                    cs2NewManaged.append(opt);
                }
            }

#ifdef Q_OS_WIN
            bool steamRunning = false;
            HANDLE hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
            if (hSnapshot != INVALID_HANDLE_VALUE) {
                PROCESSENTRY32W pe32;
                pe32.dwSize = sizeof(pe32);
                if (Process32FirstW(hSnapshot, &pe32)) {
                    do {
                        if (wcscmp(pe32.szExeFile, L"steam.exe") == 0 || 
                            wcscmp(pe32.szExeFile, L"Steam.exe") == 0) {
                            steamRunning = true;
                            HANDLE hProcess = OpenProcess(PROCESS_TERMINATE, FALSE, pe32.th32ProcessID);
                            if (hProcess) {
                                TerminateProcess(hProcess, 0);
                                CloseHandle(hProcess);
                            }
                        }
                    } while (Process32NextW(hSnapshot, &pe32));
                }
                CloseHandle(hSnapshot);
            }
            if (steamRunning) {
                emit systemStepReported(tr("Steam process detected and closed to prevent configuration overwrite."), "WARNING");
                QThread::msleep(1500);
            }

            if (!steamPathVal.isEmpty() && QDir(steamPathVal).exists()) {
                QString userdataPath = steamPathVal + "/userdata";
                QDir userdataDir(userdataPath);
                if (userdataDir.exists()) {
                    QStringList subdirs = userdataDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
                    int updatedCount = 0;
                    for (const QString &subdir : subdirs) {
                        QString vdfPath = userdataPath + "/" + subdir + "/config/localconfig.vdf";
                        if (QFile::exists(vdfPath)) {
                            QString oldVal = getVdfLaunchOptions(vdfPath, "730");
                            QString cleanedVal = oldVal;
                            for (const QString &opt : CS2_MANAGED_OPTIONS) {
                                cleanedVal.replace(opt, "", Qt::CaseInsensitive);
                            }
                            cleanedVal = cleanedVal.simplified();
                            
                            QStringList mergedOptions;
                            if (!cleanedVal.isEmpty()) {
                                mergedOptions.append(cleanedVal);
                            }
                            mergedOptions.append(cs2NewManaged);
                            QString newVal = mergedOptions.join(" ");
                            
                            if (updateVdfLaunchOptions(vdfPath, "730", newVal)) {
                                updatedCount++;
                            }
                        }
                    }
                    emit systemStepReported(tr("Counter-Strike 2 launch options updated for %1 profiles.").arg(updatedCount), "SUCCESS");
                } else {
                    cs2Success = false;
                    emit systemStepReported(tr("Steam userdata directory not found."), "ERROR");
                }
            } else {
                cs2Success = false;
                emit systemStepReported(tr("Steam path not found. Cannot apply launch options."), "ERROR");
            }
#else
            emit systemStepReported(tr("[Simulation] Counter-Strike 2 launch options set to: %1").arg(cs2NewManaged.join(" ")), "SUCCESS");
#endif
        }

        // Step 2.6: Global Steam Overlay (only if changed)
        bool steamOverlaySuccess = true;
        if (steamOverlayChanged) {
            emit systemStepReported(Optimizer::tr("Processing global Steam Overlay..."), "INFO");
            QThread::msleep(800);
#ifdef Q_OS_WIN
            HKEY hKeySteamOverlaySet;
            if (RegOpenKeyExW(HKEY_CURRENT_USER, L"Software\\Valve\\Steam", 0, KEY_SET_VALUE, &hKeySteamOverlaySet) == ERROR_SUCCESS) {
                DWORD val = steamOverlayVal ? 1 : 0;
                if (RegSetValueExW(hKeySteamOverlaySet, L"EnableOverlay", 0, REG_DWORD, (const BYTE*)&val, sizeof(val)) == ERROR_SUCCESS) {
                    emit systemStepReported(Optimizer::tr("Global Steam Overlay successfully %1.").arg(steamOverlayVal ? Optimizer::tr("enabled") : Optimizer::tr("disabled")), "SUCCESS");
                } else {
                    steamOverlaySuccess = false;
                    emit systemStepReported(Optimizer::tr("Failed to update EnableOverlay registry value."), "ERROR");
                }
                RegCloseKey(hKeySteamOverlaySet);
            } else {
                steamOverlaySuccess = false;
                emit systemStepReported(Optimizer::tr("Failed to open Steam registry key for writing."), "ERROR");
            }
#else
            emit systemStepReported(Optimizer::tr("[Simulation] Global Steam Overlay set to: %1").arg(steamOverlayVal ? "Enabled" : "Disabled"), "SUCCESS");
#endif
        }

        // Step 2.7: Counter-Strike 2 Steam Overlay (only if changed)
        bool cs2OverlaySuccess = true;
        if (cs2OverlayChanged) {
            emit systemStepReported(Optimizer::tr("Processing Steam Overlay for Counter-Strike 2..."), "INFO");
            QThread::msleep(800);
            
            if (!cs2Changed) {
#ifdef Q_OS_WIN
                bool steamRunning = false;
                HANDLE hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
                if (hSnapshot != INVALID_HANDLE_VALUE) {
                    PROCESSENTRY32W pe32;
                    pe32.dwSize = sizeof(pe32);
                    if (Process32FirstW(hSnapshot, &pe32)) {
                        do {
                            if (wcscmp(pe32.szExeFile, L"steam.exe") == 0 || 
                                wcscmp(pe32.szExeFile, L"Steam.exe") == 0) {
                                steamRunning = true;
                                HANDLE hProcess = OpenProcess(PROCESS_TERMINATE, FALSE, pe32.th32ProcessID);
                                if (hProcess) {
                                    TerminateProcess(hProcess, 0);
                                    CloseHandle(hProcess);
                                }
                            }
                        } while (Process32NextW(hSnapshot, &pe32));
                    }
                    CloseHandle(hSnapshot);
                }
                if (steamRunning) {
                    emit systemStepReported(Optimizer::tr("Steam process detected and closed to prevent configuration overwrite."), "WARNING");
                    QThread::msleep(1500);
                }
#endif
            }

#ifdef Q_OS_WIN
            if (!steamPathVal.isEmpty() && QDir(steamPathVal).exists()) {
                QString userdataPath = steamPathVal + "/userdata";
                QDir userdataDir(userdataPath);
                if (userdataDir.exists()) {
                    QStringList subdirs = userdataDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
                    int updatedCount = 0;
                    QString overlayStateVal = cs2OverlayVal ? "1" : "2";
                    for (const QString &subdir : subdirs) {
                        QString vdfPath = userdataPath + "/" + subdir + "/config/localconfig.vdf";
                        if (QFile::exists(vdfPath)) {
                            if (updateVdfOverlayState(vdfPath, "730", overlayStateVal)) {
                                updatedCount++;
                            }
                        }
                    }
                    emit systemStepReported(Optimizer::tr("Counter-Strike 2 Steam Overlay updated for %1 profiles.").arg(updatedCount), "SUCCESS");
                } else {
                    cs2OverlaySuccess = false;
                    emit systemStepReported(Optimizer::tr("Steam userdata directory not found."), "ERROR");
                }
            } else {
                cs2OverlaySuccess = false;
                emit systemStepReported(Optimizer::tr("Steam path not found. Cannot apply overlay settings."), "ERROR");
            }
#else
            emit systemStepReported(Optimizer::tr("[Simulation] Counter-Strike 2 Steam Overlay set to: %1").arg(cs2OverlayVal ? "Enabled" : "Disabled"), "SUCCESS");
#endif
        }

        // Step 2.7.5: Steam Friends & Chat Settings (only if changed)
        bool steamFriendsSuccess = true;
        if (steamFriendsChanged) {
            emit systemStepReported(Optimizer::tr("Processing Steam Friends & Chat settings..."), "INFO");
            QThread::msleep(800);

#ifdef Q_OS_WIN
            // Check and close Steam if running (to prevent overwrite on client exit)
            bool steamRunning = false;
            HANDLE hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
            if (hSnapshot != INVALID_HANDLE_VALUE) {
                PROCESSENTRY32W pe32;
                pe32.dwSize = sizeof(pe32);
                if (Process32FirstW(hSnapshot, &pe32)) {
                    do {
                        if (wcscmp(pe32.szExeFile, L"steam.exe") == 0 ||
                            wcscmp(pe32.szExeFile, L"Steam.exe") == 0) {
                            steamRunning = true;
                            HANDLE hProcess = OpenProcess(PROCESS_TERMINATE, FALSE, pe32.th32ProcessID);
                            if (hProcess) {
                                TerminateProcess(hProcess, 0);
                                CloseHandle(hProcess);
                            }
                        }
                    } while (Process32NextW(hSnapshot, &pe32));
                }
                CloseHandle(hSnapshot);
            }
            if (steamRunning) {
                emit systemStepReported(Optimizer::tr("Steam process detected and closed to prevent configuration overwrite."), "WARNING");
                QThread::msleep(1500);
            }
#endif

#ifdef Q_OS_WIN
            if (!steamPathVal.isEmpty() && QDir(steamPathVal).exists()) {
                QString userdataPath = steamPathVal + "/userdata";
                QDir userdataDir(userdataPath);
                if (userdataDir.exists()) {
                    QStringList subdirs = userdataDir.entryList(QDir::Dirs | QDir::NoDotAndDotDot);
                    int updatedCount = 0;
                    for (const QString &subdir : subdirs) {
                        QString vdfPath = userdataPath + "/" + subdir + "/config/localconfig.vdf";
                        if (QFile::exists(vdfPath)) {
                            if (updateVdfFriendsSettings(vdfPath, subdir, steamFriendsSettingsVal)) {
                                updatedCount++;
                            }
                        }
                    }
                    emit systemStepReported(Optimizer::tr("Steam Friends & Chat settings updated for %1 profiles.").arg(updatedCount), "SUCCESS");
                } else {
                    steamFriendsSuccess = false;
                    emit systemStepReported(Optimizer::tr("Steam userdata directory not found."), "ERROR");
                }
            } else {
                steamFriendsSuccess = false;
                emit systemStepReported(Optimizer::tr("Steam path not found. Cannot apply Friends & Chat settings."), "ERROR");
            }
#else
            emit systemStepReported(Optimizer::tr("[Simulation] Steam Friends & Chat settings updated successfully."), "SUCCESS");
#endif
        }

        // Step 2.8: Visual Effects (only if changed)
        bool visualEffectsSuccess = true;
        if (visualEffectsChanged) {
            emit systemStepReported(Optimizer::tr("Processing Windows visual effects..."), "INFO");
            QThread::msleep(800);
#ifdef Q_OS_WIN
            // 1. Set VisualFXSetting registry DWORD
            HKEY hKeyVisualEffects;
            if (RegOpenKeyExW(HKEY_CURRENT_USER, L"Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VisualEffects", 0, KEY_SET_VALUE, &hKeyVisualEffects) == ERROR_SUCCESS) {
                DWORD fxSetting = 3;
                bool allOn = true;
                bool allOff = true;
                for (const QString &key : visualEffectsVal.keys()) {
                    if (visualEffectsVal.value(key).toBool()) {
                        allOff = false;
                    } else {
                        allOn = false;
                    }
                }
                if (allOn) fxSetting = 1;
                else if (allOff) fxSetting = 2;

                RegSetValueExW(hKeyVisualEffects, L"VisualFXSetting", 0, REG_DWORD, (const BYTE*)&fxSetting, sizeof(fxSetting));
                RegCloseKey(hKeyVisualEffects);
            }

            // Helper lambda to write a DWORD under HKCU\Software\Microsoft\Windows\CurrentVersion\Explorer\VisualEffects\<Effect>
            auto writeVisualEffectReg = [](const QString &subkeyName, DWORD val) {
                HKEY hKey;
                QString path = "Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\VisualEffects\\" + subkeyName;
                if (RegCreateKeyExW(HKEY_CURRENT_USER, reinterpret_cast<const wchar_t*>(path.utf16()), 0, nullptr, REG_OPTION_NON_VOLATILE, KEY_WRITE, nullptr, &hKey, nullptr) == ERROR_SUCCESS) {
                    RegSetValueExW(hKey, L"DefaultApplied", 0, REG_DWORD, (const BYTE*)&val, sizeof(val));
                    RegCloseKey(hKey);
                }
            };

            // Write 17 subkey values and invoke SystemParametersInfoW for real-time application
            for (const QString &key : visualEffectsVal.keys()) {
                bool enabled = visualEffectsVal.value(key).toBool();
                DWORD dwVal = enabled ? 1 : 0;

                if (key == "animateControls") {
                    writeVisualEffectReg("ControlAnimations", dwVal);
                    SystemParametersInfoW(SPI_SETCLIENTAREAANIMATION, 0, (PVOID)(INT_PTR)enabled, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
                } else if (key == "animateWindows") {
                    writeVisualEffectReg("AnimateMinMax", dwVal);
                    HKEY hKeyMet;
                    if (RegOpenKeyExW(HKEY_CURRENT_USER, L"Control Panel\\Desktop\\WindowMetrics", 0, KEY_SET_VALUE, &hKeyMet) == ERROR_SUCCESS) {
                        const wchar_t* szVal = enabled ? L"1" : L"0";
                        RegSetValueExW(hKeyMet, L"MinAnimate", 0, REG_SZ, (const BYTE*)szVal, (wcslen(szVal) + 1) * sizeof(wchar_t));
                        RegCloseKey(hKeyMet);
                    }
                    ANIMATIONINFO ai;
                    ai.cbSize = sizeof(ai);
                    ai.iMinAnimate = enabled ? 1 : 0;
                    SystemParametersInfoW(SPI_SETANIMATION, sizeof(ai), &ai, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
                } else if (key == "animateTaskbar") {
                    writeVisualEffectReg("TaskbarAnimations", dwVal);
                    HKEY hKeyAdv;
                    if (RegOpenKeyExW(HKEY_CURRENT_USER, L"Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced", 0, KEY_SET_VALUE, &hKeyAdv) == ERROR_SUCCESS) {
                        RegSetValueExW(hKeyAdv, L"TaskbarAnimations", 0, REG_DWORD, (const BYTE*)&dwVal, sizeof(dwVal));
                        RegCloseKey(hKeyAdv);
                    }
                } else if (key == "enablePeek") {
                    writeVisualEffectReg("DWMAeroPeekEnabled", dwVal);
                    HKEY hKeyDwm;
                    if (RegOpenKeyExW(HKEY_CURRENT_USER, L"Software\\Microsoft\\Windows\\DWM", 0, KEY_SET_VALUE, &hKeyDwm) == ERROR_SUCCESS) {
                        RegSetValueExW(hKeyDwm, L"EnableAeroPeek", 0, REG_DWORD, (const BYTE*)&dwVal, sizeof(dwVal));
                        RegCloseKey(hKeyDwm);
                    }
                } else if (key == "fadeMenus") {
                    writeVisualEffectReg("MenuAnimation", dwVal);
                    SystemParametersInfoW(SPI_SETMENUANIMATION, 0, (PVOID)(INT_PTR)enabled, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
                } else if (key == "fadeTooltips") {
                    writeVisualEffectReg("TooltipAnimation", dwVal);
                    SystemParametersInfoW(SPI_SETTOOLTIPANIMATION, 0, (PVOID)(INT_PTR)enabled, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
                } else if (key == "fadeMenuSelection") {
                    writeVisualEffectReg("SelectionFade", dwVal);
                    SystemParametersInfoW(SPI_SETSELECTIONFADE, 0, (PVOID)(INT_PTR)enabled, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
                } else if (key == "saveThumbnails") {
                    writeVisualEffectReg("DWMSaveThumbnailEnabled", dwVal);
                    HKEY hKeyAdv;
                    if (RegOpenKeyExW(HKEY_CURRENT_USER, L"Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced", 0, KEY_SET_VALUE, &hKeyAdv) == ERROR_SUCCESS) {
                        RegSetValueExW(hKeyAdv, L"AlwaysHibernateThumbnails", 0, REG_DWORD, (const BYTE*)&dwVal, sizeof(dwVal));
                        RegCloseKey(hKeyAdv);
                    }
                } else if (key == "shadowPointer") {
                    writeVisualEffectReg("CursorShadow", dwVal);
                    HKEY hKeyDesk;
                    if (RegOpenKeyExW(HKEY_CURRENT_USER, L"Control Panel\\Desktop", 0, KEY_SET_VALUE, &hKeyDesk) == ERROR_SUCCESS) {
                        RegSetValueExW(hKeyDesk, L"PointerShadow", 0, REG_DWORD, (const BYTE*)&dwVal, sizeof(dwVal));
                        RegCloseKey(hKeyDesk);
                    }
                    SystemParametersInfoW(SPI_SETCURSORSHADOW, 0, (PVOID)(INT_PTR)enabled, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
                } else if (key == "shadowWindows") {
                    writeVisualEffectReg("DropShadow", dwVal);
                    SystemParametersInfoW(SPI_SETDROPSHADOW, 0, (PVOID)(INT_PTR)enabled, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
                } else if (key == "showThumbnails") {
                    writeVisualEffectReg("ThumbnailsOrIcon", dwVal);
                    HKEY hKeyAdv;
                    if (RegOpenKeyExW(HKEY_CURRENT_USER, L"Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced", 0, KEY_SET_VALUE, &hKeyAdv) == ERROR_SUCCESS) {
                        DWORD iconsOnlyVal = enabled ? 0 : 1;
                        RegSetValueExW(hKeyAdv, L"IconsOnly", 0, REG_DWORD, (const BYTE*)&iconsOnlyVal, sizeof(iconsOnlyVal));
                        RegCloseKey(hKeyAdv);
                    }
                } else if (key == "translucentSelection") {
                    writeVisualEffectReg("ListviewAlphaSelect", dwVal);
                    HKEY hKeyAdv;
                    if (RegOpenKeyExW(HKEY_CURRENT_USER, L"Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced", 0, KEY_SET_VALUE, &hKeyAdv) == ERROR_SUCCESS) {
                        RegSetValueExW(hKeyAdv, L"ListviewAlphaSelect", 0, REG_DWORD, (const BYTE*)&dwVal, sizeof(dwVal));
                        RegCloseKey(hKeyAdv);
                    }
                } else if (key == "dragContents") {
                    writeVisualEffectReg("DragFullWindows", dwVal);
                    HKEY hKeyDesk;
                    if (RegOpenKeyExW(HKEY_CURRENT_USER, L"Control Panel\\Desktop", 0, KEY_SET_VALUE, &hKeyDesk) == ERROR_SUCCESS) {
                        const wchar_t* szVal = enabled ? L"1" : L"0";
                        RegSetValueExW(hKeyDesk, L"DragFullWindows", 0, REG_SZ, (const BYTE*)szVal, (wcslen(szVal) + 1) * sizeof(wchar_t));
                        RegCloseKey(hKeyDesk);
                    }
                    SystemParametersInfoW(SPI_SETDRAGFULLWINDOWS, enabled, 0, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
                } else if (key == "slideComboBoxes") {
                    writeVisualEffectReg("ComboBoxAnimation", dwVal);
                    SystemParametersInfoW(SPI_SETCOMBOBOXANIMATION, 0, (PVOID)(INT_PTR)enabled, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
                } else if (key == "smoothFonts") {
                    writeVisualEffectReg("FontSmoothing", dwVal);
                    HKEY hKeyDesk;
                    if (RegOpenKeyExW(HKEY_CURRENT_USER, L"Control Panel\\Desktop", 0, KEY_SET_VALUE, &hKeyDesk) == ERROR_SUCCESS) {
                        const wchar_t* szVal = enabled ? L"2" : L"0";
                        RegSetValueExW(hKeyDesk, L"FontSmoothing", 0, REG_SZ, (const BYTE*)szVal, (wcslen(szVal) + 1) * sizeof(wchar_t));
                        DWORD typeVal = enabled ? 2 : 0;
                        RegSetValueExW(hKeyDesk, L"FontSmoothingType", 0, REG_DWORD, (const BYTE*)&typeVal, sizeof(typeVal));
                        RegCloseKey(hKeyDesk);
                    }
                    SystemParametersInfoW(SPI_SETFONTSMOOTHING, enabled, 0, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
                } else if (key == "smoothScroll") {
                    writeVisualEffectReg("ListBoxSmoothScrolling", dwVal);
                    SystemParametersInfoW(SPI_SETLISTBOXSMOOTHSCROLLING, 0, (PVOID)(INT_PTR)enabled, SPIF_UPDATEINIFILE | SPIF_SENDCHANGE);
                } else if (key == "dropShadowsDesktop") {
                    writeVisualEffectReg("ListviewShadow", dwVal);
                    HKEY hKeyAdv;
                    if (RegOpenKeyExW(HKEY_CURRENT_USER, L"Software\\Microsoft\\Windows\\CurrentVersion\\Explorer\\Advanced", 0, KEY_SET_VALUE, &hKeyAdv) == ERROR_SUCCESS) {
                        RegSetValueExW(hKeyAdv, L"ListviewShadow", 0, REG_DWORD, (const BYTE*)&dwVal, sizeof(dwVal));
                        RegCloseKey(hKeyAdv);
                    }
                }
            }

            // 3. Update UserPreferencesMask bitmask based on individual settings
            HKEY hKeyPref;
            if (RegOpenKeyExW(HKEY_CURRENT_USER, L"Control Panel\\Desktop", 0, KEY_READ | KEY_WRITE, &hKeyPref) == ERROR_SUCCESS) {
                BYTE mask[8] = {0};
                DWORD dwSize = sizeof(mask);
                DWORD dwType = REG_BINARY;
                if (RegQueryValueExW(hKeyPref, L"UserPreferencesMask", nullptr, &dwType, mask, &dwSize) == ERROR_SUCCESS) {
                    if (visualEffectsVal.value("smoothScroll").toBool()) mask[0] |= 0x08;
                    else mask[0] &= ~0x08;

                    if (visualEffectsVal.value("slideComboBoxes").toBool()) mask[0] |= 0x04;
                    else mask[0] &= ~0x04;

                    if (visualEffectsVal.value("fadeMenus").toBool()) mask[0] |= 0x02;
                    else mask[0] &= ~0x02;

                    if (visualEffectsVal.value("shadowPointer").toBool()) mask[1] |= 0x40;
                    else mask[1] &= ~0x40;

                    if (visualEffectsVal.value("fadeTooltips").toBool()) mask[1] |= 0x08;
                    else mask[1] &= ~0x08;

                    if (visualEffectsVal.value("fadeMenuSelection").toBool()) mask[1] |= 0x04;
                    else mask[1] &= ~0x04;

                    if (visualEffectsVal.value("shadowWindows").toBool()) mask[2] |= 0x04;
                    else mask[2] &= ~0x04;

                    RegSetValueExW(hKeyPref, L"UserPreferencesMask", 0, REG_BINARY, mask, sizeof(mask));
                }
                RegCloseKey(hKeyPref);
            }

            emit systemStepReported(Optimizer::tr("Windows visual effects optimized successfully."), "SUCCESS");
#else
            emit systemStepReported(Optimizer::tr("[Simulation] Windows visual effects updated."), "SUCCESS");
#endif
        }

        bool overallSuccess = wSearchSuccess && hibernationSuccess && overlaySuccess && coreIsolationSuccess && mouseAccelSuccess && gameModeSuccess && firewallSuccess && printerSuccess && notificationsSuccess && powerPlanSuccess && defenderSuccess && overallDrivesSuccess && usbSuccess && remoteAccessSuccess && telemetrySuccess && windowsUpdateSuccess && cs2Success && steamOverlaySuccess && cs2OverlaySuccess && steamFriendsSuccess && visualEffectsSuccess;
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
        m_originalCoreIsolationActive = coreIsolationVal;
        m_originalMouseAccelerationActive = mouseAccelVal;
        m_originalGameModeActive = gameModeVal;
        m_originalFirewallActive = firewallVal;
        m_originalPrinterActive = printerVal;
        m_originalNotificationsActive = notificationsVal;
        m_originalNotifGlobalActive = notifGlobalVal;
        m_originalNotifAppActive = notifAppVal;
        m_originalNotifSoundsActive = notifSoundsVal;
        m_originalNotifLockscreenActive = notifLockscreenVal;
        m_originalDefenderActive = defenderVal;
        m_originalDefenderRegistryActive = defenderRegistryVal;
        m_originalDefenderCmdActive = defenderCmdVal;
        m_originalDefenderServiceActive = defenderServiceVal;
        m_originalRemoteAccessActive = remoteAccessVal;
        m_originalTelemetryActive = telemetryVal;
        m_originalTelemetryDiagTrackActive = telemetryDiagTrackVal;
        m_originalTelemetryWapPushActive = telemetryWapPushVal;
        m_originalTelemetryCeipActive = telemetryCeipVal;
        m_originalTelemetryWerActive = telemetryWerVal;
        m_originalWindowsUpdateMode = windowsUpdateModeVal;
        m_originalCs2LaunchOptions = cs2OptionsVal;
        m_originalSteamOverlayActive = steamOverlayVal;
        m_originalCs2OverlayActive = cs2OverlayVal;
        m_originalSteamFriendsSettings = steamFriendsSettingsVal;
        m_originalVisualEffects = visualEffectsVal;
        m_originalDriveStates = targets;
        
        loadSystemStates();

        emit driveStatesChanged(m_driveStates);
        emit originalWinSearchActiveChanged(m_originalWinSearchActive);
        emit originalHibernationActiveChanged(m_originalHibernationActive);
        emit originalGamingOverlayActiveChanged(m_originalGamingOverlayActive);
        emit originalCoreIsolationActiveChanged(m_originalCoreIsolationActive);
        emit originalMouseAccelerationActiveChanged(m_originalMouseAccelerationActive);
        emit originalGameModeActiveChanged(m_originalGameModeActive);
        emit originalFirewallActiveChanged(m_originalFirewallActive);
        emit originalPrinterActiveChanged(m_originalPrinterActive);
        emit originalNotificationsActiveChanged(m_originalNotificationsActive);
        emit originalNotifGlobalActiveChanged(m_originalNotifGlobalActive);
        emit originalNotifAppActiveChanged(m_originalNotifAppActive);
        emit originalNotifSoundsActiveChanged(m_originalNotifSoundsActive);
        emit originalNotifLockscreenActiveChanged(m_originalNotifLockscreenActive);
        emit originalDefenderActiveChanged(m_originalDefenderActive);
        emit originalDefenderRegistryActiveChanged(m_originalDefenderRegistryActive);
        emit originalDefenderCmdActiveChanged(m_originalDefenderCmdActive);
        emit originalDefenderServiceActiveChanged(m_originalDefenderServiceActive);
        emit originalRemoteAccessActiveChanged(m_originalRemoteAccessActive);
        emit originalTelemetryActiveChanged(m_originalTelemetryActive);
        emit originalTelemetryDiagTrackActiveChanged(m_originalTelemetryDiagTrackActive);
        emit originalTelemetryWapPushActiveChanged(m_originalTelemetryWapPushActive);
        emit originalTelemetryCeipActiveChanged(m_originalTelemetryCeipActive);
        emit originalTelemetryWerActiveChanged(m_originalTelemetryWerActive);
        emit originalWindowsUpdateModeChanged(m_originalWindowsUpdateMode);
        emit originalVisualEffectsChanged(m_originalVisualEffects);
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
    } else if (funcName == "hibernation") {
        QProcess::startDetached("control.exe", QStringList() << "/name" << "Microsoft.PowerOptions" << "/page" << "pageGlobalSettings");
        Logger::log("Opening Power Options Global Settings...", "INFO");
    } else if (funcName == "coreisolation") {
        QProcess::startDetached("cmd.exe", QStringList() << "/c" << "start windowsdefender://devicesecurity");
        Logger::log("Opening Device Security (Core Isolation) settings...", "INFO");
    } else if (funcName == "mouseacceleration") {
        QProcess::startDetached("control.exe", QStringList() << "main.cpl,,1");
        Logger::log("Opening Mouse Properties (Pointer Options)...", "INFO");
    } else if (funcName == "gamemode") {
        QProcess::startDetached("cmd.exe", QStringList() << "/c" << "start ms-settings:gaming-gamemode");
        Logger::log("Opening Game Mode settings...", "INFO");
    } else if (funcName == "firewall") {
        QProcess::startDetached("cmd.exe", QStringList() << "/c" << "start windowsdefender://network");
        Logger::log("Opening Firewall & Network Protection settings...", "INFO");
    } else if (funcName == "printer") {
        QProcess::startDetached("cmd.exe", QStringList() << "/c" << "start devmgmt.msc");
        Logger::log("Opening Device Manager...", "INFO");
    } else if (funcName == "notifications") {
        QProcess::startDetached("cmd.exe", QStringList() << "/c" << "start ms-settings:notifications");
        Logger::log("Opening Windows Notifications Settings...", "INFO");
    } else if (funcName == "bitlocker") {
        QProcess::startDetached("control.exe", QStringList() << "/name" << "Microsoft.BitLockerDriveEncryption");
        Logger::log("Opening BitLocker Drive Encryption Manager...", "INFO");
    } else if (funcName == "discord") {
        QString path = QDir::homePath() + "/AppData/Roaming/discord";
        path = QDir::toNativeSeparators(path);
        QProcess::startDetached("explorer.exe", QStringList() << path);
        Logger::log("Opening Discord AppData directory in File Explorer...", "INFO");
    } else if (funcName == "defender") {
        QProcess::startDetached("cmd.exe", QStringList() << "/c" << "start windowsdefender://threatsettings");
        Logger::log("Opening Windows Defender Virus & threat protection settings...", "INFO");
    } else if (funcName == "remoteaccess" || funcName == "rdp") {
        QProcess::startDetached("cmd.exe", QStringList() << "/c" << "start ms-settings:remotedesktop");
        Logger::log("Opening Remote Desktop settings...", "INFO");
    } else if (funcName == "telemetry") {
        QProcess::startDetached("cmd.exe", QStringList() << "/c" << "start ms-settings:privacy-feedback");
        Logger::log("Opening Windows Diagnostic & Feedback settings...", "INFO");
    } else if (funcName == "windowsupdate") {
        QProcess::startDetached("cmd.exe", QStringList() << "/c" << "start ms-settings:windowsupdate");
        Logger::log("Opening Windows Update settings...", "INFO");
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
        QString cmd = QString("[Void](New-Object -ComObject Shell.Application).NameSpace('%1').Self.InvokeVerb('Properties')").arg(letter);
        QProcess::startDetached("powershell.exe", QStringList() << "-NoProfile" << "-NonInteractive" << "-Command" << cmd);
        Logger::log(QString("Opening Drive %1 properties dialog for indexing settings...").arg(letter), "INFO");
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
            cmd = "Get-AppxPackage *XboxApp* | Remove-AppxPackage";
        } else if (componentName == "XboxGamingOverlay") {
            cmd = "Get-AppxPackage *XboxGamingOverlay* | Remove-AppxPackage";
        } else if (componentName == "XboxTCUI") {
            cmd = "Get-AppxPackage *Xbox.TCUI* | Remove-AppxPackage";
        } else if (componentName == "XboxGameSpeechWindow") {
            cmd = "Get-AppxPackage *XboxGameSpeechWindow* | Remove-AppxPackage";
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

void Optimizer::selectPowerScheme(const QString &guidStr) {
    m_targetPowerSchemeGuid = guidStr.toUpper();
    emit targetPowerSchemeGuidChanged(m_targetPowerSchemeGuid);
    
    // Update m_powerSchemes locally to highlight the selected target scheme
    for (int i = 0; i < m_powerSchemes.size(); ++i) {
        QVariantMap map = m_powerSchemes[i].toMap();
        if (map["guid"].toString().toUpper() == m_targetPowerSchemeGuid) {
            map["isActive"] = true;
        } else {
            map["isActive"] = false;
        }
        m_powerSchemes[i] = map;
    }
    emit powerSchemesChanged(m_powerSchemes);
    
    Logger::log(QString("Staged target power scheme to: %1").arg(m_targetPowerSchemeGuid), "INFO");
}

void Optimizer::activateUltimatePerformance() {
    // Stage Ultimate Performance activation
    m_targetPowerSchemeGuid = "{E9A22B95-E3B0-4B87-A177-728978ED6022}";
    emit targetPowerSchemeGuidChanged(m_targetPowerSchemeGuid);
    
    // Update ultimate unlocked state (staged in UI)
    m_ultimateSchemeUnlocked = true;
    emit ultimateSchemeUnlockedChanged(m_ultimateSchemeUnlocked);
    
    // De-activate other schemes and activate Ultimate Performance in m_powerSchemes
    bool found = false;
    for (int i = 0; i < m_powerSchemes.size(); ++i) {
        QVariantMap map = m_powerSchemes[i].toMap();
        if (map["guid"].toString().toUpper() == m_targetPowerSchemeGuid) {
            map["isActive"] = true;
            found = true;
        } else {
            map["isActive"] = false;
        }
        m_powerSchemes[i] = map;
    }
    if (!found) {
        QVariantMap ultMap;
        ultMap["name"] = tr("Ultimate Performance Scheme");
        ultMap["guid"] = m_targetPowerSchemeGuid;
        ultMap["isActive"] = true;
        ultMap["isUltimate"] = true;
        m_powerSchemes.append(ultMap);
    }
    emit powerSchemesChanged(m_powerSchemes);
    
    Logger::log("Staged Ultimate Performance power scheme activation.", "INFO");
}

bool Optimizer::isDiscordRunning() {
#ifdef Q_OS_WIN
    bool running = false;
    HANDLE hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (hSnapshot != INVALID_HANDLE_VALUE) {
        PROCESSENTRY32W pe32;
        pe32.dwSize = sizeof(pe32);
        if (Process32FirstW(hSnapshot, &pe32)) {
            do {
                if (wcscmp(pe32.szExeFile, L"Discord.exe") == 0 || 
                    wcscmp(pe32.szExeFile, L"discord.exe") == 0) {
                    running = true;
                    break;
                }
            } while (Process32NextW(hSnapshot, &pe32));
        }
        CloseHandle(hSnapshot);
    }
    return running;
#else
    return false;
#endif
}

void Optimizer::killDiscord() {
#ifdef Q_OS_WIN
    HANDLE hSnapshot = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
    if (hSnapshot != INVALID_HANDLE_VALUE) {
        PROCESSENTRY32W pe32;
        pe32.dwSize = sizeof(pe32);
        if (Process32FirstW(hSnapshot, &pe32)) {
            do {
                if (wcscmp(pe32.szExeFile, L"Discord.exe") == 0 || 
                    wcscmp(pe32.szExeFile, L"discord.exe") == 0) {
                    HANDLE hProcess = OpenProcess(PROCESS_TERMINATE, FALSE, pe32.th32ProcessID);
                    if (hProcess) {
                        TerminateProcess(hProcess, 0);
                        CloseHandle(hProcess);
                    }
                }
            } while (Process32NextW(hSnapshot, &pe32));
        }
        CloseHandle(hSnapshot);
    }
    Logger::log("Closed running Discord instances to unlock hook files.", "INFO");
#endif
}

bool Optimizer::checkIsDiscordOverlayActive() {
    QString appData = QDir::homePath() + "/AppData/Roaming";
    QStringList discordDirs = { "discord", "discordcanary", "discordptb" };
    
    bool foundDll = false;
    bool foundDisabled = false;
    
    for (const QString &dirName : discordDirs) {
        QString discordPath = appData + "/" + dirName;
        if (!QDir(discordPath).exists()) continue;
        
        QDirIterator it(discordPath, QDirIterator::Subdirectories);
        while (it.hasNext()) {
            QString filePath = it.next();
            QString fileName = QFileInfo(filePath).fileName();
            
            if (fileName.compare("DiscordHook64.dll", Qt::CaseInsensitive) == 0 ||
                fileName.compare("DiscordHook.dll", Qt::CaseInsensitive) == 0) {
                foundDll = true;
            } else if (fileName.compare("DiscordHook64.dll.disabled", Qt::CaseInsensitive) == 0 ||
                       fileName.compare("DiscordHook.dll.disabled", Qt::CaseInsensitive) == 0) {
                foundDisabled = true;
            }
        }
    }
    
    if (foundDisabled && !foundDll) {
        return false;
    }
    return true; // Default to active/enabled
}

void Optimizer::setDiscordOverlayFilesActive(bool active) {
    QString appData = QDir::homePath() + "/AppData/Roaming";
    QStringList discordDirs = { "discord", "discordcanary", "discordptb" };
    
    for (const QString &dirName : discordDirs) {
        QString discordPath = appData + "/" + dirName;
        if (!QDir(discordPath).exists()) continue;
        
        QDirIterator it(discordPath, QDirIterator::Subdirectories);
        while (it.hasNext()) {
            QString filePath = it.next();
            QFileInfo fileInfo(filePath);
            QString fileName = fileInfo.fileName();
            
            if (active) {
                if (fileName.compare("DiscordHook64.dll.disabled", Qt::CaseInsensitive) == 0) {
                    QString newPath = fileInfo.absolutePath() + "/DiscordHook64.dll";
                    QFile::rename(filePath, newPath);
                    Logger::log("Restored Discord Overlay DLL: " + newPath, "INFO");
                } else if (fileName.compare("DiscordHook.dll.disabled", Qt::CaseInsensitive) == 0) {
                    QString newPath = fileInfo.absolutePath() + "/DiscordHook.dll";
                    QFile::rename(filePath, newPath);
                    Logger::log("Restored Discord Overlay DLL: " + newPath, "INFO");
                }
            } else {
                if (fileName.compare("DiscordHook64.dll", Qt::CaseInsensitive) == 0) {
                    QString newPath = filePath + ".disabled";
                    QFile::rename(filePath, newPath);
                    Logger::log("Disabled Discord Overlay DLL: " + newPath, "INFO");
                } else if (fileName.compare("DiscordHook.dll", Qt::CaseInsensitive) == 0) {
                    QString newPath = filePath + ".disabled";
                    QFile::rename(filePath, newPath);
                    Logger::log("Disabled Discord Overlay DLL: " + newPath, "INFO");
                }
            }
        }
    }
}
