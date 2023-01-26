list.of.packages <- c("data.table","ggplot2","scales","reshape2")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only=T)

agency_map = c(
  "XM-OCHA-CERF"="CERF",
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
  "XM-DAC-30010"="UNITAID",
  "XM-DAC-41140"="WFP",
  "XM-DAC-928"="WHO",
  "XI-IATI-UNPF"="UNPF",
  "41120"="UN-HABITAT",
  "XM-DAC-47066"="IOM",
  "XI-IATI-OCHASDC"="OCHASDC"
)

setwd("~/git/UNCEB-IATI-Analysis")
dat = fread("unceb_data.csv")
dat$year = year(dat$start_date)
dat$agency = agency_map[dat$reporting_org_ref]
dat$reporting_org_ref = NULL
dat_m = melt(dat, id.vars=c("iati_identifier", "agency", "start_date", "year"))

by_agency_m = data.table(dat_m)[,.(value=mean(value)),by=.(variable,agency)]
by_agency = dcast(by_agency_m, agency~variable)

by_year_m = data.table(dat_m)[,.(value=mean(value)),by=.(variable,year)]
by_year = dcast(by_year_m, variable~year)

# dat$start_month = as.Date(paste(dat$year, month(dat$start_date), "01", sep="-"))
count_by_agency = unique(dat[,c("iati_identifier","agency", "year")])
count_by_agency = data.table(count_by_agency)[,.(count=.N), by=.(agency, year)]
count_by_agency = subset(count_by_agency, year >= 2000)

fwrite(by_agency, "by_agency.csv")
fwrite(by_year, "by_year.csv")
fwrite(count_by_agency, "count_by_agency.csv")
