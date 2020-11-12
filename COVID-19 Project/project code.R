
# Filename: E:\...\project code.R
# Author: Caleb Fornshell
# Date: 3/31/2020
# 
# 
# This file is to be run RStudio cloud, because I had issues with some latex packages on my
# personal laptop. This document contains my code that creates all my graphs and performs
# my analysis. The results of this code are saved and then called in "Covid19_project.RMD"
# which will generate the final written report. 
#
# Some commands are blocked out because I don't want this file images to someones computer
# without their knowledge, or because I decided to not include the results in the final report.
# EX) ggsave() commands are commented out because they save an image






# Data is obtained from from two sources:
# Korea: https://www.kaggle.com/kimjihoo/coronavirusdataset#Case.csv
# 
# India: https://www.kaggle.com/sudalairajkumar/covid19-in-india#IndividualDetails.csv
# 
# Florida: From FloridaDisasters.org
# 
# Named Datasets:
#   korea: raw data from kaggle
# india: raw data from indian google sheet
# florida: raw data based on daily reports from FL Dept of Health, 
# compiled by floridadisasters.org
# 
# korea2: cleaned korean dataset
# india2: cleaned indian dataset
# florida2: cleaned florida dataset
# combined: combined the above three datasets. Contains only variables of interest. 
#           In a form to be easy to use with ggplot.
# 
# 


#installing needed packages if missing
frequire <- function(x){
  for( i in x ){
    #  require returns TRUE invisibly if it was able to load package
    if( ! require( i , character.only = TRUE ) ){
      #  If package was not able to be loaded then re-install
      install.packages( i , dependencies = TRUE )
      #  Load package after installing
      require( i , character.only = TRUE )
    }
  }
}

#  Then try/install packages...
frequire( c("tidyverse","lubridate" , "survival","survminer","ggfortify", "gtable","muhaz", 
            "grid","gridExtra","gmodels","xtable","summarytools", "ggpubr") )
options(xtable.timestamp="")
options(xtable.comments=FALSE)
st_options(headings = FALSE)




#read in data 
#provided in data folder
korea=as_tibble(read.csv("patient_korea.csv"))
india=as_tibble(read.csv("patient_india.csv"))
florida=as_tibble(read.csv("patient_florida.csv"))





#   The next block of code is cleaning the Korean dataset. 
# I am converting types of variables to more convenient types. 
# 
# I created a survival time variable (s.time) based on each patients 
# date of diagnosis and the their status at the end of the study period and the date of 
# which their status changed. The last three cases for s.time are censored observations.
# 
# I also create a variable called end.status. 1 if event occurred in time period, 0 otherwise.
# 
# Only looking at cases that are confirmed in the appropriate time frame.
# For a 35 day(5 week) study will look at Feb 20th - March 26th. This timeframe starts 
# just prior to the large increase in cases.


k.start=mdy("2/20/2020") #starting just before big rise in cases
k.end=k.start + 35 #five week study period

#levels for age factors used in EDA and survival analysis
levels=c("0s","10s","20s","30s","40s","50s","60s","70s","80s","90s","100s")
levels2=c("<20","20s","30s","40s","50s","60s",">70")

