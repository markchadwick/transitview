from flask import Response
from flask import abort
from flask import render_template

from transitview import app
from transitview.routes import Routes
from transitview.septa_proxy import SeptaProxy

proxy = SeptaProxy(timeout=60)

@app.route('/')
def index():
  return render_template('/index.html',
    trolleys = Routes.TROLLEYS,
    buses = Routes.BUSES)

@app.route('/route/<id>')
def route(id):
  if not [_ for (route, _) in Routes.ALL if route == id]:
    abort(404)

  route_data = proxy[id]
  if route_data is None:
    abort(500)

  return Response(route_data)
