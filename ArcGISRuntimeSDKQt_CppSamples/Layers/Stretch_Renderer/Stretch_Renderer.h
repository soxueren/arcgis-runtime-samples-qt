// [WriteFile Name=Stretch_Renderer, Category=Layers]
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

#ifndef STRETCH_RENDERER_H
#define STRETCH_RENDERER_H

namespace Esri
{
  namespace ArcGISRuntime
  {
    class MapQuickView;
    class RasterLayer;
  }
}

#include <QQuickItem>

class Stretch_Renderer : public QQuickItem
{
  Q_OBJECT

public:
  Stretch_Renderer(QQuickItem* parent = nullptr);
  ~Stretch_Renderer();    

  void componentComplete() Q_DECL_OVERRIDE;

  enum class StretchColorRampType
  {
    DemLight,
    DemScreen,
    Elevation
  };
  Q_ENUM(StretchColorRampType)

  Q_INVOKABLE void applyStretchRenderer(StretchColorRampType colorRampType);

private:
  Esri::ArcGISRuntime::MapQuickView* m_mapView;
  Esri::ArcGISRuntime::RasterLayer* m_rasterLayer;
  QString m_dataPath;
};

#endif // STRETCH_RENDERER_H