korea2=korea %>%
  #keeping and converting useful variables
  transmute(
            patient_id, global_num, birth_year, country, province,city,
            sex=as.character(sex), 
            age=as.character(age),#used in EDA
            age.group=as.character(case_when(#used in surv analysis
                  age %in% c("0s","10s") ~ "<20",
                  age %in% c("70s","80s","90s", "100s") ~ ">70",
                  TRUE ~ as.character(age))),
            Age=2020-birth_year,#numeric age, used in Cox regression
            disease=if_else(is.na(disease), 0,1),
            infection_case,
            infection_order,
            symptom_onset_date=mdy(symptom_onset_date),
            confirmed_date=mdy(confirmed_date),
            released_date=mdy(released_date),
            deceased_date=mdy(deceased_date),
            state) %>%
  
  #filtering observations to keep observations that occur in study period
  filter(sex %in% c("male","female"),
         confirmed_date>=k.start & confirmed_date<=k.end) %>%
  
  #creating the s.time variable and the censor indicator variable
  mutate(
    #indicates state at end of study
    end.state=case_when(
      (deceased_date>k.end) ~ "Isolated",
      (deceased_date <= k.end) ~ "Deceased",
      (state=="isolated") ~ "Isolated",
      ((state=="released") & (released_date>k.end)) ~ "Isolated",
      ((state=="released") & (released_date<=k.end)) ~"Released",
      ((state=="released") & (is.na(released_date)))~ "Released"),
    
    #calculating s.time based on end.state
    s.time=case_when(
      (confirmed_date==deceased_date)~.5,
      (confirmed_date==k.end) & (end.state!="Deceased") ~ 1,#avoiding s.time=0
      end.state=="Deceased" ~ as.numeric(deceased_date-confirmed_date),
      end.state=="Isolated" ~ as.numeric(k.end-confirmed_date),
      end.state=="Released" ~ as.numeric(released_date-confirmed_date))) %>%
  
  #Indicator variable indicating whether an observation is censored; 0=censor
  mutate(end.status=if_else(end.state=="Deceased",1,0)) %>%
  
  #some deaths didn't have a death date so survival time not computed==>remove
filter(!is.na(s.time),
       s.time>0,
       age!="") %>%
  arrange(age)%>%
  mutate(id=row_number())

#one age was 66. Assuming they meant 60s
korea2$age[korea2$age=="66s"]="60s"
korea2$age.group[korea2$age.group=="66s"]="60s"




# The next chunk I am cleaning my India data. Pretty similar to the chunk above.
# survival times were based on the difference between diagnosed_date and the date 
# either death, recovery, or end of study. This was determined by the current status
# variable and the status_change_date.

i.start=mdy("2/29/2020")
i.end=i.start+35

india2 = india%>%
  transmute(
    age=as.numeric(as.character(age)),
    gender=as.character(gender),
    detected_district=as.character(detected_district),
    detected_state=as.character(detected_state),
    nationality=as.character(nationality),
    diagnosed_date=dmy(diagnosed_date),
    current_status,
    status_change=dmy(status_change_date),
    Age=age,#numeric age, used in Cox regression
    age=case_when(#used in my EDA
      age<10~"0s",
      age<20~"10s",
      age<30~"20s",
      age<40~"30s",
      age<50~"40s",
      age<60~"50s",
      age<70~"60s",
      age<80~"70s",
      age<90~"80s",
      age<100~"90s",
      TRUE~"100s"),
    age.group=case_when(#used in survival analysis
      Age<20~"<20",
      Age<30~"20s",
      Age<40~"30s",
      Age<50~"40s",
      Age<60~"50s",
      Age<70~"60s",
      TRUE~">70"),
    #factor(age, levels = levels)
    ) %>%
  
  filter(diagnosed_date>=i.start & diagnosed_date<=i.end)%>%
  
  mutate(
    end.state=case_when(
       current_status=="Recovered" & status_change<=i.end ~ "Recovered",
       current_status=="Recovered" & status_change> i.end ~ "Hospitalized",
       current_status=="Deceased"  & status_change<=i.end ~ "Deceased",
       current_status=="Deceased"  & status_change >i.end ~ "Hospitalized",
       TRUE ~ "Hospitalized"),
    s.time=case_when(
      end.state=="Hospitalized" ~ as.numeric(i.end-diagnosed_date),
      end.state=="Recovered" ~ as.numeric(status_change - diagnosed_date),
      end.state=="Deceased" ~ as.numeric(status_change-diagnosed_date)),
    
    #avoiding s.time=0
    s.time=case_when(
      (s.time==0) & (end.state!="Deceased")~1,
      (s.time==0) & (end.state=="Deceased")~.5,
      TRUE~s.time),
    
    end.status=if_else(end.state=="Deceased",1,0)) %>%
  
  filter(gender %in% c("M","F"),
         !is.na(Age)) %>%
  arrange(Age)%>%
  mutate( id=row_number(),# don't want 0 based id
gender=if_else(gender=="M","male","female")) 



#Next chunk is for cleaning the florida data. Pretty similar to above chunks
#except don't have recovery information so all s.times are from either diagnosis
# to death, or from diagnosis to end of study for censored observations

f.end=mdy("4/17/2020")
f.start=f.end-35 #five week study period

