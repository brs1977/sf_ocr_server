run:
	docker run -d -p 9095:9095 --name sf_ocr --rm -v /home/rttec/projects/sf_ocr_server/output/:/usr/src/app/output sf_ocr 
stop:
	docker stop sf_ocr
build:
	docker build --build-arg SF_OCR_VERSION=0.1.1 . -t sf_ocr
test:
	python test.py
logs:
	docker logs sf_ocr
rc5:
	apt-get install -y python3-pip python3-dev build-essential libgl1-mesa-dev curl autoconf libtool libleptonica-dev
	wget https://github.com/tesseract-ocr/tesseract/archive/refs/tags/5.0.0-rc1.zip
	unzip 5.0.0-rc1.zip

	cd tesseract-5.0.0-rc1
	autoreconf --install
	./configure
	make
	make install
	ldconfig

	wget https://github.com/tesseract-ocr/tessdata/blob/main/rus.traineddata?raw=true -O /usr/local/share/tessdata/rus.traineddata

