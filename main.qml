import QtQuick 2.9
import QtQuick.Window 2.2
import QtWebSockets 1.0

Window {
    id: window
    visible: true
    width: Screen.desktopAvailableWidth
    height: Screen.desktopAvailableHeight
    title: qsTr("KITCHEN")
    flags:Qt.FramelessWindowHint    //Hide TileBar

    property var stringY: "0"

    //Title
    Rectangle{id: titleRec
        width: parent.width
        height: 40
        color: "#F44236"
        Rectangle{
            id: recLogo
            width: 80
            height: 40
            x: parent.x
            y: parent.y
            color: "#F44236"
            Image {
                id: imgLogo
                source: "/img/food.png"
                anchors.centerIn: parent
                width: 40
                height: 40
            }
        }
        Rectangle{
            id: recText
            width: parent.width - recLogo.width
            height: 40
            x: recLogo.x + recLogo.width
            y: recLogo.y
            color: "#F44236"
            Text {
                id: textTitle
                text: qsTr("KITCHEN")
                font.bold: true
                color: "#FFFFFF"
                anchors.centerIn: parent
            }
        }
    }

    //Table HeaderRow
    Row{
        id: headRow
        spacing: 4
        x: recLogo.x
        y: recLogo.y + recLogo.height
        width: parent.width

        Rectangle{
            id: colID
            width: 80
            height: 25
            color: "#DBDBDB"
            Text {
                id: txtID
                text: qsTr("ID")
                anchors.centerIn: parent
                color: "#606060"
            }
        }
        Rectangle{
            id: colPrioritize
            width: 90
            height: 25
            color: "#DBDBDB"
            Text {
                id: txtPrioritize
                text: qsTr("Prioritize")
                anchors.centerIn: parent
                color: "#606060"
            }
        }
        Rectangle{
            id: colOrderName
            width: parent.width - colChef.width - colTable.width - colQty.width - colPrioritize.width - colID.width
            height: 25
            color: "#DBDBDB"
            Text {
                id: txtOrderName
                text: qsTr("Order Name/Note")
                anchors.centerIn: parent
                color: "#606060"
            }
        }
        Rectangle{
            id: colQty
            width: 120
            height: 25
            color: "#DBDBDB"
            Text {
                id: txtQty
                text: qsTr("Qty")
                anchors.centerIn: parent
                color: "#606060"
            }
        }
        Rectangle{
            id: colTable
            width: 90
            height: 25
            color: "#DBDBDB"
            Text {
                id: txtTable
                text: qsTr("Table")
                anchors.centerIn: parent
                color: "#606060"
            }
        }
        Rectangle{
            id: colChef
            width: 200
            height: 25
            color: "#DBDBDB"
            Text {
                id: txtChef
                text: qsTr("Chef")
                anchors.centerIn: parent
                color: "#606060"
            }
        }
    }

    //Content Row
    Rectangle{
        id: recContent
        height: window.height - headRow.height - titleRec.height - statusRec.height
        width: parent.width
        color: "#EDEDED"
        y: headRow.y + headRow.height


    }

    //Statusext
    Rectangle{
        id: statusRec
        width: parent.width
        height: 25
        color: "grey"
        y: window.height - 25
        x: 0
        Text {
            id: statusMessage
            text: qsTr("Loading...")
            anchors.centerIn: parent
            color: "#FFFFFF"
        }
    }

    WebSocket {
               id: socket
               //url: "ws://13.67.35.142:8686/categories"
               url: "ws://13.67.35.142:8686/kitchen"
               onTextMessageReceived: {
                   // console.log(message)
                   var jsonObject = JSON.parse(message)
                   if(jsonObject["order"].length > 6){
                       statusMessage.text = "Showing 6 out of " + jsonObject["order"].length + " orders"
                   }
                   else{
                       statusMessage.text = "Showing " + jsonObject["order"].length + " orders"
                   }

                   var hasOrder=0;
                   // when server update
                   if(jsonObject["operationType"] === "update")
                   {
                        for (var i=0; i<jsonObject["order"].length; i++){
                            for(var j=0;j<recContent.children.length; j++)
                            {
                                if(recContent.children[j].objectName === jsonObject["order"][i]["_id"] && jsonObject["order"][i]["status"] !== "Accept"){
                                    console.log("xoa");
                                    recContent.children[j].destroy();
                                    for(var k =j ;k<recContent.children.length;k++)
                                    {
                                        recContent.children[k].y -= recContent.children[0].height;
                                    }
                                    stringY -= 165;
                                }else if(recContent.children[j].objectName === jsonObject["order"][i]["_id"] && jsonObject["order"][i]["status"] === "Accept"){
                                     hasOrder++;
                                }else if(recContent.children[j].objectName !== jsonObject["order"][i]["_id"] && jsonObject["order"][i]["status"] !== "Accept"){
                                    hasOrder++;
                                }

                            }
                            if(hasOrder == 0)
                            {
                                console.log(stringY);
                                console.log("them");
                                console.log(jsonObject["order"][i]["_id"]);
                                var objectString = 'import QtQuick 2.9;Rectangle{
                                                             objectName: "' + jsonObject["order"][i]["_id"] +'"
                                                             color: "white";
                                                             width: parent.width;
                                                             height: parent.height/6 - 5;
                                                             y: ' + stringY.toString() + ';
                                                             Rectangle {
                                                                         x: ' + colID.x + '
                                                                         width: ' + colID.width + ';
                                                                         height: parent.height;
                                                                         Text {
                                                                             text: qsTr("' + (i+1).toString() + '");
                                                                             anchors.centerIn: parent;
                                                                             }
                                                                         }
                                                             Rectangle {
                                                                         x: ' + colPrioritize.x + ';
                                                                         width: ' + colPrioritize.width + ';
                                                                         height: parent.height;
                                                                         Text {
                                                                             text: qsTr("' + jsonObject["order"][i]["priority"] + '");
                                                                             color: "blue";
                                                                             anchors.centerIn: parent;
                                                                             }
                                                                         }
                                                             Rectangle {
                                                                         x: ' + colOrderName.x + ';
                                                                         width: ' + colOrderName.width + ';
                                                                         height: parent.height;
                                                                         Text {
                                                                             text: qsTr("' + jsonObject["order"][i]["food"]["name"] + '");
                                                                             anchors.centerIn: parent;
                                                                             }
                                                                         }
                                                             Rectangle {
                                                                         x: ' + colQty.x + ';
                                                                         width: ' + colQty.width + ';
                                                                         height: parent.height;
                                                                         Text {
                                                                             text: qsTr("' + jsonObject["order"][i]["quantity"] + '");
                                                                             color: "red";
                                                                             font.pointSize: 20;
                                                                             anchors.centerIn: parent;
                                                                             }
                                                                         }
                                                             Rectangle {
                                                                         x: ' + colTable.x + ';
                                                                         width: ' + colTable.width + ';
                                                                         height: parent.height;
                                                                         Text {
                                                                             text: qsTr("' + jsonObject["order"][i]["table"]["name"] + '");
                                                                             anchors.centerIn: parent;
                                                                             }
                                                                         }
                                                             Rectangle {
                                                                         x: ' + colChef.x + ';
                                                                         width: ' + colChef.width + ';
                                                                         height: parent.height;
                                                                         Text {
                                                                             text: qsTr("' + jsonObject["order"][i]["user"] + '");
                                                                             anchors.centerIn: parent;
                                                                             }
                                                                         }
                                                                 }\n'
                                newObject = Qt.createQmlObject(objectString.toString(),
                                                             recContent,
                                                                  jsonObject["order"][i]["_id"]);

                                stringY = convertToInt(stringY) + recContent.height/6 + 5
                            }
                            hasOrder =0;
                        }
                   }
                   else if(jsonObject["operationType"] === "get")
                   {
                       //Xóa các đối tượng trong recContent
                       /*for(var j=0 ;j<recContent.children.length;j++)
                       {
                           recContent.children[j].destroy();
                       }*/

                       for (var i=0; i<jsonObject["order"].length; i++){
                       var order = jsonObject["order"][i]

                       //Xử lý hiển thị ảnh ưu tiên
                       var imgCheck = "";
                       if(order["priority"] !== false) imgCheck = "/img/check.png"

                       var objectNote = ""
                       var xNote = colOrderName.x
                       //Xử lý hiển thị các note
                       for(var z=0; z<order["note"].length; z++){
                           if(order["note"][z]["name"] !== null){
                               objectNote += 'Rectangle{
                                                    height: 20;
                                                    width: 90;
                                                    color: "#F4FF7C";
                                                    radius: 8;
                                                    y: ' + stringY.toString() + ' + parent.height/2;
                                                    x: ' + xNote + ';
                                                    Text {
                                                        text: "' + order["note"][z]["name"] + '";
                                                        font.italic: true;
                                                        anchors.centerIn: parent;
                                                          }
                                                    }'
                               xNote += 100;
                           }
                       }

                       var objectUser = ""
                       var xUser = colChef.x
                       var yUser = stringY
                       //Xử lý hiển thị các note
                       for(var z=0; z<order["user"].length; z++){
                           if(order["user"][z]["name"] !== null){
                               objectUser += 'Rectangle{
                                                    x: ' + xUser + ';
                                                    //y: parent.y;
                                                    width: ' + colChef.width/2 + ' - 10;
                                                    height: parent.height
                                                    Rectangle{
                                                        width: parent.width
                                                        height: 80;
                                                        y: parent.y;
                                                        Image {
                                                            source: "/img/male.png"
                                                            anchors.centerIn: parent
                                                            fillMode: Image.PreserveAspectCrop
                                                            width: 32
                                                            height: 32
                                                               }
                                                        }
                                                    Rectangle{
                                                        width: parent.width
                                                        height: parent.height * 0.25
                                                        y: parent.y + 80;
                                                        Text {
                                                            text: qsTr("' + order["user"][z]["name"] + '")
                                                            anchors.centerIn: parent
                                                            }
                                                        }
                                                    }
                                                    '
                               xUser += colChef.width/order["user"].length;
                           }
                       }

                       var objectString = 'import QtQuick 2.9;Rectangle{
                                                    objectName: "' + order["_id"] +'"
                                                    color: "white";
                                                    width: parent.width;
                                                    height: parent.height/6;
                                                    y: ' + stringY.toString() + ';
                                                    Rectangle {
                                                                x: ' + colID.x + '
                                                                width: ' + colID.width + ';
                                                                height: parent.height;
                                                                Text {
                                                                    text: qsTr("' + (i+1).toString() + '");
                                                                    anchors.centerIn: parent;
                                                                    }
                                                                }
                                                    Rectangle {
                                                                x: ' + colPrioritize.x + ';
                                                                width: ' + colPrioritize.width + ';
                                                                height: parent.height;
                                                                Image {
                                                                    source: "' + imgCheck + '"
                                                                    anchors.centerIn: parent;
                                                                    }
                                                                }
                                                    Rectangle {
                                                                x: ' + colOrderName.x + ';
                                                                width: ' + colOrderName.width + ';
                                                                height: parent.height/2;
                                                                Text {
                                                                    text: qsTr("' + order["food"]["name"] + '");
                                                                    anchors.left: parent.left;
                                                                    anchors.verticalCenter: parent.verticalCenter;
                                                                    font.pointSize: 16;
                                                                    }
                                                                }'+
                                                    objectNote +'
                                                    Rectangle {
                                                                x: ' + colQty.x + ';
                                                                width: ' + colQty.width + ';
                                                                height: parent.height;
                                                                Text {
                                                                    text: qsTr("' + order["quantity"] + '");
                                                                    color: "red";
                                                                    font.pointSize: 20;
                                                                    anchors.centerIn: parent;
                                                                    }
                                                                }
                                                    Rectangle {
                                                                x: ' + colTable.x + ';
                                                                width: ' + colTable.width + ';
                                                                height: parent.height;
                                                                Image {
                                                                    source: "/img/table.png"
                                                                    fillMode: Image.PreserveAspectCrop
                                                                    width: parent.width - 30;
                                                                    height: parent.height - 60;
                                                                    anchors.centerIn: parent;
                                                                    Text {
                                                                        text: qsTr("' + order["table"]["name"] + '");
                                                                        color: "#FFFFFF"
                                                                        anchors.centerIn: parent
                                                                        }
                                                                    }
                                                                }
                                                    Rectangle {
                                                                x: ' + colChef.x + ';
                                                                width: ' + colChef.width + ';
                                                                height: parent.height;
                                                                Text {
                                                                    text: qsTr("' + order["user"] + '");
                                                                    anchors.centerIn: parent;
                                                                    }
                                                                }'
                                                        + objectUser +'
                                                        }\n'
                       var newObject = Qt.createQmlObject(objectString.toString(),
                                                    recContent,
                                                         order["_id"]);

                       stringY = convertToInt(stringY) + recContent.height/6 + 5
                       //console.log(objectString)
                   }
                       }

               }
               onStatusChanged: if (socket.status === WebSocket.Error) {
                                    console.log("Error: " + socket.errorString)
                                } else if (socket.status === WebSocket.Open) {
                                    socket.sendTextMessage("Hello World")
                                } else if (socket.status === WebSocket.Closed) {
                                    statusMessage.text = "Socket closed"
                                }
               active: true
        }

    //VÃ¹ng mÃ n hÃ¬nh nháº¥n vÃ o sáº½ Ä‘Ã³ng cá»­a sá»• hiá»‡n thá»‹
    MouseArea {
            anchors.fill: parent
            onClicked: {
                Qt.quit();
                refreshReContent();
            }
        }

    function convertToInt(string)
    {
           var stringValue = parseInt(string);
           return stringValue;
    }

}
