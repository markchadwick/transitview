from google.appengine.api import memcache
from google.appengine.api import urlfetch

class SeptaProxy(object):
  def __init__(self, timeout):
    self._timeout = timeout

  def __getitem__(self, key):
    cached = memcache.get(key)
    if cached is not None:
      return cached

    route_data = self._fetch_route_data(key)
    if route_data is not None:
      memcache.set(key, route_data, self._timeout)

    return route_data

  def _fetch_route_data(self, route):
    """
    route files live at http://www.septa.org/transitview/bus_route_data/MFO
    """
    url = "http://www3.septa.org/transitview/bus_route_data/%s" % route
    result = urlfetch.fetch(url)
    if result.status_code == 200:
      return result.content
    else:
      return None
