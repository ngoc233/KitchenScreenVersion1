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
    property var dataArray: []
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
                //source: "/images/food.png"
                source: "http://www.eatlogos.com/food_and_drinks/png/vector_food_orange_logo.png"
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
            width: 180
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
            width: 400
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
            text: qsTr("Showing 6 out of 15 orders")
            anchors.centerIn: parent
            color: "#FFFFFF"
        }
    }

    WebSocket {
           id: socket
           //url: "ws://13.67.35.142:8686/categories"
           url: "ws://13.67.35.142:8686/kitchen"
           onTextMessageReceived: {
               //console.log(message)
               //_createTime
               var jsonObject = JSON.parse(message)


               //kiểm tra xem có thêm dữ liệu hay không
               var hasOrder=0;
               // when server update
               if(jsonObject["operationType"] === "update")
               {
                    for (var i=0; i<jsonObject["order"].length; i++){
                        for(var j=0;j<dataArray.length; j++)
                        {
                            // nếu không accpet thì xóa
//                            console.log("status la : " + jsonObject["order"][i]["status"]);
                            if(dataArray[j]["_id"] === jsonObject["order"][i]["_id"] && jsonObject["order"][i]["status"] !== "Accept"){
                                console.log("xoa");
                                recContent.children[j].destroy();
                                //update lại dữ liệu của dataArray để true trước false
                                for(var deleteArray=0;deleteArray<dataArray.length;deleteArray++)
                                {
                                   if(dataArray[deleteArray]["_id"] === jsonObject["order"][i]["_id"])
                                   {
                                       console.log("gia tri can xoa la" + jsonObject["order"][i]["food"]["name"]);
                                       // vì không thể xóa phần từ của array trong qml lên phải đẩy xuống cuối và xóa
                                       dataArray[deleteArray]["priority"] = false;
                                       dataArray[deleteArray]["_createTime"] = 0;
                                   }

                                }
                                sortArray(dataArray);
                                //duyetMang(dataArray);
                                console.log("du lieu xoa la" + dataArray.pop()["food"]["name"]);
                                console.log("xoa data khoi array");

                            }else if(dataArray[j]["_id"] === jsonObject["order"][i]["_id"] && jsonObject["order"][i]["status"] === "Accept"){
                                if(dataArray[j]["priority"] !== jsonObject["order"][i]["priority"] )
                                {
                                    dataArray[j]["priority"] = jsonObject["order"][i]["priority"];
                                    sortArray(dataArray);
                                    // vừa fixed xem xét lên xóa hay để lại
                                    hasOrder++;
                                }
                                else
                                {
                                    hasOrder++;
                                }

                            }else if(dataArray[j]["_id"] !== jsonObject["order"][i]["_id"] && jsonObject["order"][i]["status"] !== "Accept"){
                                hasOrder++;
                            }

                        }
                        // thêm dữ liệu ( đây là trường hợp server thêm mới 1 ID và có status là accept
                        if(hasOrder == 0)
                        {
                            console.log("them");
                            //thêm dữ liệu vào dataArray;
                            dataArray[dataArray.length] = jsonObject["order"][i];
                            console.log("value uu tien la" + dataArray[dataArray.length -1]["priority"]);
                            //console.log("them data vao dataArray : " + console.log(dataArray[dataArray.length -1]["_id"]));

                            // sort lại dataArray
                            sortArray(dataArray);
                        }
                        hasOrder = 0;
                    }

                    //remove all recContent
                    for(var i=0 ;i<recContent.children.length;i++)
                    {
                        recContent.children[i].destroy();
                    }
                    // add new data to recContent
                    stringY = 0;
                    console.log("do dai cua dataArray sau khi update la " +dataArray.length);

                    //sort dataArray
                    sortArray(dataArray);
                    checkOrder(dataArray);
                    // send new data for recContent
                    //duyetMang(dataArray)
                    for (var i=0; i<dataArray.length; i++){
                    var order = dataArray[i];
                        //Xử lý hiển thị ảnh ưu tiên
                        var imgCheck = "";
                        if(order["priority"] !== false) imgCheck = "/images/check-mark.png"

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
                                                     y: parent.height/2;
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
                        //Xử lý hiển thị các user
                        for(var z=0; z<order["user"].length; z++){
                            if(order["user"][z]["name"] !== null){
                                objectUser += 'Rectangle{
                                                     x: ' + xUser + ';
                                                     //y: parent.y;
                                                     width: ' + colChef.width/order["user"].length + ' - 10;
                                                     height: parent.height
                                                     Rectangle{
                                                         width: parent.width
                                                         height: 80;
                                                         y: parent.y;
                                                         Image {
                                                             source: "/images/male.png"
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
                                                     height: parent.height/8;
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
                                                                     width: 40; height: 40;
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
                                                                     source: "/images/table.png"
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

                        stringY = convertToInt(stringY) + recContent.height/8 + 5
                }
               }
               // when server run
               else if(jsonObject["operationType"] === "get")
               {
                    //add data to array
                    for(var i=0;i<jsonObject["order"].length;i++)
                    {
                        dataArray[i]= jsonObject["order"][i];
                    }
                    checkOrder(jsonObject["order"]);
                    console.log("do dai cua dataArray sau khi get la " +dataArray.length);

                    sortArray(dataArray);


                   for (var i=0; i<dataArray.length; i++){
                   var order = dataArray[i]

                       //Xử lý hiển thị ảnh ưu tiên
                       var imgCheck = "";
                       if(order["priority"] !== false) imgCheck = "/images/check-mark.png"

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
                                                    y: parent.height/2;
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
                       //Xử lý hiển thị các user
                       for(var z=0; z<order["user"].length; z++){
                           console.log(order["user"][z]["name"]);
                           if(order["user"][z]["name"] !== null){
                               objectUser += 'Rectangle{
                                                    x: ' + xUser + ';
                                                    //y: parent.y;
                                                    width: ' + colChef.width/order["user"].length + ' - 10;
                                                    height: parent.height
                                                    Rectangle{
                                                        width: parent.width
                                                        height: 80;
                                                        y: parent.y;
                                                        Image {
                                                            source: "/images/male.png"
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
                                                    height: parent.height/8;
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
                                                                    width: 40; height: 40;
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
                                                                    source: "/images/table.png"
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

                       stringY = convertToInt(stringY) + recContent.height/8 + 5
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
    Text{
        id: numberRow
        text: "0"
        visible: false
    }

    //Vùng màn hình nhấn vào sẽ đóng cửa sổ hiện thị
    MouseArea {
            anchors.fill: parent
            onClicked: {
                Qt.quit();
            }

        }

    function convertToInt(string)
    {
           var stringValue = parseInt(string);
           return stringValue;
    }
    function sortArray(dataArray)
    {
        //sort according priority
        for(var pi=0;pi<dataArray.length -1;pi++)
        {
            for(var pj=pi+1;pj<dataArray.length;pj++)
            {
                if(dataArray[pj]["priority"] === true && dataArray[pi]["priority"] === false)
                {
                    var pTemp = dataArray[pj];
                    dataArray[pj] = dataArray[pi];
                    dataArray[pi] = pTemp;
                }
            }
        }
        //sort according create time
        for(var ti=0;ti<dataArray.length -1;ti++)
        {
            for(var tj=ti+1;tj<dataArray.length;tj++)
            {
                if( dataArray[tj]["priority"] === dataArray[ti]["priority"])
                {
                    if(dataArray[tj]["_createTime"] > dataArray[ti]["_createTime"] )
                    {
                        var tTemp = dataArray[tj];
                        dataArray[tj] = dataArray[ti];
                        dataArray[ti] = tTemp;
                    }
                }
            }
        }
    }
    function duyetMang(dataArray)
    {
        console.log("duyet mang");
        for(var i=0;i<dataArray.length;i++)
        {
            console.log("ten la " +dataArray[i]["food"]["name"] + "gtri uu tien la " +dataArray[i]["priority"]);
        }
    }
    //hiển thị số order ở footter
    function checkOrder(dataArray){
        if(dataArray.length > 8){
            statusMessage.text = "Showing 8 out of " + dataArray.length + " orders"
            numberRow.text = "8"
        }
        else{
            statusMessage.text = "Showing " + dataArray.length + " orders"
            numberRow.text = dataArray.length
        }
    }
}
