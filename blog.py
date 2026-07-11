import os
import re
import argparse
from PIL import Image
from lxml import etree
from lxml.etree import XSLTApplyError, XSLTParseError
from pygments import highlight
from pygments.lexers import guess_lexer, get_lexer_by_name
from pygments.formatters import HtmlFormatter

# Command-line arguments.
parser = argparse.ArgumentParser(description="Static blog processor")
parser.add_argument('--all', action='store_true')
parser.add_argument('--images', action='store_true')
args = parser.parse_args()

# Constants.
BASE_DIR = os.path.dirname(os.path.abspath(__file__))
SOURCE_DIR = os.path.join(BASE_DIR, 'source')
IMAGE_DIR = os.path.join(BASE_DIR, 'images')

# Static XSL to HTML transformations.
xsl = etree.parse(os.path.join(SOURCE_DIR, 'stylesheet.xsl'))
xsl.xinclude()

try:
  transform = etree.XSLT(xsl)
except XSLTParseError as e:
  print('Building transformation failed')

  for error in e.error_log:
    print('{!s}: {!s}'.format(error.level_name, error.message))

  exit(1)

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
      # First apply Pygments transforms to any codeblocks.
      for code_block in xml.xpath('//codeblock'):
        code = code_block.text
        leader_indent = len(re.match(r'\s+', code).group(0)) - 1
        code = '\n'.join([l[leader_indent:] for l in code.split('\n')])
        lang = code_block.get('lang', default='text')
        options = {}

        if lang == 'php':
            options['startinline'] = True

        lexer = get_lexer_by_name(lang, **options) if lang else guess_lexer(code)
        pygments_code = highlight(code, lexer, HtmlFormatter())
        code_block.getparent().replace(code_block, etree.fromstring(pygments_code))

      # Then apply the XSL styles to the rest.
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
