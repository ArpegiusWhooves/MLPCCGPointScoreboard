import QtQuick 2.0
//import Ubuntu.Components 1.1
import QtQuick.Controls 1.1

ListView {
    id: listView1
    delegate: Item {
        x: 5
        width: parent.width / 1.5
        height: delegatetext1.height
        Row {
            id: row1
            spacing: 5
            Rectangle {
                width: 10
                height: delegatetext1.height
                color: colorCode
            }
            
            Text {
                id:delegatetext1
                text: info
                font.pixelSize: listView1.height / 12.0
                anchors.verticalCenter: parent.verticalCenter
                font.family: fontCelestiaRedux.name;
            }
        }
    }
}
