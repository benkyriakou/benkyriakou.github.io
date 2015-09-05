import os
from lxml import etree

xsl = etree.parse('./source/stylesheet.xsl')
transform = etree.XSLT(xsl)

listing = os.walk('./source')

for item in listing:
  inpath, dirnames, filenames = item

  for filename in filenames:
    name, extension = os.path.splitext(filename)

    if extension == '.xml':
      outpath = inpath.replace('./source', '.')

      if not os.path.exists(outpath):
        os.makedirs(outpath)

      xml = etree.parse(inpath + '/' + filename)
      xml.xinclude()
      result = transform(xml)
      result.write(outpath + '/' + name + '.html', pretty_print=True)
