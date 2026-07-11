.PHONY: all build install css images

all: css images

build:
	. venv/bin/activate; python blog.py

install:
	sudo apt install yui-compressor virtualenv
	virtualenv venv -q
	. venv/bin/activate; pip install -r requirements.txt

css:
	rm ./css/style.css
	cat ./source/css/*.css >> ./css/style.css
	yui-compressor css/style.css -o css/style.css

images:
	. venv/bin/activate python blog.py --images