from PIL import Image

def squarify(im):
    dom = max(im.width, im.height)
    dim = dom - ((dom - im.width) % 2)
    x = (dim - im.width)//2
    y = max(0, (dim - im.height)//2)
    out = Image.new(im.mode, (dim, dim))
    out.paste(im, (x, y))
    return out
