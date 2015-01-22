import QtQuick 2.0
import QtGraphicalEffects 1.0

Item {
    id: dailybackground

    property bool crop: dailybackground.width*2 > dailybackground.height * 3

    property bool nightEnabled: true

    property alias rotation: gradientShift.rotation

    property real progtresTop: 0.0

    onProgtresTopChanged: {
        b1.enabled=!crop;
        b3.enabled=!crop;
    }

    property real progtresBottom: 0.0

    onProgtresBottomChanged: {
        b2.enabled=!crop;
        b4.enabled=!crop;
    }

    onWidthChanged:
    {
        b1.enabled=false;
        b2.enabled=false;
        b3.enabled=false;
        b4.enabled=false;
    }

    Item {
        anchors.fill: parent
        id: day
        clip: true

        Image {
            id:dayTop
            height: parent.height/2
            anchors.bottom: parent.verticalCenter
            x:dailybackground.crop?0:(-width+ parent.width)*(1-dailybackground.progtresTop)
            width: height*3
            sourceSize: Qt.size(parent.height/2*3,height)
            rotation: 180
            source: "./day.svg"

            Behavior on x {
                id:b1
                SmoothedAnimation {
                    id:a1
                    duration: 3000
                }
            }
        }
        Image {
            id:dayBottom
            x:dailybackground.crop?0:(-width+ parent.width)*(dailybackground.progtresBottom)
            height: parent.height/2
            anchors.top: parent.verticalCenter
            width: height*3
            sourceSize: Qt.size(parent.height/2*3,height)
            source: "./day.svg"

            Behavior on x {
                id:b2
                SmoothedAnimation {
                    id:a2
                    duration: 3000
                }
            }
        }
    }

    Item {
        id:night
        clip: true
        anchors.fill: parent
        visible: false
        Image {
            id:nightTop
            height: parent.height/2
            anchors.bottom: parent.verticalCenter
            x:dailybackground.crop?0:(-width+ parent.width)*(1-dailybackground.progtresTop)
            width: height*3
            sourceSize: Qt.size(parent.height/2*3,parent.height/2)
            rotation: 180
            source: "./night.svg"

            Behavior on x {
                id:b3
                SmoothedAnimation {
                    id:a3
                    duration: 3000
                }
            }
        }

        Image {
            id:nightBottom
            x:dailybackground.crop?0:(-width+ parent.width)*(dailybackground.progtresBottom)
            height: parent.height/2
            anchors.top: parent.verticalCenter
            width: height*3
            sourceSize: Qt.size(parent.height/2*3,parent.height/2)
            source: "./night.svg"

            Behavior on x {
                id:b4
                SmoothedAnimation {
                    id:a4
                    duration: 3000
                }
            }
        }
    }

    Image {

        id: maskShift
        anchors.fill: parent
        visible: false

        Rectangle {
            id: gradientShift
            anchors.centerIn: parent
            width: Math.max(parent.width,parent.height)*1.4
            height: Math.max(parent.width,parent.height)*1.4
            gradient: Gradient {
                GradientStop {
                    position: 0.45;
                    color: "black";
                }
                GradientStop {
                    position: 0.55;
                    color: "transparent";
                }
            }
        }

    }

    OpacityMask {
        id: nightMasked
        visible: dailybackground.nightEnabled
        cached: false
        anchors.fill:  parent
        source: night
        maskSource: maskShift
    }
    states: [
        State {
            name: "Crop"
            when: dailybackground.crop

            PropertyChanges {
                target: dayTop
                width: dailybackground.width
                height: dailybackground.width/3
            }
            PropertyChanges {
                target: dayBottom
                width: dailybackground.width
                height: dailybackground.width/3
            }
            PropertyChanges {
                target: nightTop
                width: dailybackground.width
                height: dailybackground.width/3
            }
            PropertyChanges {
                target: nightBottom
                width: dailybackground.width
                height: dailybackground.width/3
            }
        }
    ]
    
}
