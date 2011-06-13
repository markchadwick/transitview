class Bus
  constructor: (obj) ->
    image = switch obj.Direction
      when "NorthBound" then "north.png"
      when "SouthBound" then "south.png"
      when "EastBound" then "east.png"
      when "WestBound" then "west.png"
      else "unknown.png"

    pos = new google.maps.LatLng(obj.lat, obj.lng)
    icon = new google.maps.MarkerImage(
      "/static/images/icons/" + image)

    @marker = new google.maps.Marker({
      position: pos,
      icon:     icon
    })

  remove: ->
    @marker.setMap(null)
    @marker = null

  display: (map) ->
    @marker.setMap(map)

class Updater
  constructor: (kmlUrl, frequency) ->
    @kmlUrl = kmlUrl
    @lastLayer = null
    @route = null
    @map = null
    @frequency = 100
    @buses = []

  displayRoute: (route, map) ->
    @route = route
    @map = map
    url = @kmlUrl +"/"+ route +".kml"

    if(@lastLayer)
      @lastLayer.setMap(null)

    kmlLayer = new google.maps.KmlLayer(url)
    @lastLayer = kmlLayer
    kmlLayer.setMap(map)
    this.update()

  update: ->
    if not @route
      return true

    document.location = '/#!/' +  @route
    url = '/route/' + @route
    _gaq.push(['_trackPageview', url])
    $.ajax({
      url:      url,
      success:  (data) =>
        this.setMarkers(jsonParse(data))
    })

  setMarkers: (obj) ->
    bus.remove() for bus in @buses
    @buses = new Bus(bus) for bus in obj.bus
    bus.display(@map) for bus in @buses

class Routes
  constructor: (buses, trolleys) ->
    @routeControl = this.createRouteControl(buses, trolleys)
    @changeNotify = null

  createRouteControl: (routes) ->
    selectElement = document.createElement('select')
    selectElement.id = "routeselect"
    blankOption = document.createElement('option')
    blankOption.text = 'Choose a route...'
    selectElement.appendChild(blankOption)

    busGroup = document.createElement('optgroup')
    busGroup.label = "Buses"
    selectElement.appendChild(busGroup)

    trollyGroup = document.createElement('optgroup')
    trollyGroup.label = "Trolleys"
    selectElement.appendChild(trollyGroup)

    busOpts = (this.createOption o for o in buses)
    trollyOpts = (this.createOption o for o in trolleys)

    busGroup.appendChild o for o in busOpts
    trollyGroup.appendChild o for o in trollyOpts

    google.maps.event.addDomListener(selectElement, 'change', (event) =>
      route = $(selectElement).val()
      this.changeNotify(route)
    )

    selectElement

  createOption: (option) ->
    optionElement = document.createElement('option')
    optionElement.value = option[0]
    optionElement.text = option[1]
    optionElement


class TransiteViewMap
  constructor: (routes, updater, route) ->
    @map = this.createMap()
    @map.controls[google.maps.ControlPosition.TOP_RIGHT].push(routes.routeControl)
    @updater = updater

    routes.changeNotify = (route) =>
      this.selectionChanged(route, @map)

    if route
      this.selectionChanged(route, @map)

  createMap: ->
    mapEl = document.getElementById('map_canvas')
    latLng = new google.maps.LatLng(39.95, -75.16)

    new google.maps.Map(mapEl, {
      zoom:       12,
      center:     latLng,
      mapTypeId:  google.maps.MapTypeId.ROADMAP,
      panControl:         false,
      mapTypeControl:     false,
      streetViewControl:  false
    })

  selectionChanged: (route) ->
    @updater.displayRoute(route, @map)


tv_initialize: (b_list, t_list) ->
  hash = location.hash.split('/')

  frequency = 10000 # 10 seconds
  routeControl = new Routes(b_list, t_list)
  updater = new Updater("http://www3.septa.org/transitview/kml")

  updateRoute: ->
    try
      updater.update()
    catch error
      alert(error)
    finally
      setTimeout(updateRoute, frequency)

  route = if hash and hash.length is 2
    hash[1]

  map = new TransiteViewMap(routeControl, updater, route)

  updateRoute()
