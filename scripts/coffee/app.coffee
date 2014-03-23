App = Ember.Application.create()

App.ApplicationAdapter = DS.FixtureAdapter.extend()

App.MarkerLayer = EmberLeaflet.MarkerLayer.extend(
    EmberLeaflet.PopupMixin,
        options:
            icon: L.icon
                iconUrl: 'img/marker.png'
                iconSize: [16, 16]
                iconAnchor: [8, 8]
                popupAnchor: [0, 0]

        popupContent: ( ->
            content = @get 'content'
            "Status: #{content.status}<br/>
             Quality: #{content.quality}<br/>
             Quantity: #{content.quantity}<br/>
             Constructed On: #{content.constructionDate}<br/>
            <img width=64 height=64 src='#{content.photo}'>"
        ).property()
)

App.MarkerCollectionLayer = EmberLeaflet.MarkerCollectionLayer.extend
    contentBinding: "controller"
    itemLayerClass: App.MarkerLayer

collection =
    type: "FeatureCollection"
    features:[
        type: "Feature"
        id: "01"
        geometry:
            type: "Polygon"
            coordinates: [[
                [10, 0]
                [15, 0]
                [15, 10]
                [10, 10]
                [10, 0]
            ]]
        type: "Feature"
        id: "02"
        geometry:
            type: "Polygon"
            coordinates: [[
                [-9.5, 7.2]
                [-9.0, 7.2]
                [-9.0, 6.2]
                [-9.5, 6.2]
                [-9.5, 7.2]
            ]]
    ]

App.IndexView = EmberLeaflet.MapView.extend
    center: L.latLng 7, -8.4
    zoom: 9
    childLayers: [
        EmberLeaflet.DefaultTileLayer
        App.MarkerCollectionLayer
    ]
    didInsertElement: () ->
        projectPoint = (x, y) ->
            point = map.latLngToLayerPoint new L.LatLng(y, x)
            @stream.point point.x, point.y
            null
        project = (pt) ->
            point = map.latLngToLayerPoint new L.LatLng(pt[1], pt[0])
            [ point.x, point.y ]
        reset = () ->
            bounds = path.bounds(wells)
            if Math.abs(bounds[0][0]) == Infinity
                return false
            topLeft = bounds[0]
            bottomRight = bounds[1]

            svg.attr("width", bottomRight[0] - topLeft[0])
                .attr("height", bottomRight[1] - topLeft[1])
                .style("left", topLeft[0] + "px")
                .style("top", topLeft[1] + "px")
            g.attr "transform", "translate(#{-topLeft[0]},#{-topLeft[1]})"

            #@features?.attr "d", path
            #    .style "fill-opacity", 0.8
            #    .attr "fill", "blue"

            true

        @_super()
        wells =
            type: "FeatureCollection"
            features: []

        map = @_layer
        svg = d3.select(map.getPanes().overlayPane).append "svg"
        g = svg.append("g").attr "class", "leaflet-zoom-hide"
        transform = d3.geo.transform point: projectPoint
        path = d3.geo.path().projection transform
        ctrl = @get 'controller'
        ctrl.store.find('watersource').then (data) ->
            data.forEach (item) ->
                wells.features.push
                    type: "Feature"
                    geometry:
                        type: "Point"
                        coordinates: [item.get('latitude'), item.get('longitude')]
                    properties: item

            feature = g.selectAll("path")
                    .data(collection.features)
                    .enter()
                        .append("path")
        
            #@features = g.selectAll("circle")
            #                .data(wells.features)
            #                .enter()
            #                    .append("circle")
            #                    .attr "cx", (d) ->
            #                        cd = d.geometry.coordinates
            #                        pt = map.latLngToLayerPoint new L.LatLng(cd[0], cd[1])
            #                        pt.x
            #                    .attr "cy", (d) ->
            #                        cd = d.geometry.coordinates
            #                        pt = map.latLngToLayerPoint new L.LatLng(cd[1], cd[0])
            #                        pt.y
            #                    .attr "r", 10
            #                    .attr "stroke", "black"
            #                    .attr "fill", "gray"
            #                    .attr "fill-opacity", 0.8

            reset()

        map.on("viewreset", reset)
        reset()
        null

App.IndexController = Ember.ArrayController.extend
    content: []
    isHidden: true
    actions:
        expand: ()->
            @set 'isHidden', false
            null

        contract: ()->
            @set 'isHidden', true
            null

App.IndexRoute = Ember.Route.extend
    setupController: (controller) ->
        content = []
        controller.store.find('watersource').then (data)->
            data.forEach (item)->
                d = {}
                for x of item._data
                    d[x] = item._data[x]
                d['location'] = L.latLng item.get('latitude'), item.get('longitude')
                content.push d

            controller.set 'content', content

window.App = App
