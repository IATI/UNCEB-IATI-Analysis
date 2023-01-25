import os
import requests
from dotenv import dotenv_values

config = dotenv_values(".env")
rows = 1000

un_publisher_refs = [
    'XM-OCHA-CERF', # CERF
    'XM-DAC-41301', # FAO
    'XM-DAC-41108', # IFAD
    'XM-DAC-41302', # ILO
    'XM-DAC-45001', # ITC
    'XM-DAC-41116', # UNEP
    'XM-DAC-41110', # UNAIDS
    'XM-DAC-41111', # UNCDF
    'XM-DAC-41149', # UNDCO
    'XM-DAC-41114', # UNDP
    'XM-DAC-41304', # UNESCO
    'XM-DAC-41119', # UNFPA
    'XM-DAC-41121', # UNHCR
    'XM-DAC-41122', # UNICEF
    'XM-DAC-41123', # UNIDO
    'XM-DAC-41127', # UNOCHA
    '41AAA', # UNOPS
    'XM-DAC-41130', # UNRWA
    'XM-DAC-41146', # UN-Women
    'XM-DAC-30010', # UNITAID
    'XM-DAC-41140', # WFP
    'XM-DAC-928', # WHO
    'XI-IATI-UNPF', # UNPF
    '41120', # UN-Habitat
]

base_url = 'https://api.iatistandard.org/datastore/activity/iati?q=(reporting_org_ref:"{}")&rows={}&start={}'

empty_response = '<?xml version="1.0" encoding="UTF-8"?><iati-activities generated-datetime="" version="2.03"/>\n'

for publisher in un_publisher_refs:
    print(publisher)
    publisher_path = os.path.join("data", publisher)
    os.makedirs(publisher_path)
    headers = {'Ocp-Apim-Subscription-Key': config['API_KEY']}
    page = 0
    response_code = 200
    response_text = ""
    while response_code == 200 and response_text != empty_response:
        api_query_url = base_url.format(publisher, rows, page * rows)
        response = requests.get(api_query_url, headers=headers)
        response_code = response.status_code
        if response_code != 200:
            print(response_code)
            break
        response_text = response.text
        if response_text != empty_response:
            with open(os.path.join(publisher_path, '{}.xml'.format(page)), 'w') as xml_file:
                xml_file.write(response_text)
        page += 1
