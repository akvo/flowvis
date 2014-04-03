App = Ember.Application.create()

App.ApplicationAdapter = DS.FixtureAdapter.extend()

App.Flowdata = DS.Model.extend
    surveyDate: DS.attr 'date'
    submitter: DS.attr 'string'
    settlement: DS.attr 'string'
    wPtype: DS.attr 'string'
    hPtype: DS.attr 'string'
    status: DS.attr 'string'
    mainProblem: DS.attr 'string'
    constructionDate: DS.attr 'date'
    whoInstalled: DS.attr 'string'
    usedForDrinking: DS.attr 'boolean'
    quality: DS.attr 'string'
    quantity: DS.attr 'string'
    waterCommittee: DS.attr 'boolean'
    collectMoney: DS.attr 'string'
    photo: DS.attr 'string'
    latitude: DS.attr 'number'
    longitude: DS.attr 'number'

App.IndexView = EmberLeaflet.MapView.extend
    center: L.latLng 6.22, -9.25
    zoom: 9
    didInsertElement: () ->
        getBounds = (data) ->
            tlx = tly = Infinity
            brx = bry = -Infinity
            for item in data
                pt = map.latLngToLayerPoint item.LatLng
                if pt.x > brx
                    brx = pt.x
                if pt.y > bry
                    bry = pt.y
                if pt.x < tlx
                    tlx = pt.x
                if pt.y < tly
                    tly = pt.y
            [[tlx, tly],[brx, bry]]

        update = () ->
            feature?.attr "transform", (d) ->
                "translate(#{map.latLngToLayerPoint(d.LatLng).x}, 
                    #{map.latLngToLayerPoint(d.LatLng).y})"

            bounds = getBounds flowdata
            tl = bounds[0]
            br = bounds[1]
            svg.attr "width", br[0] - tl[0] + 40
                .attr "height", br[1] - tl[1] + 40
                .style "left", "#{tl[0]-10}px"
                .style "top", "#{tl[1]-10}px"


            g.attr "transform",
                "translate(#{-tl[0]+10},#{-tl[1]+10})"

        projectPoint = (x, y) ->
            pt = map.latLngToLayerPoint new L.LatLng(y, x)
            this.stream.point pt.x, pt.y

        feature = null
        @_super()
        map = @_layer
        svg = d3.select(map.getPanes().overlayPane).append "svg"
        g = svg.append("g").attr "class", "leaflet-zoom-hide"
        ctrl = @get 'controller'
        flowdata = []
        fields = []
        Ember.get(App.Flowdata, 'fields').forEach (field) ->
            fields.push field
        ctrl.store.find('flowdata').then (data) ->
            data.forEach (item) ->
                d = {}
                for f in fields
                    d[f] = item.get f
                d.LatLng = new L.LatLng(item.get('latitude'), item.get('longitude'))
                flowdata.push d

            feature = g.selectAll "circle"
                .data flowdata
                .enter().append "circle"
                    .style "stroke", "black"
                    .style "opacity", 0.6
                    .style "fill", (d) ->
                        if d.quality.istartswith "soft"
                            return "green"
                        "red"
                    .attr "r", 5
                    .attr "transform", (d) ->
                        pt = map.latLngToLayerPoint(d.LatLng)
                        "translate(#{pt.x},#{pt.y})"

            map.on "viewreset", update
            update()

window.App = App
