#pragma once
#include <QString>
#include <QVariantList>
#include <functional>

class PowerUsbManager {
public:
    static QVariantList loadPowerSchemes(bool &isUltimateUnlocked, QString &activeSchemeGuidStr);
    static QVariantList loadUsbDevices(bool &anyUsbPowerSaving);
    static void deleteUltimatePerformance(const QVariantList &powerSchemes);
    static bool setUsbPowerSavingRegistry(const QString &subkeyPath, bool active);
    
    static bool applyPowerScheme(const QString &targetPowerSchemeGuid, 
                                 const QString &activePowerSchemeGuid, 
                                 bool deleteUltimateStaged, 
                                 QString &finalActiveSchemeGuid,
                                 std::function<void(const QString&, const QString&)> reportStep);
                                 
    static bool applyUsbPowerSaving(const QVariantList &usbDevices, 
                                    const QVariantList &originalUsbDevices, 
                                    std::function<void(const QString&, const QString&)> reportStep);
};
