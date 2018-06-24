from io import BytesIO
from PIL import Image
from flask import Flask, Response, request, send_file

from squarify import squarify

app = Flask(__name__)

@app.route('/squarify', methods=['POST'])
def post():
    f = request.files['file']
    im = Image.open(f.stream)
    buf = BytesIO()
    squarify(im).save(buf, format=im.format)
    return Response(buf.getvalue(),
        mimetype='application/octet-stream',
        headers={
            'Content-Disposition': 'attachment;filename=square-{}'.format(f.filename),
            },
        )

def debug():

    import os.path

    @app.route('/', methods=['GET'])
    def get():
        return send_file(os.path.join(os.path.dirname(__file__), 'resources/index.html'))

    app.run(debug=True)

if __name__ == '__main__':
    debug()
