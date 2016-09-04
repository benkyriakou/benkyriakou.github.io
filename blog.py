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

      print('Processing ' + inpath + '/' + filename)

      xml = etree.parse(inpath + '/' + filename)
      xml.xinclude()

      # Don't generate pages for external articles
      if (len(xml.xpath('/document[@rel="external"]')) > 0):
        print('Skipping external article ' + filename)
        continue

      result = transform(xml)

      print('Generating ' + outpath + '/' + name + '.html')

      result.write(outpath + '/' + name + '.html', pretty_print=True)