country=rep("Florida", dim(florida)[1])#24802 obs
florida2=as_tibble(cbind(country, florida)) %>%
  transmute(
    Death,
    "country"=as.character(country),
    Age,#numeric age, used in Cox Regression
    age=case_when(#used in EDA
      between(Age,0,9)   ~ "0s",
      between(Age,10,19) ~ "10s",
      between(Age,20,29) ~ "20s",
      between(Age,30,39) ~ "30s",
      between(Age,40,49) ~ "40s",
      between(Age,50,59) ~ "50s",
      between(Age,60,69) ~ "60s",
      between(Age,70,79) ~ "70s",
      between(Age,80,89) ~ "80s",
      between(Age,90,99) ~ "90s",
      between(Age,100,120)~"100s"),
    age.group=case_when(#used in surv analysis
      between(Age,0,19)   ~ "<20",
      between(Age,20,29) ~ "20s",
      between(Age,30,39) ~ "30s",
      between(Age,40,49) ~ "40s",
      between(Age,50,59) ~ "50s",
      between(Age,60,69) ~ "60s",
      between(Age,70,120) ~ ">70"),
    #factor(age, levels = levels),
    sex=tolower(as.character(Gender)),
    "confirmed_date"=mdy(Date.case),
    died=if_else(Died==1,1,0,0),
    end.state=if_else(died==1,"Dead","Alive"),
    deceased_date=mdy(Death.Date))

#setting death date to NA for censored patients
florida2$deceased_date[florida2$died==0]=NA

florida2=florida2 %>%
  mutate(
    #calulating survival times
    s.time=case_when(
      died==1 ~ as.numeric(deceased_date-confirmed_date),
      died==0 ~ as.numeric(f.end-confirmed_date),
      TRUE ~ -100)) %>%
  mutate(
    #avoiding s.times of 0
    s.time=case_when(
      died==1 & (confirmed_date==deceased_date) ~ .5,
      died==0 & (confirmed_date==f.end) ~ 1,
      TRUE ~ s.time
    )
  )%>%
  #subsetting, and removing obs without suffient data for s.time 
  filter(
    confirmed_date>=f.start,
    s.time>=0,
    sex %in% c("male","female"),
    !is.na(age)
    #removed 248 cases
  )%>%
  #makes for better visual
  arrange(Age)%>%
  mutate(id=row_number(),
         end.state=if_else(died==1,"Dead","Alive"))


#################################
#Visualization for Korean Sample#
#################################
k.viz=ggplot(data=korea2[2184:2199,], aes(y=id)) + 
  #adding black dots
  geom_point(aes(x=confirmed_date)) +
  #adding lines 
  geom_segment(aes(x=confirmed_date, 
                   y=id, 
                   xend=confirmed_date+s.time, 
                   yend=id)) +
  #adding x and o
  geom_point(aes(x=confirmed_date+s.time, 
                 shape=as.factor(end.status), 
                 color=end.state,
                 stroke=2) ) +
  #printing s.time next to x and o
  geom_text(aes(x=confirmed_date+s.time +2, y=id, 
                label=s.time), size=6)+
  #Cleaning up labels, legends, and titles
  guides(shape=FALSE) +
  scale_shape_manual(values = c(1,4)) +
  scale_x_date(name = "Date", 
               breaks=seq(k.start,k.end, length.out = 5), 
               minor_breaks = "1 day") +
  scale_y_continuous(breaks=c(1834:1847)) +
  theme(plot.caption = element_text(hjust=0, size=18),
        axis.text = element_text(size=16),
        legend.position = "top",
        legend.text = element_text(size=16),
        legend.title = element_blank())

#saving plot. Will call saved plot in RMD file
#ggsave(filename = "k_viz.png", plot = k.viz, width = 15, height = 5.5)  



