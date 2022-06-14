
library(DBI)
library(tidyverse)

DB_PATH="Driver={SQLite3};database=/media/abhinav/Data/Economic_Census/ec6.sqlite"

con_ec6 <- dbConnect(odbc::odbc(), .connection_string = DB_PATH, 
                     timeout = 10)
#List of all tables
list_state_tables=as.data.frame(dbListTables(con_ec6))

#Create a empty data frame
district_ec_nic=data.frame()

#Fetch data for each district from NIC
for(i in 1:nrow(list_state_tables)){
  df_temp=tbl(con_ec6,list_state_tables[i,1])%>%
    select(1,2,11,24)%>%
    filter(SECTOR=="Urban")%>%
    group_by(District,ST,NIC3)%>%
    count()%>%
    collect()
  district_ec_nic=rbind(district_ec_nic,df_temp)
}

district_ec_ownership=data.frame()

for(i in 1:nrow(list_state_tables)){
  df_temp=tbl(con_ec6,list_state_tables[i,1])%>%
    select(1,2,13,24)%>%
    filter(SECTOR=="Urban")%>%
    group_by(District,OWN_SHIP_C)%>%
    count()%>%
    collect()
  district_ec_ownership=rbind(district_ec_ownership,df_temp)
}

#Merge district ec data with census code
district_nic_merged=district_ec_nic %>% merge(district_Code,by.x = c("District","ST"),by.y =c("DISTRICT_NAME","State_Name"),all.x=TRUE)
