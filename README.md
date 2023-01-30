# UNCEB-IATI-Analysis

## Installation
```
python3 -m virtualenv venv
source venv/bin/activate
pip3 install -r requirements.txt
```

## Use
```
source venv/bin/activate
mkdir data
python3 download.py
python3 parse.py
Rscript interpret_and_chart.R
```