#################################
#Visualization for Indian Sample#
#################################
i.viz=ggplot(data=india2[805:819,], aes(y=id)) + 
  #adding black dots
  geom_point(aes(x=diagnosed_date)) +
  #adding lines 
  geom_segment(aes(x=diagnosed_date, 
                   y=id, 
                   xend=diagnosed_date+s.time, 
                   yend=id)) +
  #adding x and o
  geom_point(aes(x=diagnosed_date+s.time, 
                 shape=as.factor(end.status), 
                 color=end.state,
                 stroke=2) ) +
  #printing s.time next to x and o
  geom_text(aes(x=diagnosed_date+s.time +2, y=id, 
                label=s.time), size=6)+
  #Cleaning up labels, legends and titles
  guides(shape=FALSE) +
  scale_shape_manual(values = c(1,4)) +
  scale_x_date(name="Date")+
  #scale_y_continuous(breaks=seq(20,36, length.out = 13))+
  theme(plot.caption = element_text(hjust=0, size=18),
        axis.text = element_text(size=16),
        legend.position = "top",
        legend.text = element_text(size=16),
        legend.title = element_blank())
#ggsave(filename = "i_viz.png", plot = i.viz, width = 15, height = 5.5)  


#################################
#Visualization for Korean Sample#
#################################
f.viz=ggplot(data=florida2[21443:21458,], aes(y=id)) + 
  #adding black dots
  geom_point(aes(x=confirmed_date)) +
  #adding lines 
  geom_segment(aes(x=confirmed_date, 
                   y=id, 
                   xend=confirmed_date+s.time, 
                   yend=id)) +
  #adding x and o
  geom_point(aes(x=confirmed_date+s.time, 
                 shape=as.factor(end.state), 
                 color=as.factor(end.state),
                 stroke=2) ) +
  #printing s.time next to x and o
  geom_text(aes(x=confirmed_date+s.time +2, y=id, 
                label=s.time), size=6)+
  #Cleaning up labels, legends, and titles
  guides(shape=FALSE) +
  scale_shape_manual(values = c(1,4)) +
  scale_color_manual(values = c("#00BFC4","#F8766D"))+
  scale_x_date(name="Date", 
               breaks=seq(f.start,f.end, length.out = 5), 
               minor_breaks = "1 day") +
  scale_y_continuous(breaks=seq(21443,21458,by=3))+
  theme(plot.caption = element_text(hjust=0, size=18),
        axis.text = element_text(size=16),
        legend.position = "top",
        legend.text = element_text(size=16),
        legend.title = element_blank())

#ggsave(filename = "f_viz.png", plot = f.viz, width = 15, height = 5.5)   


#combining data sets on similar columns
combined=as_tibble(data.frame(
  country=c(rep("Korea", dim(korea2)[1]),
            rep("India",dim(india2)[1]), 
            florida2$country),
  age=c(korea2$age,india2$age, florida2$age),
  age.group=c(korea2$age.group, india2$age.group, florida2$age.group),
  Age=c(korea2$Age,india2$Age, florida2$Age),
  sex=c(korea2$sex, india2$gender, florida2$sex),
  confirmed_date=c(korea2$confirmed_date, 
                   india2$diagnosed_date, 
                   florida2$confirmed_date),
  s.time=c(korea2$s.time, india2$s.time, florida2$s.time),
  end.state=c(korea2$end.state, india2$end.state, florida2$end.state),
  end.status=as.numeric(c(as.character(korea2$end.status), 
                          as.character(india2$end.status),
                          as.character(florida2$died)))))


#barplot for sex (Appendix Figure 4)
sex=ggplot(data=combined, aes(x=country, fill=sex)) + 
  geom_bar(position="dodge") +
  xlab("")+
  facet_wrap(vars(country), scales="free")+
  geom_text(stat='count', aes(label=..count..), 
            vjust=-.1, position =position_dodge(width=.8))+
  theme(plot.caption = element_text(hjust=0, size=12),
        text = element_text(size=14),
        legend.position = "right")
#sex
#ggsave(filename = "sex.pdf", plot = sex, height = 5, width=10)  


#cross tabulation tables for gender and end.state
#print(ctable(korea2$sex, korea2$end.state, justify = "c",
#              caption="Korea Sex by End Status"), method="pandoc")
# print(ctable(india2$gender, india2$end.state, justify = "c",
#              caption="India Sex by End Status"), method="pandoc")
# print(ctable(florida2$sex, florida2$end.state, justify = "c",
#              caption="Florida Sex by End Status"), method="pandoc")




