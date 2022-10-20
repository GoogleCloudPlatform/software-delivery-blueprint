# Copyright 2022 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

import os
import socket

from flask import Flask
from flask import Response

app = Flask(__name__)

@app.route('/')
def hello_world():
  hostname = socket.gethostname()
  #hello_target = os.environ.get('HELLO_TARGET', 'World')
  return 'Hello World!\n'

@app.route('/healthz')
def healthz():
  return Response("{'a':'b'}", status=201, mimetype='application/json')