from PIL import Image

def squarify(im):
    dom = max(im.width, im.height)
    dim = dom - ((dom - im.width) % 2)
    x = (dim - im.width)//2
    y = max(0, (dim - im.height)//2)
    out = Image.new(im.mode, (dim, dim))
    out.paste(im, (x, y))
    return out

def main():
    import sys
    from argparse import ArgumentParser
    parser = ArgumentParser()
    parser.add_argument('in_path', metavar='INPUT_IMAGE_PATH', help='Input image path, or - for stdin.')
    parser.add_argument('out_path', metavar='OUTPUT_IMAGE_PATH', nargs='?', help='Output image path, or - for stdout. Default to square-INPUT_IMAGE_PATH, or - if INPUT_IMAGE_PATH is -.')
    args = parser.parse_args()
    in_file = sys.stdin.buffer if args.in_path == '-' else args.in_path
    if args.out_path is None:
        out_file = sys.stdout.buffer if args.in_path == '-' else 'square-{}'.format(args.in_path)
    else:
        out_file = sys.stdout.buffer if args.out_path == '-' else args.out_path
    in_im = Image.open(in_file)
    squarify(in_im).save(out_file, format=in_im.format)

if __name__ == '__main__':
    main()