#barplot for agegroups
age=ggplot(data=combined, aes(x=factor(age,levels = levels) ,fill=country)) + 
  geom_bar(position="dodge") +
  facet_wrap(vars(country), scales="free", ncol=1)+
  labs(x="")+
  #geom_text(stat='count', aes(label=..count..),
  #          vjust=-.1, position=position_dodge(width=.8))+
  theme(axis.text =element_text(size=16),
        strip.text = element_text(size=16))+
  guides(fill=FALSE)
#age
#ggsave(filename = "Age.png", plot = age, height=10, width=15) 


# print(ctable(x=florida2$age, y=florida2$end.state, justify = "c",
#              caption="Florida Age by End Status"), method="pandoc")
# 
# print(ctable(x = korea2$age, y=korea2$end.state, justify = "c",
#              caption="Korea Age by End Status"), method="pandoc")
# 
# print(ctable(x=india2$age, y=india2$end.state, justify = "c",
#              caption="India Age by End Status"), method="pandoc")
# 


#barplot for confirmed cases per day
case=ggplot(data=combined%>%group_by(country, confirmed_date))+
  geom_bar(aes(x=confirmed_date, fill=country), show.legend = FALSE) +
  facet_wrap(vars(country), ncol=1, scales="free_y")+
  xlab("Date") + 
  scale_x_date(breaks = seq(from=k.start, to=f.end, length.out=6)) +
  theme(plot.caption = element_text(hjust=0, size=12),
        strip.text.x = element_text(size=12),
        axis.text.x = element_text(size=12),
        axis.text.y=element_text(size=12))
#case
#ggsave(filename = "casesbydate.png", plot = case) 


#barplot of the state of each patient at the end of the study
end=ggplot(data=combined, aes(x=end.state,fill=country))+
  geom_bar(position="dodge", show.legend = FALSE) +
  facet_wrap(vars(country), scales="free")+
  geom_text(stat='count', aes(label=..count..), vjust=-.1, size=6,
            position=position_dodge(width=.8)) +
  xlab(" ")+
  theme(strip.text.x = element_text(size=14),
        text = element_text(size=18)) 
#end
#ggsave(filename = "endstate.png", plot = end, width=15) 


#histograms for the observered survival time

surv=ggplot(data=combined, aes(x=s.time, fill=country, )) + 
  geom_histogram(binwidth = 1, boundary=1) + 
  facet_wrap(vars(country), ncol=1, scales ="free") +
  theme(axis.text = element_text(size=16),
        strip.text = element_text(size=16))
#ggsave(filename = "surv.png", surv, width=15, height=10)

k.sum=round(c(mean=mean(korea2$s.time), median=median(korea2$s.time),
                mode=mean(korea2$s.time), sd=sd(korea2$s.time)),2)

i.sum=round(c(mean=mean(india2$s.time), median=median(india2$s.time),
                mode=mean(india2$s.time), sd=sd(india2$s.time)),2)

f.sum=round(c(mean=mean(florida2$s.time), median=median(florida2$s.time),
                  mode=mean(florida2$s.time), sd=sd(florida2$s.time)),2)
#surv

# print(descr(x = korea2$s.time, transpose = TRUE, stats =c("n.valid", "mean","med", "sd"),
#             caption="South Korea Survival Time Statistics"), method = "pander")
# 
# print(descr(x = india2$s.time, transpose = TRUE, stats = c("n.valid", "mean","med", "sd"),
#             caption="India Survival Time Statistics"), method = "pander")
# 
# print(descr(x = florida2$s.time, transpose = TRUE, stats =c("n.valid", "mean","med", "sd"),
#             caption="Florida Survival Time Statistics"), method = "pander")









# Survival analysis and code
# 
# First I am going to keep all countries combined and calculate overall survival and hazard functions. Then I am going to calculate survival and hazard functions for each variable(country, sex, age) while controlling for the other two variables. Then I will make a cox PH regression model using all of the variables in the model.

km=survfit(Surv(s.time, end.status)~1, data=combined)
smooth.haz=muhaz(combined$s.time, combined$end.status, bw.smooth=20, b.cor="left", max.time = 35)

haz=smooth.haz$haz.est
cut=smooth.haz$est.grid
h.surv=c(1,exp(-cumsum(haz[1:(length(haz)-1)]*diff(cut))))
haz.df=data.frame(haz, cut,h.surv)

