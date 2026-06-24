#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QIcon>
#include <QTranslator>
#include <iostream>
#include "logger.h"
#include "settings.h"
#include "optimizer.h"

#ifdef Q_OS_WIN
#include <QAbstractNativeEventFilter>
#include <QQuickWindow>
#include <windows.h>
#include <windowsx.h>

class WinNativeEventFilter : public QAbstractNativeEventFilter {
public:
    WinNativeEventFilter(QQuickWindow* window) : m_window(window) {
        if (m_window) {
            HWND hwnd = (HWND)m_window->winId();
            
            LONG_PTR style = GetWindowLongPtr(hwnd, GWL_STYLE);
            style |= WS_CAPTION | WS_SYSMENU | WS_THICKFRAME | WS_MAXIMIZEBOX | WS_MINIMIZEBOX;
            SetWindowLongPtr(hwnd, GWL_STYLE, style);
            
            SetWindowPos(hwnd, NULL, 0, 0, 0, 0, 
                         SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_NOACTIVATE | SWP_FRAMECHANGED);
        }
    }

    bool nativeEventFilter(const QByteArray &eventType, void *message, qintptr *result) override {
        if (eventType == "windows_generic_MSG") {
            MSG* msg = static_cast<MSG*>(message);
            if (m_window && msg->hwnd == (HWND)m_window->winId()) {
                switch (msg->message) {
                    case WM_GETMINMAXINFO: {
                        MINMAXINFO* mmi = reinterpret_cast<MINMAXINFO*>(msg->lParam);
                        HMONITOR hMonitor = MonitorFromWindow(msg->hwnd, MONITOR_DEFAULTTONEAREST);
                        MONITORINFO mi = { 0 };
                        mi.cbSize = sizeof(mi);
                        if (GetMonitorInfo(hMonitor, &mi)) {
                            mmi->ptMaxPosition.x = mi.rcWork.left - mi.rcMonitor.left;
                            mmi->ptMaxPosition.y = mi.rcWork.top - mi.rcMonitor.top;
                            mmi->ptMaxSize.x = mi.rcWork.right - mi.rcWork.left;
                            mmi->ptMaxSize.y = mi.rcWork.bottom - mi.rcWork.top;
                            mmi->ptMaxTrackSize.x = mmi->ptMaxSize.x;
                            mmi->ptMaxTrackSize.y = mmi->ptMaxSize.y;
                        }
                        *result = 0;
                        return true;
                    }
                    case WM_NCCALCSIZE: {
                        *result = 0;
                        return true;
                    }
                    case WM_NCHITTEST: {
                        int x = GET_X_LPARAM(msg->lParam);
                        int y = GET_Y_LPARAM(msg->lParam);
                        
                        POINT pt = { x, y };
                        ScreenToClient(msg->hwnd, &pt);
                        
                        int border_width = GetSystemMetrics(SM_CXSIZEFRAME) + GetSystemMetrics(SM_CXPADDEDBORDER);
                        int width = m_window->width();
                        int height = m_window->height();

                        if (IsZoomed(msg->hwnd)) {
                            break;
                        }
                        
                        bool left = pt.x < border_width;
                        bool right = pt.x > width - border_width;
                        bool top = pt.y < border_width;
                        bool bottom = pt.y > height - border_width;
                        
                        if (top && left) { *result = HTTOPLEFT; return true; }
                        if (top && right) { *result = HTTOPRIGHT; return true; }
                        if (bottom && left) { *result = HTBOTTOMLEFT; return true; }
                        if (bottom && right) { *result = HTBOTTOMRIGHT; return true; }
                        if (left) { *result = HTLEFT; return true; }
                        if (right) { *result = HTRIGHT; return true; }
                        if (top) { *result = HTTOP; return true; }
                        if (bottom) { *result = HTBOTTOM; return true; }
                        break;
                    }
                }
            }
        }
        return false;
    }

private:
    QQuickWindow* m_window;
};
#endif


int main(int argc, char* argv[]) {
    // Instantiate QGuiApplication first so QCoreApplication properties (like applicationDirPath) are available
    QGuiApplication app(argc, argv);
    app.setApplicationName("Megu Pack Optimizer");
    app.setApplicationVersion("1.0.0");
    app.setOrganizationName("MeguStudio");
    app.setWindowIcon(QIcon(":/MeguPackOptimizer/src/resources/megu_logo_transparent.png"));

    // Instantiate logger next
    Logger loggerInstance;
    
    // Install custom log message handler to capture all QML and Qt core logs
    qInstallMessageHandler(Logger::qtMessageHandler);

    Logger::log("Initializing backend engines...", "INFO");

    // Instantiate settings and optimizer
    Settings settingsInstance;
    Optimizer optimizerInstance;

    QQmlApplicationEngine engine;
    engine.addImportPath("qrc:/");

    // Translator setup
    QTranslator* translator = new QTranslator(&app);
    auto loadLanguage = [&app, &engine, translator](const QString &lang) {
        app.removeTranslator(translator);
        if (lang == "uk") {
            bool loaded = translator->load("megu_pack_optimizer_uk", ":/MeguPackOptimizer/translations");
            if (!loaded) {
                loaded = translator->load(":/MeguPackOptimizer/translations/megu_pack_optimizer_uk.qm");
            }
            if (loaded) {
                app.installTranslator(translator);
                Logger::log("Ukrainian translation loaded successfully", "INFO");
            } else {
                Logger::log("Failed to load Ukrainian translation from resource path", "WARNING");
            }
        } else {
            Logger::log("Default language (English) selected", "INFO");
        }
        engine.retranslate();
    };

    // Load initial language
    loadLanguage(settingsInstance.language());

    // Connect language change signal to reload language dynamically
    QObject::connect(&settingsInstance, &Settings::languageChanged, &app, loadLanguage);

    // Register backend contexts to QML for reactive bindings
    engine.rootContext()->setContextProperty("loggerBackend", &loggerInstance);
    engine.rootContext()->setContextProperty("settingsBackend", &settingsInstance);
    engine.rootContext()->setContextProperty("optimizerBackend", &optimizerInstance);

    // QML Module Entry point path
    const QUrl url(QStringLiteral("qrc:/MeguPackOptimizer/src/qml/main.qml"));
    
    QObject::connect(&engine, &QQmlApplicationEngine::objectCreated,
                     &app, [url](QObject *obj, const QUrl &objUrl) {
        if (!obj && url == objUrl) {
            Logger::log("QML Engine failed to create root ApplicationWindow!", "FATAL");
            QCoreApplication::exit(-1);
        }
    }, Qt::QueuedConnection);

    Logger::log("Loading QML engine...", "INFO");
    engine.load(url);

#ifdef Q_OS_WIN
    const QList<QObject*> rootObjects = engine.rootObjects();
    if (!rootObjects.isEmpty()) {
        QQuickWindow* qmlWindow = qobject_cast<QQuickWindow*>(rootObjects.first());
        if (qmlWindow) {
            WinNativeEventFilter* filter = new WinNativeEventFilter(qmlWindow);
            app.installNativeEventFilter(filter);
            Logger::log("Native Win32 event filter for Aero Snap installed.", "INFO");
        }
    }
#endif

    Logger::log("Application event loop started.", "INFO");
    return app.exec();
}
