# Author: Caleb Fornshell
# Description: A script to scape the Wheel of Fortune bonus puzzle information.
#   Puzzle information taken from 
#   https://www.angelfire.com/mi4/malldirectories/wheel/year/month.html
#
#   Generating dataset with 9 variables:
#         DATE: Date puzzle aired on TV
#         CATEGORY: Puzzle Category
#         PUZZLE: Soluntion to puzzle
#         L1: Consonents selected by contestant
#         L4: Vowel selected by contestant
#         L5: fourth consonent selected by contestant if s/he had wild card
#         WIN: Did the contestant win? YES/NO


require(htmltab)
require(tidyverse)
require(lubridate)


#function that will check if a url is valid
valid_url <- function(url_in,t=2){
  con <- url(url_in)
  check <- suppressWarnings(try(open.connection(con,open="rt",timeout=t),silent=T)[1])
  suppressWarnings(try(close.connection(con),silent=T))
  ifelse(is.null(check),TRUE,FALSE)
}

#months and years in data set
m=tolower(month.name)
y=c(2007:2015)

#constructing urls
my = unite(merge(y,m, all=TRUE), my, sep = "/")
base = "https://www.angelfire.com/mi4/malldirectories/wheel/"

urls = 
  data.frame(a = rep(base, dim(my)[1]),
             b = my,
             c = rep(".html", dim(my)[1])) %>%
  unite(urls, sep="") 
 

#creating data frame with no rows but established column names
cnames=c("DATE", "CATEGORY", "PUZZLE", "L1" ,"L2" ,"L3" ,"L4" ,"L5", "WIN")
puzzles = setNames(data.frame(matrix(nrow=0, ncol=9)),nm = cnames)


#looping through all urls and getting data
for(u in urls[,1]){
  
  #if valid url -> get data
  if(valid_url(u)){
    
  # will produce warnings, can ignore
  puzzle1 = htmltab(u, rm_nodata_cols = FALSE) %>%
    select(c(1:4,6))%>% 
    filter(DATE != "") %>%
    mutate(DATE = dmy(DATE)) %>%
    #separating letter choices into individual columns
    separate(col = LETTERS, into = c("L1","L2","L3","L4","L5"), sep=" ")
    
  #merging new puzzles to dataset
  puzzles = rbind(puzzles, puzzle1)
  
  }else print(u) #printing url that aren't valid. Not important, just curious
}


#writing csv with final data
write.csv(puzzles, 
          file = "C:\\Users\\Caleb\\Desktop\\jobs\\Projects\\Wheel of Fortune\\BonusPuzzles.csv",
          fileEncoding = "UTF-8", row.names = FALSE)