survplot=autoplot(km, ylim = c(.9,1), surv.colour="red") + 
  labs(title = "Overall Survival Curve") +
  xlab("Time(in days)")+
  ylab("Survival Probability")+
  geom_line(data=haz.df, aes(x=cut, y=h.surv), inherit.aes = FALSE)+
  theme(plot.caption = element_text(hjust = 0, size=16),
        axis.text = element_text(size=14),
        axis.title = element_text(size=16))


hazplot=ggplot(data=haz.df, aes(x=cut, y=haz))+ geom_line() +
  labs(title="Overall Smoothed Hazard Function",
       caption="Figure 1: Overall Survival and Hazard Curve") +
  xlab("Time(in days)")+
  ylab("Hazard Rate") +
  theme(plot.caption = element_text(hjust = 0, size=20),
        axis.text = element_text(size=14),
        axis.title = element_text(size=16))


overall=ggarrange(survplot, hazplot, nrow =2) 
#ggsave(filename = "overall.pdf", plot=overall,width = 10, height = 8)


#making a data frame for each location using the muhaz function
smooth.haz.f=muhaz(florida2$s.time, florida2$died, bw.smooth=20, b.cor="left", max.time = 35)
haz.f=smooth.haz.f$haz.est
cut.f=smooth.haz.f$est.grid
h.surv.f=c(1,exp(-cumsum(haz.f[1:(length(haz.f)-1)]*diff(cut.f))))#based on muhaz hazard

smooth.haz.k=muhaz(korea2$s.time, korea2$end.status, bw.smooth=20, b.cor="left", max.time = 35,)
haz.k=smooth.haz.k$haz.est
cut.k=smooth.haz.k$est.grid
h.surv.k=c(1,exp(-cumsum(haz.k[1:(length(haz.k)-1)]*diff(cut.k))))#based on muhaz hazard

smooth.haz.i=muhaz(india2$s.time, india2$end.status, bw.smooth=20, b.cor="left", max.time = 35)
haz.i=smooth.haz.i$haz.est
cut.i=smooth.haz.i$est.grid
h.surv.i=c(1,exp(-cumsum(haz.i[1:(length(haz.i)-1)]*diff(cut.i))))#based on muhaz hazard

Loc=c("Florida", "Korea", "India")
haz.df=data.frame(Country=rep(Loc, each=101),
                  haz=c(haz.f, haz.k, haz.i),
                  cut=c(cut.f, cut.k, cut.i),
                  surv=c(h.surv.f, h.surv.k, h.surv.i))


#survival curves for each country. Solid line is surv curve based on muhaz hazard
km.curve=survfit(Surv(s.time, end.status)~country, data=combined)
survplot.c=autoplot(km.curve)+ 
  labs(title = "Survival Curves by Country")+
  xlab("Time(in days)")+
  ylab("Survival Probability") +
  geom_line(data=haz.df, aes(x=cut, y=surv, color=Country), inherit.aes = FALSE)+
  theme(text=element_text(size=12),
        axis.text = element_text(size=14) ,
        legend.text = element_text(size=14))


#hazard curves for each country
hazplot.c=ggplot(data=haz.df, aes(x=cut, y=haz, color=Country))+ 
  geom_line()+
  labs(title="Smoothed Hazard Curve by Country",
       caption="Figure 2:  Survival and Hazard Curve by Country",
       color="Country") +
  xlab("Time(in days)")+
  ylab("Hazard Rate") +
  theme(text=element_text(size=12),
        plot.caption = element_text(hjust = 0, size=20),
        axis.text = element_text(size=14),
        legend.text = element_text(size=14))


overall=ggarrange(survplot.c, hazplot.c, nrow =2) 
#ggsave(filename="countrySurv.pdf", plot=overall,width=10, height = 8)
survdiff(Surv(s.time, end.status)~country+strata(age.group, sex), data=combined)
pw.country=pairwise_survdiff(Surv(s.time, end.status)~country, data=combined)


male=combined[combined$sex=="male",]
female=combined[combined$sex=="female",] 

