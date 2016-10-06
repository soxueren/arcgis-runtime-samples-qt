// [WriteFile Name=SearchForWebmap, Category=CloudAndPortal]
// [Legal]
// Copyright 2016 Esri.

// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
// http://www.apache.org/licenses/LICENSE-2.0

// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
// [Legal]

import QtQuick 2.6
import QtQuick.Controls 1.4
import QtQuick.Layouts 1.3
import Esri.ArcGISRuntime 100.0
import Esri.ArcGISExtras 1.1
import Esri.ArcGISRuntime.Toolkit.Dialogs 2.0

Rectangle {
    id: rootRectangle
    clip: true

    width: 800
    height: 600

    property real scaleFactor: System.displayScaleFactor

    function search(keyWord) {

        portal.findItems(webmapQuery);

        webmapsModel.append({"name": "Imagery"});
        webmapsModel.append({"name": "Imagery with labels"});
        webmapsModel.append({"name": "Light Gray Canvas"});
        webmapsModel.append({"name": "National Geographic"});
        webmapsModel.append({"name": "Oceans"});
        webmapsModel.append({"name": "Streets"});
        webmapsModel.append({"name": "Terrain with labels"});
        webmapsModel.append({"name": "Topographic"});

        webmapsList.model = webmapsModel;
        webmapsList.visible = true;
        mapView.visible = false;
    }

    function selectWebmap(webmapName) {
        var bmap = ArcGISRuntimeEnvironment.createObject("BasemapImagery");
        map.basemap = bmap;
        mapView.visible = true;
        webmapsModel.clear();
    }

    ListModel {
        id: webmapsModel
    }

    PortalQueryParametersForItems {
        id: webmapQuery
        type: Enums.PortalItemTypeWebMap
    }

    Portal {
        id: portal
        loginRequired: true
        credential: Credential {
            oAuthClientInfo: OAuthClientInfo {
                oAuthMode: Enums.OAuthModeUser
                clientId: "W3hPKzPbeJ0tr8aj"
            }
        }

        Component.onCompleted: load();

        onLoadStatusChanged: {
            if (loadStatus === Enums.LoadStatusFailedToLoad)
                retryLoad();

            if (loadStatus !== Enums.LoadStatusLoaded)
                return;

            searchBox.visible = true
        }

        onFindItemsResultChanged: {
            var foundWebmaps = portal.findItemsResult;
            if (foundWebmaps)
                console.log("found",foundWebmaps.totalResults);
        }
    }

    Component {
        id: webmapDelegate
        Rectangle {
            anchors.margins: 25
            width: webmapsList.width
            height: 24 * scaleFactor
            border.color: "lightgrey"
            radius: 10

            Text {
                anchors{fill: parent; margins: 10}
                text: name
                color: "grey"
                horizontalAlignment: Text.AlignHCenter
            }

            MouseArea {
                anchors.fill: parent
                onClicked: webmapsList.currentIndex = index;
                onDoubleClicked: selectWebmap(name);
            }
        }
    }

    Component {
        id: highlightDelegate
        Rectangle {
            z: 110
            anchors.margins: 25
            width: webmapsList.width
            height: 24 * scaleFactor
            color: "orange"
            radius: 4

            Text {
                anchors{fill: parent; margins: 10}
                text: webmapsModel.count > 0 ? webmapsModel.get(webmapsList.currentIndex).name : ""
                font.bold: true
                color: "white"
                horizontalAlignment: Text.AlignHCenter
            }
        }
    }

    BusyIndicator {
        anchors.centerIn: parent
        running: portal.loadStatus !== Enums.LoadStatusLoaded
    }

    Rectangle {
        id: resultsBox
        visible: webmapsModel.count > 0
        anchors {top: searchBox.bottom; bottom: parent.bottom; left: parent.left; right: parent.right; margins: 10 * scaleFactor}
        border.color: "grey"
        border.width: 2
        radius: 5


        Text {
            id: resultsTitle
            anchors { margins: 10; top: parent.top; left: parent.left; right: parent.right }
            text: "webmaps: " + keyWordField.text
            font.bold: true
            font.pointSize: 10
            horizontalAlignment: Text.AlignHCenter
        }

        ListView {
            id: webmapsList
            anchors { margins: 20; top: resultsTitle.bottom; bottom: parent.bottom; left: parent.left; right: parent.right }
            clip: true
            model: webmapsModel
            delegate: webmapDelegate
            highlightFollowsCurrentItem: true
            highlight: highlightDelegate
        }

    }

    Column {
        visible: portal.loadStatus === Enums.LoadStatusLoaded
        id: searchBox
        anchors {top: parent.top; horizontalCenter: parent.horizontalCenter; margins: 10 * scaleFactor}
        height: 100
        spacing:5

        Text {
            id: instruction
            text: qsTr("search for webmaps:")
            font.bold: true
        }

        Row {
            spacing: 5
            TextField {
                id: keyWordField
                placeholderText: "enter keyword"

                Keys.onReturnPressed: {
                    if (text.length > 0)
                        search(text);
                }
            }

            Image {
                source: "qrc:/Samples/CloudAndPortal/SearchForWebmap/searchIcon.png"
                width: height
                height: keyWordField.height

                MouseArea {
                    anchors.fill: parent
                    enabled: keyWordField.text.length > 0
                    onClicked : search(keyWordField.text);
                }
            }
        }
    }

    MapView {
        id: mapView
        visible: false
        anchors {top: searchBox.bottom; bottom: parent.bottom; left: parent.left; right: parent.right; margins: 10 * scaleFactor}

        Map {
            id: map
            spatialReference: SpatialReference.createWebMercator()
        }
    }

    AuthenticationView {
        authenticationManager: AuthenticationManager
    }

    // Neatline rectangle
    Rectangle {
        anchors.fill: parent
        color: "transparent"
        border {
            width: 0.5 * scaleFactor
            color: "black"
        }
    }
}
