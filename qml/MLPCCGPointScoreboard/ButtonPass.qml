import QtQuick 2.0

Item {
    id: button

    signal clicked

    property bool pressed: false

    Image {
        anchors.fill: parent
        source: "ButtonPassUp.svg"
        sourceSize.width: button.width
        sourceSize.height: button.height
        visible: !pressed
    }

    Image {
        anchors.fill: parent
        sourceSize.width: button.width
        sourceSize.height: button.height
        source: "ButtonPassDown.svg"
        visible: pressed
    }

    MouseArea {
        anchors.rightMargin: button.width / 3
        anchors.leftMargin: button.width / 3
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

}