smooth.haz.M=muhaz(male$s.time, male$end.status, bw.smooth=20, b.cor="left", max.time=35)
haz.M=smooth.haz.M$haz.est
cut.M=smooth.haz.M$est.grid
h.surv.M=c(1,exp(-cumsum(haz.M[1:(length(haz.M)-1)]*diff(cut.M))))#based on muhaz hazard

smooth.haz.F=muhaz(female$s.time, female$end.status, bw.smooth=20, b.cor="left", max.time=35)
haz.F=smooth.haz.F$haz.est
cut.F=smooth.haz.F$est.grid
h.surv.F=c(1,exp(-cumsum(haz.F[1:(length(haz.F)-1)]*diff(cut.F))))#based on muhaz hazard

sex.df=data.frame(Sex=rep(c("male", "female"), each=101),
                  haz=c(haz.M, haz.F),
                  cut=c(cut.M, cut.F),
                  h.surv=c(h.surv.M, h.surv.F))

#survival curves for each Sex. Solid line is surv curve based on muhaz hazard
km.curve=survfit(Surv(s.time, end.status)~sex, data=combined)
survplot.sex=autoplot(km.curve)+ labs(title = "Survival Curves by Sex")+
  xlab("Time(in days)")+
  ylab("Survival Probability") +
  geom_line(data=sex.df, aes(x=cut, y=h.surv, color=Sex), inherit.aes = FALSE)+
  theme(text=element_text(size=16),
        axis.text = element_text(size = 14),
        axis.text.y = element_text(size = 14),
        axis.text.x = element_text(size = 14),
        legend.text = element_text(size=14))


#hazard curves for each sex
hazplot.sex=ggplot(data=sex.df, aes(x=cut, y=haz, color=Sex))+ 
  geom_line()+
  labs(title="Overall Smoothed Hazard Function",
       caption="Figure 3: Survival and Hazard Curves by Sex") +
  xlab("Time(in days)") +
  ylab("Hazard Rate") +
  theme(text = element_text(size=16),
        plot.caption = element_text(hjust = 0, size=20),
        axis.text.x = element_text(size = 14),
        axis.text.y = element_text(size = 14),
        legend.text = element_text(size=14))


(overall.sex=ggarrange(survplot.sex, hazplot.sex, nrow =2)) 
#ggsave(filename = "sexSurv.pdf", plot=overall.sex, width = 10, height = 8)
survdiff(Surv(s.time, end.status)~sex+strata(age.group, country), data=combined)
pairwise_survdiff(Surv(s.time, end.status)~sex, data=combined)





#making data frame for plotting s function based on hazard function
age.df=data.frame(age=numeric(), haz=numeric(), cut=numeric(), surv=numeric())
for(i in levels2[-1]){
  dat=combined[combined$age.group==i,bw.smooth=20, b.cor="left", max.time=35]
  smooths=muhaz(dat$s.time, dat$end.status)
  haz=smooths$haz.est
  cut=smooths$est.grid
  surv=c(1,exp(-cumsum(haz[1:(length(haz)-1)]*diff(cut))))
  #rows to add to age.df
  newrows=data.frame(age=rep(i,101),haz , cut, surv)
  age.df=rbind(age.df, newrows)}


#survival curves for each Sex. Solid line is surv curve based on muhaz hazard
km.curve=survfit(Surv(s.time, end.status)~factor(age.group, levels = levels2), data=combined)
survplot.age=autoplot(km.curve)+ 
  labs(title = "Survival Curves by Age")+
  xlab("Time(in days)")+
  ylab("Survival Probability") +
  geom_line(data=age.df, aes(x=cut, y=surv, color=age), inherit.aes = FALSE)+
  theme(text=element_text(size=12))


#hazard curves for each sex
hazplot.age=ggplot(data=age.df, aes(x=cut, y=haz, color=age))+ 
  geom_line()+
  labs(title="Smoothed Hazard Curve by Age",
       caption="Figure 4: Survival and Hazard Curves by Age Category") +
  xlab("Time(in days)") +
  ylab("Hazard Rate") +
  theme(text = element_text(size=12),
        plot.caption = element_text(hjust = 0, size=18),
        axis.text.y = element_text(size = 12),
        axis.text.x = element_text(size = 12))


