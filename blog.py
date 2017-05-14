import os
import sass
import argparse
from PIL import Image
from lxml import etree
from lxml.etree import XSLTApplyError

# Command-line arguments.
parser = argparse.ArgumentParser(description="Static blog processor")
parser.add_argument('--all', action='store_true')
parser.add_argument('--css', action='store_true')
parser.add_argument('--images', action='store_true')
args = parser.parse_args()

# Constants.
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
SOURCE_DIR = os.path.join(BASE_DIR, 'source')
IMAGE_DIR = os.path.join(BASE_DIR, 'images')

# Static XSL to HTML transformations.
xsl = etree.parse(os.path.join(SOURCE_DIR, 'stylesheet.xsl'))
xsl.xinclude()
transform = etree.XSLT(xsl)

# Build CSS from SCSS.
if args.all or args.css:
  print('\nGenerating CSS\n')

  SCSS_BASE = os.path.join(BASE_DIR, 'scss')
  CSS_FILE = os.path.join(BASE_DIR, 'css', 'style.css')

# First get a sorted list of files for consistency.
  scss_files = os.listdir(SCSS_BASE)
  scss_files.sort()

  # Filter out anything without a .scss extension
  scss_files = [f for f in scss_files if f.endswith('.scss')]

  css_string = ''

  # Build the new compiled file
  for scss_file in scss_files:
    print('Processing {!s}'.format(scss_file))

    css_string += sass.compile(
      filename=os.path.join(SCSS_BASE, scss_file),
      output_style='compressed'
    )

  # # Write the new CSS file
  with open(CSS_FILE, 'w', encoding='utf8') as fh:
    print('Writing CSS to {!s}'.format(CSS_FILE.replace(BASE_DIR, '')))

    # Strip BOM from string
    # @todo: Figure out whether this comes from libsass or the pip
    # package. See https://github.com/dahlia/libsass-python/pull/52.
    css_string = css_string.replace('\uFEFF', '')

    fh.write(css_string)

print('Generating HTML\n')

# Build the content from XML source.
for item in os.walk(SOURCE_DIR):
  inpath, dirnames, filenames = item
  xml_files = [f for f in filenames if f.endswith('.xml')]

  for filename in xml_files:
    name, extension = os.path.splitext(filename)
    outpath = inpath.replace(SOURCE_DIR, BASE_DIR)

    if not os.path.exists(outpath):
      os.makedirs(outpath)

    infile = os.path.join(inpath, filename)
    print('Processing {!s}'.format(infile.replace(BASE_DIR, '')))

    xml = etree.parse(infile)
    xml.xinclude()

    # Don't generate pages for external articles.
    if xml.xpath('/document[@rel="external"]'):
      print('Skipping external article ' + filename)
      continue

    try:
      result = transform(xml)
      outfile = os.path.join(outpath, name + '.html')

      print('Generating {!s}'.format(outfile.replace(BASE_DIR, '')))
      result.write(outfile, pretty_print=True)
    except XSLTApplyError as e:
      print('Transformation failed')

      for error in transform.error_log:
        print('{!s}: {!s}'.format(error.level_name, error.message))

# Generate image derivatives.
if args.all or args.images:
  print('\nGenerating image derivatives\n')

  # Current we have a 320px and a 760px version
  DERIVATIVE_WIDTHS = (320, 760)
  ARTICLE_IMAGE_DIR = os.path.join(IMAGE_DIR, 'articles')

  for source_image in os.listdir(ARTICLE_IMAGE_DIR):
    print('Generating derivatives for image {!s}'.format(source_image))
    pil_image = Image.open(os.path.join(ARTICLE_IMAGE_DIR, source_image))

    for derivative_width in DERIVATIVE_WIDTHS:
      source_width, source_height = pil_image.size
      derivative_size = (derivative_width, int(source_height / (source_width / derivative_width)))
      pil_image_out = pil_image.resize(derivative_size, resample=Image.LANCZOS)

      original_filename, original_extension = os.path.splitext(source_image)

      image_outname = original_filename + '_' + str(derivative_width) + original_extension
      image_outpath = os.path.join(IMAGE_DIR, 'derivatives', image_outname)
      pil_image_out.save(image_outpath)
