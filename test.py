from glob import glob
import pickle
import json
import subprocess
import time
import random
# import pytesseract


def curl_ocr(file_name):
    base_url = '127.0.0.1:9095/ocr'
    response = subprocess.check_output(['curl', '-s', '-F', 'file=@'+file_name, base_url])    
    return json.loads(response.decode("utf-8"))['id']

def curl_progress(id):
    base_url = '127.0.0.1:9095/progress/'
    response = subprocess.check_output(['curl', '-s', base_url + id])    
    return json.loads(response.decode("utf-8"))

def test_curl():
    
    num_files = 6
    # file_names = ['input/kTo84xXwdKk0qzkYnx8Ic09qWZELRS.pdf','input/256277.pdf']
    files = glob('input/*.pdf')
    file_names = random.choices(files,k=num_files)

    ids = []
    for file_name in file_names:
        id = curl_ocr(file_name)
        print(file_name,id)
        ids.append(id)
        time.sleep(random.randint(0,10)/3)

    errors = []
    finalized = []
    for x in range(300):
        if len(ids)==0:
            break
        
        id = random.choice(ids)
        
        time.sleep(random.randint(3,10))
        state = curl_progress(id)
        print(id,state)

        if 'detail' in state.keys():
            print(state['detail'])
            errors.append(id)
            ids.remove(id)
        elif state['page']==state['pages'] and state['pages']!=0:
            finalized.append(id)
            ids.remove(id)
    print('errors',errors)
    print('finalized',finalized)
        
test_curl()