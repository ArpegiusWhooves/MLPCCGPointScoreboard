import QtQuick 2.0
import QtQuick.Controls 1.1

Rectangle {
    id: rectangle1
    width: 500
    height: 800

    property int turn: 1
    property int firstplayer: 0
    property int player: 0

    property int apperturn: appofscore()

    function appofscore() {
        var max= Math.max( item1.score,item2.score );
        if(max < 2) return 2;
        if(max < 6) return 3;
        if(max < 11) return 4;
        return 5;
    }

    PlayerBoard {
        id: item1
        y: 834
        name: "Player 1"

        haveTurn: rectangle1.player==1
        onHaveTurnChanged: {
            if(haveTurn) {
                startTurn(rectangle1.apperturn,rectangle1.turn)
            }
        }

        readOnlyName: rectangle1.player!=0

        onLeave: {
            rectangle1.player=0;
            rectangle1.state= "player2win";
            wintext2.text= item2.name + qsTr(" wins!");
        }

        onPass: {
             rectangle1.player=2;
            if(rectangle1.firstplayer == 2) {
                rectangle1.turn += 1;
            }
        }

        anchors.left: parent.left
        anchors.leftMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0

        onScoreChanged: {
            if(score >= 15){
                rectangle1.player=0;
                rectangle1.state= "player1win";
                wintext2.text= item1.name + qsTr(" wins!");
            }
        }
    }

    PlayerBoard {
        id: item2
        name: "Player 2"

        haveTurn: rectangle1.player==2
        onHaveTurnChanged: {
            if(haveTurn) {
                startTurn(rectangle1.apperturn,rectangle1.turn)
            }
        }

        onLeave: {
            rectangle1.player=0;
            rectangle1.state= "player1win";
            wintext2.text= item1.name + qsTr(" wins!");
        }

        onPass: {
             rectangle1.player=1;
             if(rectangle1.firstplayer == 1) {
                 rectangle1.turn += 1;
             }
        }

        readOnlyName: rectangle1.player!=0

        anchors.top: parent.top
        anchors.topMargin: 0
        anchors.right: parent.right
        anchors.rightMargin: 0
        anchors.left: parent.left
        anchors.leftMargin: 0
        rotation: 180

        onScoreChanged: {
            if(score >= 15){
                rectangle1.player=0;
                rectangle1.state= "player2win";
                wintext2.text= item2.name + qsTr(" wins!");
            }
        }
    }

    Button {
        id: button2
        text: qsTr("  Start as First Player  ")
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: 0
        anchors.bottom: column1.top
        anchors.bottomMargin: 10
        rotation: 180
        enabled:false
        onClicked: { rectangle1.firstplayer=2; item1.clear();item2.clear(); rectangle1.turn=1; rectangle1.player=2; }

    }

    Button {
        id: button1
        text: qsTr("  Start as First Player  ")
        anchors.horizontalCenter: parent.horizontalCenter
        opacity: 0
        anchors.top: column1.bottom
        anchors.topMargin: 10
        enabled:false
        onClicked: { item1.clear();item2.clear(); rectangle1.turn=1; rectangle1.player=1;rectangle1.firstplayer=2; }
    }

    Image {
        id: image1
        x: -207
        y: 511
        width: rectangle1.width/5
        height: rectangle1.width/4
        anchors.verticalCenterOffset: 1
        sourceSize.height: 300
        sourceSize.width: 200
        anchors.verticalCenter: parent.verticalCenter
        source: "./arrow_up_green.svg"

    }

    Column{
        id: column1

        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        Text {
            id: wintext2
            font.pointSize: 40
            font.family: "Tahoma"
            font.bold: true
            rotation: 180
            opacity: 0.0
        }
        Text {
            id: wintext1
            text: wintext2.text
            font.pointSize: 40
            font.family: "Tahoma"
            font.bold: true
            opacity: 0.0
        }

    }

    Button {
        id: button3
        x: 602
        y: 366
        text: qsTr("Save to pastebin")
        enabled: false
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter
        opacity: 0
        onClicked: {
            var req= new XMLHttpRequest();
            req.onreadystatechange = function() {
                                if (req.readyState == XMLHttpRequest.DONE) {
                                    button3.text = req.responseText;
                                    Qt.openUrlExternally(req.responseText);
                                }
                            }
            var text= "";
            var h1=item1.getHistory();
            var h2=item2.getHistory();
            var o,name;
            for( var i=0,j=0; ; ){
                if( i>=h1.length ) {
                    if(j>=h2.length) break;
                    o=h2[j];
                    name=item2.name;
                    ++j;
                } else
                    if( j>=h2.length )
                {
                    o=h1[i];
                    name=item1.name;
                    ++i;
                } else
                    if( h1[i].date < h2[j].date )
                {
                    o=h1[i];
                    name=item1.name;
                    ++i;
                } else
                {
                    o=h2[j];
                    name=item2.name;
                    ++j;
                }
                text += "["+Qt.formatDateTime(new Date(o.date),"yyyy.MM.dd hh:mm:ss")+"] "+name+": "+o.info+"\n";
            }
            var title= "MLP CCG " + item1.name +" vs "+ item2.name;
            var params= "api_option=paste&api_dev_key=ea5baa4b6d8023fd305d9f75cce3b788&api_paste_private=1&api_paste_name="+encodeURIComponent(title)+"&api_paste_code="+encodeURIComponent(text);
            req.open("POST", "http://pastebin.com/api/api_post.php");
            req.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
            req.setRequestHeader("Content-length", params.length);
            //req.setRequestHeader("Connection", "close");
            req.send(params);
        }
    }


    Component.onCompleted:
    {
        rectangle1.state= "start";
    }

    states: [
        State {
            name: "start"

            PropertyChanges {
                target: image1
                x: -181
                y: 511
                anchors.verticalCenterOffset: 1
            }

            PropertyChanges {
                target: button1
                opacity: 1
                enabled:true
            }
            PropertyChanges {
                target: button2
                opacity: 1
                enabled:true
            }
            PropertyChanges {
                target: item1
                anchors.bottomMargin: -64
            }

            PropertyChanges {
                target: item2
                anchors.topMargin: -76
            }
        },
        State {
            name: "player1turn"
            when: rectangle1.player==1
            PropertyChanges {
                target: image1
                x: 44
                y: 311
                anchors.verticalCenterOffset: 0
                rotation: 180
            }
            PropertyChanges {
                target: button1
                enabled:false
                opacity: 0
            }
            PropertyChanges {
                target: button2
                enabled:false
                opacity: 0
            }
        },
        State {
            name: "player2turn"
            when: rectangle1.player==2
            PropertyChanges {
                target: image1
                x: 44
                y: 311
                anchors.verticalCenterOffset: 0
                rotation: 0
            }
            PropertyChanges {
                target: button1
                enabled:false
                opacity: 0
            }
            PropertyChanges {
                target: button2
                enabled:false
                opacity: 0
            }
        },
        State {
            name: "player1win"
            when: item1.score >= 15

            PropertyChanges {
                target: wintext2
                opacity: 1.0
            }

            PropertyChanges {
                target: wintext1
                opacity: 1.0
            }

            PropertyChanges {
                target: item1
                anchors.bottomMargin: -64
            }

            PropertyChanges {
                target: item2
                anchors.topMargin: -76
            }
            PropertyChanges {
                target: button1
                enabled:true
                opacity: 1
            }
            PropertyChanges {
                target: button2
                enabled:true
                opacity: 1
            }

            PropertyChanges {
                target: button3
                enabled: true
                anchors.verticalCenterOffset: 0
                opacity: 1
            }

            PropertyChanges {
                target: column1
                spacing: 30
            }
        },
        State {
            name: "player2win"
            when: item2.score >= 15

            PropertyChanges {
                target: wintext2
                opacity: 1.0
            }

            PropertyChanges {
                target: wintext1
                opacity: 1.0
            }

            PropertyChanges {
                target: item1
                anchors.bottomMargin: -64
            }

            PropertyChanges {
                target: item2
                anchors.topMargin: -76
            }
            PropertyChanges {
                target: button1
                enabled:true
                opacity: 1
            }
            PropertyChanges {
                target: button2
                enabled:true
                opacity: 1
            }

            PropertyChanges {
                target: button3
                enabled: true
                rotation: 180
                opacity: 1
            }
        }
    ]

    transitions: [
        Transition {
            SpringAnimation {
                properties: "rotation,x,y"
                spring: 2
                damping: 0.2
            }
            NumberAnimation {
                properties: "opacity,anchors.topMargin,anchors.bottomMargin"
                duration: 300
            }

        }

    ]
}