overall.age=ggarrange(survplot.age, hazplot.age, nrow =2) 
#ggsave(filename = "ageSurv.pdf", plot=overall.age, width = 8, height = 6 )
survdiff(Surv(s.time, end.status)~age.group+strata(sex, country), data=combined)
pw.agegroup=pairwise_survdiff(Surv(s.time, end.status)~age.group, data=combined)



#which variables violate proportional hazards model
#cox.zph tests the PH assumption
#plot(cox.zph(coxph(Surv(s.time, end.status)~age.group + sex + country, data=combined)))



#Country violated PH assumption, stratify on country
#now PH assumption reasonably met
#cox.zph(coxph(Surv(s.time, end.status)~age.group + sex + strata(country), data=combined))


#models for testing whether age.group is significant 
mod.cox1=coxph(Surv(s.time, end.status)~age.group + sex + strata(country), data=combined)

mod.cox.int=coxph(Surv(s.time, end.status)~age.group + sex + age.group:country+sex:country+strata(country), data=combined)

#are any of the interaction terms useful
#p-value=.1732, no interactions not helpful
anova(mod.cox1, mod.cox.int)

#in the model w/o interactions none of the age.group coefficients are significant
#Does age.group need to be in the model? 
mod.cox2=coxph(Surv(s.time, end.status)~ sex + strata(country), data=combined)

#YES age.group should remain
anova(mod.cox1, mod.cox2)

#It may be useful to consider age as continuous
mod.cox3=coxph(Surv(s.time, end.status)~Age+sex+strata(country), data=combined)
cox.zph(mod.cox3)#PH assumption reasonable


#which stratified model is better? Numeric age or age.group
AIC(mod.cox1, mod.cox3)#numeric age is better, mod.cox3


sum.cox3=summary(mod.cox3)
mod3.df=data.frame(var=rownames(sum.cox3$conf.int) ,est=sum.cox3$coefficients[,2], 
                   high=sum.cox3$conf.int[,4], low=sum.cox3$conf.int[,3])

ggplot(mod3.df, aes(x=var)) +
  geom_point(aes(y=high)) +
  geom_point(aes(y=low)) +
  geom_errorbar(aes(ymin=low, ymax=high), size=1)+
  geom_point(aes(y=est), color="red") +
  geom_hline(yintercept = 1, size=1) +
  coord_flip() +
  labs(title ="95% Confidence Interval for Hazard Ratio",
       caption = "Stratified Cox regression model with numeric age")
  
  


###################################
# how about an extended cox model #
###################################

#put data in counting process form
covid=survSplit(combined, cut = combined$s.time[combined$end.status==1], 
                end = "s.time", event = "end.status", id="id")


#fitting the Model
x.mat.Age=data.frame(model.matrix(~Age+sex+country+id+tstart+s.time+end.status, data=covid))[,-1]

mod.extF=coxph(Surv(tstart, s.time, end.status)~ 
                Age + sexmale + countryIndia + countryKorea + countryIndia:s.time + countryKorea:s.time + sexmale:s.time+Age:s.time, 
              data=x.mat.Age)
sum.modF=summary(mod.extF)

mod.ext=coxph(Surv(tstart, s.time, end.status)~ 
                Age + sexmale + countryIndia + countryKorea + countryIndia:s.time + countryKorea:s.time, 
        data=x.mat.Age)
sum.mod=summary(mod.ext)

coxext.df=data.frame(var=rownames(sum.mod$coefficients),
                     high=sum.mod$conf.int[,4],
                     low=sum.mod$conf.int[,3],
                     est=sum.mod$conf.int[,1])


extcox.HR=ggplot(coxext.df, aes(x=var)) +
  geom_point(aes(y=high)) +
  geom_point(aes(y=low)) +
  geom_errorbar(aes(ymin=low, ymax=high), size=1)+
  geom_point(aes(y=est), color="red", size=4) +
  geom_hline(yintercept = 1, size=1) +
  xlab("") + ylab("Hazard Ratio")+
  scale_y_continuous(limits = c(0,4))+
  coord_flip() +
  theme(plot.caption = element_text(size=18, hjust = 0),
        axis.text = element_text(size=18),
        axis.title = element_text(size=18))
#ggsave(filename = "extcoxHR.pdf", extcox.HR, width=10, height = 8)


