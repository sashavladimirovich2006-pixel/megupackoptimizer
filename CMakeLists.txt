cmake_minimum_required(VERSION 3.16)

project(megu_pack_optimizer LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)

# Find Qt6 Modules
find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick)

qt_standard_project_setup()

# Source files for C++ Backend
set(SOURCES
    src/main.cpp
    src/logger.h
    src/logger.cpp
    src/settings.h
    src/settings.cpp
    src/optimizer.h
    src/optimizer.cpp
    src/app.manifest
    src/resources.rc
)

# Executable target definition
qt_add_executable(megu_pack_optimizer ${SOURCES})

# Register Theme.qml as a Singleton Type in QML
set_source_files_properties(src/qml/Theme.qml PROPERTIES QT_QML_SINGLETON_TYPE TRUE)

# Configure the QML Module
qt_add_qml_module(megu_pack_optimizer
    URI MeguPackOptimizer
    VERSION 1.0
    QML_FILES
        src/qml/main.qml
        src/qml/Theme.qml
        src/qml/components/AcrylicPanel.qml
        src/qml/components/MeguButton.qml
        src/qml/components/MeguSwitch.qml
        src/qml/components/MeguProgressBar.qml
        src/qml/components/MeguScrollBar.qml
        src/qml/components/LogViewer.qml
        src/qml/components/SpecCard.qml
        src/qml/components/ShowPathButton.qml
        src/qml/views/DashboardView.qml
        src/qml/views/SettingsView.qml
        src/qml/views/OptimizationView.qml
        src/qml/views/SteamSettingsDrawer.qml
        src/qml/views/IndexingDrawer.qml
        src/qml/views/XboxDrawer.qml
        src/qml/views/MpoDrawer.qml
        src/qml/views/NotificationsDrawer.qml
        src/qml/views/PowerDrawer.qml
        src/qml/views/DefenderDrawer.qml
        src/qml/views/UsbDrawer.qml
        src/qml/views/TelemetryDrawer.qml
        src/qml/views/WindowsUpdateDrawer.qml
        src/qml/views/VisualEffectsDrawer.qml
        src/qml/views/MoreRightsDrawer.qml
        src/qml/views/ExplorerDrawer.qml
    RESOURCES
        src/resources/settings.svg
        src/resources/steam.svg
        src/resources/development.svg
        src/resources/folder.svg
        src/resources/play.svg
        src/resources/bolt.svg
        src/resources/info.svg
        src/resources/warning.svg
        src/resources/check.svg
        src/resources/close.svg
        src/resources/terminal.svg
        src/resources/monitor.svg
        src/resources/cpu.svg
        src/resources/cores.svg
        src/resources/ram.svg
        src/resources/gpu.svg
        src/resources/motherboard.svg
        src/resources/storage.svg
        src/resources/arrow.svg
        src/resources/eye.svg
        src/resources/help.svg
        src/resources/megu_logo_transparent.png
        src/resources/cs2_icon.svg
        src/resources/ads.svg
        src/resources/privacy.svg
        src/resources/location.svg
        src/resources/telemetry.svg
        src/resources/camera.svg
        src/resources/microphone.svg
        translations/megu_pack_optimizer_uk.qm
)

# Link Qt6 Libraries
target_link_libraries(megu_pack_optimizer PRIVATE
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
)

# Windows Specific: Hide terminal window in production (Release mode)
# In Debug mode, keep it open for debugging output.
if(CMAKE_BUILD_TYPE STREQUAL "Release")
    set_target_properties(megu_pack_optimizer PROPERTIES
        WIN32_EXECUTABLE ON
    )
else()
    set_target_properties(megu_pack_optimizer PROPERTIES
        WIN32_EXECUTABLE OFF
    )
endif()

# Require Administrator Privileges on Windows (like BoosterX)
if(WIN32 AND MSVC)
    target_link_options(megu_pack_optimizer PRIVATE
        "/MANIFESTUAC:NO"
    )
endif()

if(MSVC)
    target_compile_options(megu_pack_optimizer PRIVATE "/bigobj")
endif()
