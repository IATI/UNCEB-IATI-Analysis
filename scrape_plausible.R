list.of.packages <- c("data.table","ggplot2","scales","reshape2","httr","jsonlite")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only=T)

agency_map = c(
  "XM-DAC-41301"="FAO",
  "XM-DAC-41108"="IFAD",
  "XM-DAC-41302"="ILO",
  "XM-DAC-45001"="ITC",
  "XM-DAC-41116"="UNEP",
  "XM-DAC-41110"="UNAIDS",
  "XM-DAC-41111"="UNCDF",
  "XM-DAC-41149"="UNDCO",
  "XM-DAC-41114"="UNDP",
  "XM-DAC-41304"="UNESCO",
  "XM-DAC-41119"="UNFPA",
  "XM-DAC-41121"="UNHCR",
  "XM-DAC-41122"="UNICEF",
  "XM-DAC-41123"="UNIDO",
  "XM-DAC-41127"="UNOCHA",
  "41AAA"="UNOPS",
  "XM-DAC-41130"="UNRWA",
  "XM-DAC-41146"="UN-WOMEN",
  "XM-DAC-41140"="WFP",
  "XM-DAC-928"="WHO",
  "41120"="UN-HABITAT",
  "XM-DAC-47066"="IOM",
  "XI-IATI-OCHASDC"="OCHASDC"
)

setwd("~/git/UNCEB-IATI-Analysis")

agency_refs = names(agency_map)
page_types = c("reporting_ref", "publisher", "aid")
analytics_list = list()
analytics_index = 1
for(agency_ref in agency_refs){
  for(page_type in page_types){
    Sys.sleep(2)
    message(agency_ref, " ", page_type)
    scrape_url = paste0(
      "https://plausible.io/api/stats/d-portal.org/countries?period=custom&date=2023-04-21&from=2023-01-20&to=2023-04-20&filters=%7B%22page%22%3A%22%2Fctrack.html%23",
      page_type,
      "%3D",
      agency_ref,
      "*%22%7D&with_imported=true&limit=999"
    )
    res = GET(scrape_url)
    json_dat = content(res, as="text")
    parsed_json_dat = fromJSON(json_dat)
    if(length(parsed_json_dat) > 0){
      parsed_json_dat$agency = agency_map[agency_ref]
      analytics_list[[analytics_index]] = parsed_json_dat
      analytics_index = analytics_index + 1
    }
  }
}

analytics_dat = rbindlist(analytics_list)
fwrite(analytics_dat, "analytics/dportal_countries_20230120_20230420.csv")
