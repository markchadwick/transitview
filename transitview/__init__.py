from flask import Flask

app = Flask('transitview')
app.debug = True

from transitview import views
