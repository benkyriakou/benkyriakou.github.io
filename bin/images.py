import os

from PIL import Image

print('\nGenerating image derivatives\n')

BASE_DIR = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
IMAGE_DIR = os.path.join(BASE_DIR, 'images')

# Current we have a 320px and a 760px version
DERIVATIVE_WIDTHS = (320, 760)
ARTICLE_IMAGE_DIR = os.path.join(IMAGE_DIR, 'articles')
DERIVATIVE_IMAGE_DIR = os.path.join(IMAGE_DIR, 'derivatives')

for item in os.walk(ARTICLE_IMAGE_DIR):
    inpath, dirnames, filenames = item

    jpg_files = [f for f in filenames if f.endswith('.jpg') or f.endswith('.png')]

    for filename in jpg_files:
        input_path = os.path.join(inpath, filename)
        relative_path = os.path.relpath(input_path, IMAGE_DIR)

        print('Generating derivatives for image {!s}'.format(relative_path))
        pil_image = Image.open(input_path)

        for derivative_width in DERIVATIVE_WIDTHS:
            source_width, source_height = pil_image.size
            derivative_size = (derivative_width, int(source_height / (source_width / derivative_width)))
            pil_image_out = pil_image.resize(derivative_size, resample=Image.Resampling.LANCZOS)

            original_filename, original_extension = os.path.splitext(filename)

            outname = original_filename + '_' + str(derivative_width) + original_extension
            outpath = inpath.replace(ARTICLE_IMAGE_DIR, DERIVATIVE_IMAGE_DIR)
            outfile = os.path.join(outpath, outname)

            if not os.path.exists(outpath):
                os.makedirs(outpath)

            pil_image_out.save(outfile)