import QtQuick 2.0

Item {
    id: button

//    property bool enabled: true

    signal clickedUp
    signal clickedDown

    property int  value: -1

    property bool pressedUp: false
    property bool pressedDown: false

    Image {
        anchors.fill: parent
        source: "ButtonActionUp.svg"
        sourceSize.width: button.width
        sourceSize.height: button.height
        visible: !pressedDown && !pressedUp
    }

    Image {
        id: image1
        anchors.fill: parent
        anchors.centerIn: parent
        sourceSize.width: button.width
        sourceSize.height: button.height
        source: "ButtonActionDown2.svg"
        visible: pressedUp
    }

    Image {
        id: image2
        anchors.fill: parent
        anchors.centerIn: parent
        sourceSize.width: button.width
        sourceSize.height: button.height
        source: "ButtonActionDown1.svg"
        visible: pressedDown
    }


    MouseArea {
        enabled: button.enabled
//        anchors.bottomMargin: button.height * 0.03
        anchors.leftMargin: button.width * 0.4
//        anchors.rightMargin: 0
        anchors.topMargin: button.height * 0.55

        anchors.fill: parent

         onPressed: {
             button.pressedUp=true;
         }
         onReleased: {
             button.pressedUp=false;
         }

         onClicked: {
             button.clickedUp()
             button.pressedUp=false;
         }
    }

    MouseArea {
        enabled: button.enabled
        anchors.bottomMargin: button.height * 0.55
        anchors.leftMargin: button.width * 0.4
//        anchors.rightMargin: button.width * 0.05
//        anchors.topMargin: button.height * 0.03

        anchors.fill: parent

         onPressed: {
             button.pressedDown=true;
         }
         onReleased: {
             button.pressedDown=false;
         }

         onClicked: {
             button.clickedDown()
             button.pressedDown=false;
         }
    }

    Text {
        id: valueText1
        text: value.toString()
        anchors.verticalCenterOffset: -0.026 * button.height
        anchors.horizontalCenterOffset: -0.070 * button.width
        font { family: fontCelestiaRedux.name; pixelSize: button.width*0.3 }
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
    }
}
