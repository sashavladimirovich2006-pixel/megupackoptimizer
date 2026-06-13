#pragma once
#include <QString>
#include <QObject>
#include <functional>

class SystemInfoProvider {
public:
    static QString getOsName();
    static QString getCpuName();
    static QString getLogicalCores();
    static QString getRamSize();
    static QString getGpuName();
    static QString getMotherboard();
    static QString getMotherboardSubValue();
    static QString getStorage();
    static QString getDisplay();
    static QString getSecureBoot();
    static QString getHagsStatus();
    static QString getHvciStatus();
    static QString getTpmStatus();
    static QString getRebarStatus();
    static double getCpuLoad(void* prevIdle, void* prevKernel, void* prevUser);
    static double getRamLoad();
    static void queryGpuTempAsync(QObject *parent, std::function<void(const QString &)> callback);
};
