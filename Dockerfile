FROM tiangolo/uvicorn-gunicorn-fastapi:python3.7

# EXPOSE 9095

RUN apt-get update -y && apt-get install -y python3-pip python3-dev build-essential libgl1-mesa-dev curl autoconf libtool libleptonica-dev

#tesseract-ocr-rus #libsqlite3-dev

# tesseract 5.0
RUN wget https://github.com/tesseract-ocr/tesseract/archive/refs/tags/5.0.0-beta-20210916.zip
RUN unzip 5.0.0-beta-20210916.zip

RUN cd tesseract-5.0.0-beta-20210916 && \
    autoreconf --install && \
    ./configure && \
    make && \
    make install && \
    ldconfig

RUN wget https://github.com/tesseract-ocr/tessdata/blob/main/rus.traineddata?raw=true -O /usr/local/share/tessdata/rus.traineddata


RUN python -m pip install --upgrade pip

# fix pytesseract
RUN pip3 install Pillow
RUN pip3 install --upgrade Pillow
RUN pip3 install gdown

WORKDIR /usr/src/app

RUN mkdir /usr/src/app/output
RUN mkdir /usr/src/app/models
VOLUME ["/usr/src/app/output"]

# copy models
# COPY models/*.pkl /usr/src/app/models/
RUN gdown --id 1-Q5BGBKs53ZsZZXgzTnNVxKq78ScZa20 -O models/type.pkl \
    && gdown --id 1-PlVu3-wGVVIiBb2fcEpHzr-SLLSrw-x -O models/orient.pkl

WORKDIR /tmp

ARG SF_OCR_VERSION=unknown
RUN SF_OCR_VERSION=${SF_OCR_VERSION} git clone https://github.com/brs1977/sf_ocr.git

RUN pip3 install -r sf_ocr/requirements.txt 

WORKDIR /usr/src/app

RUN cp /tmp/sf_ocr/*.py /usr/src/app/
RUN cp /tmp/sf_ocr/config.yaml /usr/src/app/models


CMD ["uvicorn", "server:app", "--reload", "--host", "0.0.0.0", "--port", "9095", "--workers", "1"]
