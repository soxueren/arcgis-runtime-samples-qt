// [WriteFile Name=ShowCallout, Category=DisplayInformation]
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

#include "ShowCallout.h"

#include "Map.h"
#include "MapQuickView.h"
#include "CalloutData.h"
#include "GeometryEngine.h"

using namespace Esri::ArcGISRuntime;

ShowCallout::ShowCallout(QQuickItem* parent):
    QQuickItem(parent),
    m_map(nullptr),
    m_mapView(nullptr)
{
}

ShowCallout::~ShowCallout()
{
}

void ShowCallout::componentComplete()
{
    QQuickItem::componentComplete();

    // find QML MapView component
    m_mapView = findChild<MapQuickView*>("mapView");
    m_mapView->setWrapAroundMode(WrapAroundMode::Disabled);

    // Create a map using the topographic basemap
    m_map = new Map(Basemap::topographic(this), this);
    m_map->setInitialViewpoint(Viewpoint(Point(-13041154, 3858170, SpatialReference(3857)), 1e5));

    // Set map to map view
    m_mapView->setMap(m_map);

    // initialize callout
    m_mapView->calloutData()->setVisible(false);
    m_mapView->calloutData()->setTitle("Location");
    m_mapView->calloutData()->setImageUrl(QUrl("qrc:/Samples/DisplayInformation/ShowCallout/RedShinyPin.png"));

    // display callout on mouseclick
    connect(m_mapView, &MapQuickView::mouseClick, [this](QMouseEvent& mouseEvent){
        if (m_mapView->calloutData()->isVisible())
            m_mapView->calloutData()->setVisible(false);
        else
        {
            Point mapPoint = GeometryEngine::project(m_mapView->screenToLocation(mouseEvent.x(), mouseEvent.y()), SpatialReference(3857));
            m_mapView->calloutData()->setLocation(mapPoint);          
            m_mapView->calloutData()->setDetail("lat: " + QString::number(mapPoint.x()) + " long: " + QString::number(mapPoint.y()));
            m_mapView->calloutData()->setVisible(true);
        }
        qDebug() << m_mapView->calloutData()->detail();
        qDebug() << m_mapView->calloutData()->screenPoint();
        qDebug() << m_mapView->calloutData()->isVisible();
        qDebug() << m_mapView->calloutData()->location();
    });
}

CalloutData* ShowCallout::calloutData() const
{
    return m_mapView->calloutData();
}
