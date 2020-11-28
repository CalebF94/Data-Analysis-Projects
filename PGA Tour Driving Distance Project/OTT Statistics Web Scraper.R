################################################################################
#                                                                              #
# This program will scrape data from the PGA Tour website. It will also clean  #
# some of the data and convert to proper data types. Each statistic will be    #
# saved to its own table. The tables will later be merged in MYSQL.            #
#                                                                              #
################################################################################

library(rvest)
library(dplyr)
library(tidyr)
library(stringr)

#statistic IDs and labels for stats to be scraped
scrape_stats = c("02401","02402","02404","02405",
                 "02406", "02407","02408","02409")
scrape_names = c( "ClubheadSpeed", "BallSpeed", "LaunchAngle", 
                 "SpinRate","ApexDistance", "ApexHeight", "HangTime", "CarryDistance")  



#Function to read "Off The Tee" Statistics
pga_scraper=function(stat, year1, year2, statLab="StatAvg"){
  #stat:  numeric identifyer of statistic used by PGA Tour website
  #year1: year of statistic to scrape strart
  #year2: year of statistic to scrape end
  
  #ensuring proper years
  if(year1>year2){return("year2 should be >= year1")}
  
  base_url="https://www.pgatour.com/content/pgatour/stats/stat."
  table=data.frame()
  
  
  for(y in year1:year2){
      scrape_url=paste(base_url,stat,".y",y,".html", sep="")
      
      url=read_html(scrape_url)
      #getting stats table and selecting appropriate columns
       newtable=url %>%
         html_nodes("table") %>%
         html_table()%>%
         .[[2]] %>%
         transmute(
           `Year`= y,
           `PLAYER NAME`,
           `ROUNDS`,
           `AVG.`,
           `TOTAL ATTEMPTS`
         ) %>%
         unite(col = "PlayerYear", c(2,1),remove = FALSE,sep = "") %>%
         mutate(PlayerYear=str_replace_all(`PlayerYear`,pattern = " ",""))%>%
        #Two Richards Johnson, so I removed them. Caused issued with unique identifyer.
         filter(`PLAYER NAME`!="Richard Johnson")
         
       
       #combining years
       table=bind_rows(table,newtable)
       
  }
  
 
  
   #Renameing columns
   names(table)=c("PlayerYear", "Year","Player", "Rounds", statLab, "Attempts")
  return(table)
}


#list that will store tables
tables=vector(mode="list", length = length(scrape_stats))

#Using pga_scraper to get data
for(i in 1:length(scrape_stats)){
  
  tables[[i]]=pga_scraper(scrape_stats[i], year1=2007, year2=2019, statLab=scrape_names[i])
}


#Converting Apex height(ft' in") into double
tables[[6]] = tables[[6]] %>%
  mutate(
    ApexHeight= str_replace_all(ApexHeight,pattern = "'",replacement = ""),
    ApexHeight= str_replace_all(ApexHeight,pattern = "\"",replacement = ""))%>%
  separate(ApexHeight,into = c("feet","inches"), sep = " ") %>%
  mutate(ApexHeight = round(as.numeric(feet)+as.numeric(inches)/12,2)) %>%
  select(PlayerYear, Year, Player,Rounds, ApexHeight,Attempts)
  

#converting spin rate to numeric
tables[[4]] = tables[[4]] %>%
  mutate(
    SpinRate=as.numeric(str_replace_all(SpinRate,pattern = ",",replacement = "")))
  



names(tables)=scrape_names
attach(tables)


##writing to csv. name of file is "statistic label.csv"
for(name in names(tables)){
  
  write.csv(
    tables[[name]],
    file = paste("C:\\FileOutputLocation\\",name,".csv", sep = ""),
    row.names = FALSE, fileEncoding = "UTF8")
  
}






