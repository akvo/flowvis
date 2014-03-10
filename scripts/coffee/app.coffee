App = Ember.Application.create()

App.ApplicationAdapter = DS.FixtureAdapter.extend()

App.MarkerLayer = EmberLeaflet.MarkerLayer.extend(
    EmberLeaflet.PopupMixin,
        options:
            icon: L.icon
                iconUrl: 'img/well.png'
                iconSize: [64, 64]
                iconAnchor: [32, 64]
                popupAnchor: [-5, -55]
        popupContent: ( ->
            content = @get 'content'
            "Status: #{content.Status}<br/><img width=64 height=64 src='#{content.Photo}'>"
        ).property()
)

App.MarkerCollectionLayer = EmberLeaflet.MarkerCollectionLayer.extend
    contentBinding: "controller"
    itemLayerClass: App.MarkerLayer

App.IndexView = EmberLeaflet.MapView.extend
    center: L.latLng 7, -9
    zoom: 8
    childLayers: [
        EmberLeaflet.DefaultTileLayer
        App.MarkerCollectionLayer
    ]

App.IndexController = Ember.ArrayController.extend
    content: []

App.IndexRoute = Ember.Route.extend
    setupController: (controller) ->
        content = []
        controller.store.find('watersource').then (data)->
            data.forEach (item)->
                content.push
                    Status: item.get 'status'
                    location: L.latLng item.get('latitude'), item.get('longitude')
                    WPtype: item.get 'wPtype'
                    HPtype: item.get 'hPtype'
                    Photo: item.get 'photo'

            controller.set 'content', content

window.App = App
