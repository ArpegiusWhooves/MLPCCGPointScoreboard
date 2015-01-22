import QtQuick 2.0

Item {
    id: button

    signal clicked

//    property bool enabled: true

    property int  value: -1

    property bool pressed: false

    Image {
        anchors.fill: parent
        source: "ButtonScoreUp.svg"
        sourceSize.width: button.width
        sourceSize.height: button.height
        visible: !pressed
    }

    Image {
        id: image1
        anchors.fill: parent
        anchors.centerIn: parent
        sourceSize.width: button.width
        sourceSize.height: button.height
        source: "ButtonScoreDown.svg"
        visible: pressed
    }


    MouseArea {
        enabled: button.enabled
//        anchors.bottomMargin: button.height * 0.05
        anchors.leftMargin: 0
        anchors.rightMargin: button.width * 0.20
        anchors.topMargin: button.height * 0.36

        anchors.fill: parent

         onPressed: {
             button.pressed=true;
         }
         onReleased: {
             button.pressed=false;
         }

         onClicked: {
             button.clicked()
             button.pressed=false;
         }
    }

    Text {
        id: valueText1
        text: value.toString()
        font { family: fontCelestiaRedux.name; pixelSize: button.width*0.3 }
        anchors.verticalCenterOffset: -0.106 * button.height
        anchors.horizontalCenterOffset: -0.032 * button.width
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }
}
