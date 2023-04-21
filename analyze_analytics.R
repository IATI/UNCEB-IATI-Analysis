list.of.packages <- c("data.table","ggplot2","scales","reshape2","anytime")
new.packages <- list.of.packages[!(list.of.packages %in% installed.packages()[,"Package"])]
if(length(new.packages)) install.packages(new.packages)
lapply(list.of.packages, require, character.only=T)

setwd("~/git/UNCEB-IATI-Analysis/analytics")

di_style = theme_bw() +
  theme(
    panel.border = element_blank()
    ,panel.grid.major.x = element_blank()
    ,panel.grid.minor.x = element_blank()
    ,panel.grid.major.y = element_line(colour = greys[2])
    ,panel.grid.minor.y = element_blank()
    ,panel.background = element_blank()
    ,plot.background = element_blank()
    ,axis.line.x = element_line(colour = "black")
    ,axis.line.y = element_blank()
    ,axis.ticks = element_blank()
    ,legend.position = "bottom"
  )

rotate_x_text_45 = theme(
  axis.text.x = element_text(angle = 45, vjust = 1, hjust=1)
)
rotate_x_text_90 = theme(
  axis.text.x = element_text(angle = 90, vjust = 0.5, hjust=1)
)
format.big.mark = function(x){
  return(format(x, big.mark=",", scientific=F))
}
date_dat = fread("apim_export_date_20230120_20230420.csv")
date_dat$Date = anydate(date_dat$`timestamp [UTC]`)
date_dat$category = "Datastore API"
date_dat$category[which(date_dat$DatastoreSearch)] = "Datastore Search"

p = ggplot(date_dat, aes(x=Date, y=Count, group=category, fill=category)) +
  geom_area(stat="identity") +
  scale_y_continuous(labels=format.big.mark, expand = c(0, 0)) +
  scale_x_date(date_labels="%d %b %Y", date_breaks="3 weeks") +
  di_style +
  rotate_x_text_45 +
  labs(x="", y="Requests", fill="", title="IATI Datastore requests per week for UN agency data")
p
ggsave(filename="graphics/datastore_over_time.png", plot=p, width=10, height=5)

agency_dat = fread("apim_export_20230120_20230420.csv")
agency_dat_l = melt(agency_dat, id.vars=c("DatastoreSearch", "Count"))
agency_dat_l = subset(agency_dat_l, value)
agency_dat_agg = data.table(agency_dat_l)[,.(Count=sum(Count)),by=.(DatastoreSearch,variable)]
setnames(agency_dat_agg,"variable","Agency")
agency_dat_agg$category = "Datastore API"
agency_dat_agg$category[which(agency_dat_agg$DatastoreSearch)] = "Datastore Search"
agency_dat_agg_agg = agency_dat_agg[,.(Count=sum(Count)),by=.(Agency)]
agency_dat_agg_agg = agency_dat_agg_agg[order(-agency_dat_agg_agg$Count),]
agency_dat_agg$Agency = factor(agency_dat_agg$Agency, levels=unique(agency_dat_agg_agg$Agency))

p2 = ggplot(agency_dat_agg, aes(x=Agency, y=Count, group=category, fill=category)) +
  geom_bar(stat="identity") +
  scale_y_continuous(labels=format.big.mark, expand = c(0, 0)) +
  di_style +
  rotate_x_text_45 +
  labs(x="", y="Requests", fill="", title="IATI Datastore requests for UN agency data\n20 Jan 2023 - 20 Apr 2023")
p2
ggsave(filename="graphics/datastore_by_agency.png", plot=p2, width=10, height=5)

dportal_dat = fread("dportal_countries_20230120_20230420.csv")
dportal_agg = dportal_dat[,.(Count=sum(visitors)),by=.(name)]
nrow(dportal_agg)
sum(dportal_agg$Count)
dportal_agg = subset(dportal_agg, Count>=10)
dportal_agg = dportal_agg[order(-dportal_agg$Count)]
dportal_agg$name = factor(dportal_agg$name, levels=dportal_agg$name)

p3 = ggplot(dportal_agg, aes(x=name, y=Count)) +
  geom_bar(stat="identity", fill="#3a6475") +
  scale_y_continuous(labels=format.big.mark, expand = c(0, 0)) +
  di_style +
  rotate_x_text_45 +
  labs(x="", y="Visitors", fill="", title="D-Portal visitors to UN agency pages by country\n20 Jan 2023 - 20 Apr 2023")
p3
ggsave(filename="graphics/dportal_by_country.png", plot=p3, width=10, height=5)
