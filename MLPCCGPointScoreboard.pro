# Add more folders to ship with the application, here
folder_01.source = qml/MLPCCGPointScoreboard
folder_01.target = qml
DEPLOYMENTFOLDERS = folder_01

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =



# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp

# Installation path
# target.path =

# Please do not modify the following two lines. Required for deployment.
include(qtquick2applicationviewer/qtquick2applicationviewer.pri)
qtcAddDeployment()

ANDROID_PACKAGE_SOURCE_DIR = $$PWD/android

OTHER_FILES += \
    android/AndroidManifest.xml \
    qml/MLPCCGPointScoreboard/arrow_up_green.svg \
    qml/MLPCCGPointScoreboard/GameState.js \
    qml/MLPCCGPointScoreboard/ButtonPass.qml \
    qml/MLPCCGPointScoreboard/ButtonScore.qml \
    qml/MLPCCGPointScoreboard/ButtonAction.qml

DISTFILES += \
    qml/MLPCCGPointScoreboard/DailyBackgorund.qml
