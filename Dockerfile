FROM python:3.12.3-bullseye
#FROM tiangolo/uvicorn-gunicorn-fastapi:python3.12.3

# EXPOSE 9085
#RUN apk add apt-get

RUN apt-get update -y && apt-get install -y python3-pip python3-dev build-essential libgl1-mesa-dev curl autoconf libtool libleptonica-dev

#tesseract-ocr-rus #libsqlite3-dev

#ARG TESSERACT_VERSION=5.0.0-beta-20210916
ARG TESSERACT_VERSION=5.5.0

# tesseract 5.0
RUN wget --no-check-certificate https://github.com/tesseract-ocr/tesseract/archive/refs/tags/${TESSERACT_VERSION}.zip
RUN unzip ${TESSERACT_VERSION}.zip

RUN cd tesseract-${TESSERACT_VERSION} && \
    autoreconf --install && \
    ./configure && \
    make && \
    make install && \
    ldconfig

RUN wget --no-check-certificate https://github.com/tesseract-ocr/tessdata/blob/main/rus.traineddata?raw=true -O /usr/local/share/tessdata/rus.traineddata
RUN wget --no-check-certificate https://github.com/tesseract-ocr/tessdata/blob/main/eng.traineddata?raw=true -O /usr/local/share/tessdata/eng.traineddata


RUN python -m pip install --upgrade pip

# fix pytesseract
#RUN pip3 install Pillow
#RUN pip3 install --upgrade Pillow

RUN pip3 install gdown
RUN pip install uv


WORKDIR /usr/src/app

RUN mkdir /usr/src/app/output
RUN mkdir /usr/src/app/models
VOLUME ["/usr/src/app/output"]

RUN gdown --id 1-Q5BGBKs53ZsZZXgzTnNVxKq78ScZa20 -O models/type.pkl --no-check-certificate \
    && gdown --id 1-PlVu3-wGVVIiBb2fcEpHzr-SLLSrw-x -O models/orient.pkl --no-check-certificate

WORKDIR /tmp

ARG SF_OCR_VERSION=unknown
RUN SF_OCR_VERSION=${SF_OCR_VERSION} git -c http.sslverify=false clone https://github.com/brs1977/sf_ocr.git

RUN cp /tmp/sf_ocr/*.py /usr/src/app/
RUN cp /tmp/sf_ocr/config.yaml /usr/src/app/models
RUN cp /tmp/sf_ocr/requirements.lock /usr/src/app/
RUN cp /tmp/sf_ocr/pyproject.toml /usr/src/app/
RUN cp /tmp/sf_ocr/README.md /usr/src/app/

WORKDIR /usr/src/app

RUN uv pip install --no-cache --system -r requirements.lock

CMD ["uvicorn", "server:app", "--reload", "--host", "0.0.0.0", "--port", "9075", "--workers", "1"]
