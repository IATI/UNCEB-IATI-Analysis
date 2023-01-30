# UNCEB-IATI-Analysis

## Setup

First, register for an API key here: https://developer.iatistandard.org/

Next, create a `.env` file with the contents:

```
API_KEY=your-api-key-here
```

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