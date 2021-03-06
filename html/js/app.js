// Generated by CoffeeScript 1.7.1
var App, collection;

App = Ember.Application.create();

App.ApplicationAdapter = DS.FixtureAdapter.extend();

App.MarkerLayer = EmberLeaflet.MarkerLayer.extend(EmberLeaflet.PopupMixin, {
  options: {
    icon: L.icon({
      iconUrl: 'img/marker.png',
      iconSize: [16, 16],
      iconAnchor: [8, 8],
      popupAnchor: [0, 0]
    })
  },
  popupContent: (function() {
    var content;
    content = this.get('content');
    return "Status: " + content.status + "<br/> Quality: " + content.quality + "<br/> Quantity: " + content.quantity + "<br/> Constructed On: " + content.constructionDate + "<br/> <img width=64 height=64 src='" + content.photo + "'>";
  }).property()
});

App.MarkerCollectionLayer = EmberLeaflet.MarkerCollectionLayer.extend({
  contentBinding: "controller",
  itemLayerClass: App.MarkerLayer
});

collection = {
  type: "FeatureCollection",
  features: [
    {
      type: "Feature",
      id: "01",
      geometry: {
        type: "Polygon",
        coordinates: [[[10, 0], [15, 0], [15, 10], [10, 10], [10, 0]]]
      },
      type: "Feature",
      id: "02",
      geometry: {
        type: "Polygon",
        coordinates: [[[-9.5, 7.2], [-9.0, 7.2], [-9.0, 6.2], [-9.5, 6.2], [-9.5, 7.2]]]
      }
    }
  ]
};

App.IndexView = EmberLeaflet.MapView.extend({
  center: L.latLng(7, -8.4),
  zoom: 9,
  childLayers: [EmberLeaflet.DefaultTileLayer, App.MarkerCollectionLayer],
  didInsertElement: function() {
    var ctrl, g, map, path, project, projectPoint, reset, svg, transform, wells;
    projectPoint = function(x, y) {
      var point;
      point = map.latLngToLayerPoint(new L.LatLng(y, x));
      this.stream.point(point.x, point.y);
      return null;
    };
    project = function(pt) {
      var point;
      point = map.latLngToLayerPoint(new L.LatLng(pt[1], pt[0]));
      return [point.x, point.y];
    };
    reset = function() {
      var bottomRight, bounds, topLeft;
      bounds = path.bounds(wells);
      if (Math.abs(bounds[0][0]) === Infinity) {
        return false;
      }
      topLeft = bounds[0];
      bottomRight = bounds[1];
      svg.attr("width", bottomRight[0] - topLeft[0]).attr("height", bottomRight[1] - topLeft[1]).style("left", topLeft[0] + "px").style("top", topLeft[1] + "px");
      g.attr("transform", "translate(" + (-topLeft[0]) + "," + (-topLeft[1]) + ")");
      return true;
    };
    this._super();
    wells = {
      type: "FeatureCollection",
      features: []
    };
    map = this._layer;
    svg = d3.select(map.getPanes().overlayPane).append("svg");
    g = svg.append("g").attr("class", "leaflet-zoom-hide");
    transform = d3.geo.transform({
      point: projectPoint
    });
    path = d3.geo.path().projection(transform);
    ctrl = this.get('controller');
    ctrl.store.find('watersource').then(function(data) {
      var feature;
      data.forEach(function(item) {
        return wells.features.push({
          type: "Feature",
          geometry: {
            type: "Point",
            coordinates: [item.get('latitude'), item.get('longitude')]
          },
          properties: item
        });
      });
      feature = g.selectAll("path").data(collection.features).enter().append("path");
      return reset();
    });
    map.on("viewreset", reset);
    reset();
    return null;
  }
});

App.IndexController = Ember.ArrayController.extend({
  content: [],
  isHidden: true,
  actions: {
    expand: function() {
      this.set('isHidden', false);
      return null;
    },
    contract: function() {
      this.set('isHidden', true);
      return null;
    }
  }
});

App.IndexRoute = Ember.Route.extend({
  setupController: function(controller) {
    var content;
    content = [];
    return controller.store.find('watersource').then(function(data) {
      data.forEach(function(item) {
        var d, x;
        d = {};
        for (x in item._data) {
          d[x] = item._data[x];
        }
        d['location'] = L.latLng(item.get('latitude'), item.get('longitude'));
        return content.push(d);
      });
      return controller.set('content', content);
    });
  }
});

window.App = App;
