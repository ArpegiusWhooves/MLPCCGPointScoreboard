import QtQuick 2.0
//import Ubuntu.Components 1.1
import QtQuick.Controls 1.1

Item {
    id: mainLog

    readonly property Item paper: paper

    Image {
        x: 0
        y: 50
        height: 100
        anchors.right: parent.right
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.topMargin: 0
        source: "scrollTop.svg"
    }

    Image {
        x: -9
        y: 40
        height: 100
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        source: "scrollTop.svg"
        anchors.right: parent.right
    }

    Image {
        id:paper
        anchors.rightMargin: mainLog.width*78/700.0
        anchors.leftMargin: mainLog.width*78/700.0
        anchors.bottomMargin: 59
        anchors.topMargin: 61
        anchors.fill:  parent
        source: "./scrollMiddle.svg"
    }
}
