#include <QtGui/QGuiApplication>
#include "qtquick2applicationviewer.h"

int main(int argc, char *argv[])
{
    QGuiApplication app(argc, argv);

    app.setOrganizationName("Arpegius");
    app.setOrganizationDomain("arpegius.pl");
    app.setApplicationName("MLPCCGPointScoreboard");

    QtQuick2ApplicationViewer viewer;
    viewer.setMainQmlFile(QStringLiteral("qml/MLPCCGPointScoreboard/main.qml"));
    viewer.showExpanded();

    return app.exec();
}
