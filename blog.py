import os
import sass
import argparse
from PIL import Image
from lxml import etree
from lxml.etree import XSLTApplyError

parser = argparse.ArgumentParser(description="Static blog processor")
parser.add_argument('--images', action='store_true')
args = parser.parse_args()

xsl = etree.parse('./source/stylesheet.xsl')
transform = etree.XSLT(xsl)

listing = os.walk('./source')

# Build the content from XML source.
for item in listing:
  inpath, dirnames, filenames = item

  for filename in filenames:
    name, extension = os.path.splitext(filename)

    if extension == '.xml':
      outpath = inpath.replace('./source', '.')

      if not os.path.exists(outpath):
        os.makedirs(outpath)

      print('Processing ' + inpath + '/' + filename)

      xml = etree.parse(inpath + '/' + filename)
      xml.xinclude()

      # Don't generate pages for external articles
      if (len(xml.xpath('/document[@rel="external"]')) > 0):
        print('Skipping external article ' + filename)
        continue

      try:
        result = transform(xml)
        print('Generating ' + outpath + '/' + name + '.html')
        result.write(outpath + '/' + name + '.html', pretty_print=True)
      except XSLTApplyError as e:
        print('Transformation failed')

        for error in transform.error_log:
          print('{!s}: {!s}'.format(error.level_name, error.message))


if args.images:
  im_derivatives = (760, 320)

  # Generate image derivatives
  for image in os.listdir('./images/articles'):
    print('Generating derivatives for image {!s}'.format(image))
    im = Image.open(os.path.join('./images/articles', image))

    for derivative in im_derivatives:
      im_out_size = (derivative, int(im.size[1] / (im.size[0] / derivative)))
      im_out = im.resize(im_out_size, resample=Image.LANCZOS)
      original_filename, original_extension = os.path.splitext(image)
      im_outname = original_filename + '_' + str(derivative) + original_extension
      im_outpath = os.path.join('./images/derivatives', im_outname)
      im_out.save(im_outpath)


# Build CSS from SCSS.
# First get a sorted list of files
print('Generating CSS')

SCSS_BASE = './scss'
CSS_FILE = './css/style.css'

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
  print('Writing CSS to {!s}'.format(CSS_FILE))

  # Strip BOM from string
  # @todo: Figure out whether this comes from libsass or the pip
  # package. See https://github.com/dahlia/libsass-python/pull/52.
  css_string = css_string.replace('\uFEFF', '')

  fh.write(css_string)
