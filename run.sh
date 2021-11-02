
app="sf_ocr"

docker run -d -p 9095:9095 --name ${app} --rm -v /home/rttec/projects/sf_ocr_server/output/:/usr/src/app/output ${app} 