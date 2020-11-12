#
# Author: Caleb Fornshell
# Date: November 2020
#
# Description: Shiny web app that compares the salaries of MLB players. Will 
# scrape data from a github account and use packages such as shiny, ggplot, 
# tidyr, and plotly to produce an interactive web app to compare the salaries 
# of MLB players across years, and teams.

library(shiny)
require(shinythemes)
require(htmltab)
require(tidyverse)
require(plotly)


#########################################
#                                       #
#  scraping data from a github account  #
#                                       #
#########################################
PartialURL = "https://raw.githubusercontent.com/chadwickbureau/baseballdatabank/master/core/"

titles = c("People", "Salaries","Teams") # names of the tables


tables=list() #list of tables
sources=list() #list of urls from where data was scraped


#loop for scraping data and storing data table in the lists 
for(i in 1:length(titles)) {
  
  sport.table = read.csv2(
    paste(PartialURL, titles[i], ".csv", sep = ""),
    header = TRUE,
    sep = ",",
    stringsAsFactors = FALSE
  )
  
  tables[[i]] = sport.table
  sources[[i]] = paste(PartialURL, titles[i], ".csv", sep = "")
}

#naming the columns in the data tables and attaching for easier access
names(tables)=titles
names(sources)=titles
attach(tables)




###################################################
#                                                 #
#  Cleaning the Data sets(converting data types   #
#   and removing unnecessary columns)             #
#                                                 #
###################################################
People = People %>%
  transmute(
    playerID = playerID,
    birthCountry = birthCountry,
    nameFirst = nameFirst,
    nameLast = nameLast,
    nameGiven = nameGiven,
    debut = as.Date(debut),
    finalGame = as.Date(finalGame)
  )

Teams = Teams %>%
  transmute(
    yearID = yearID,
    lgID = lgID,
    teamID = teamID,
    franchID = franchID,
    divID = divID,
    name = name
  )

Salaries = Salaries %>%
  transmute(
    yearID = yearID,
    teamID = teamID,
    lgID = lgID,
    playerID = playerID,
    salary = as.numeric(salary)
  )


###################################################
#                                                 #
#  Creating dataset(queries) that will be use in  #
#   the analysis later. Comments will describe    #
#   where each query will be used                 #
#                                                 #
###################################################

#list of current franchises
FranchiseCur=(Teams%>%  filter(yearID==2016)%>% select(franchID))[[1]]


## query that is used a lot ##
by.year = inner_join(x = People,
                     y = Salaries,
                     by = c("playerID" = "playerID")) %>%
  select(playerID, nameGiven, salary, teamID, yearID, lgID) %>%
  group_by(yearID, lgID) %>%
  summarise(total_salary = sum(salary))



#table describing the imported tables. Used in the sources tab
DescriptionTable =
  data.frame(
    Table = names(sources),
    Source = c(sources[[1]],sources[[2]],sources[[3]]),
    Description = c(
      'Provides information on individual players for each year played. Includes
        information such as year, salary, team, and personal information such as
        DOB, height, and weight',
      'Provides information on the salary for each player and year. Can be
        merged withPeople based on playerID. Can be merged with Teams based on 
        teamID',
      'Provides information on each team including season, team name, 
        and location'
    )
  )



# Define UI for application that draws a histogram
ui <-
  navbarPage(
    theme = shinytheme("lumen"),
    title = "Baseball Salary Project",
    tabsetPanel(
      type =c("tabs"),
      tabPanel(
        
        ############################
        #                          #
        # Code for 'League' tab    #
        #                          #
        ############################
        
        h4("League"),
        sidebarLayout(
          
          sidebarPanel(
            
            ## Select League ##
            selectInput(
              inputId = "SelectedLeague", 
              label = h4("Select League"),
              choices = c("MLB", "AL","NL"),
              selected = "MLB",
              multiple = TRUE
              ),
            
            ## Select Years ##
            sliderInput(inputId = "SelectedYear",
                        label=h4("Select Year Range"),
                        min=min(Salaries$yearID), 
                        max=2016, step = 1,
                        value=c(min(Salaries$yearID),2016)
            )
          ),
          
            ## Output line graph with league salary info ##
            mainPanel(
              plotOutput("leagueSalary", height = 300)
            )
            
          ),
        
        
          ## Output 3 cards with % change info
          fluidRow(
            ## MLB %change card ##
            column(
              width = 4,
              
              tags$style("#mlbSalaryIncreaseCard {font-size:16px;
                                   color:black;
                                   display:block; }"
              ),
              tags$style("#mlbSalaryIncrease {font-size:40px;
                                   color:red;
                                   display:block; }"
              ),
              div(style="text-align:center;
                             box-shadow: 10px 10px 5px #888888;
                             width:250px;
                             height:200px;
                             padding-top:50px;
                             position:relative;",
              textOutput("mlbSalaryIncreaseCard"),
              textOutput("mlbSalaryIncrease"))
              
            ),
            
            ## AL %change card ##
            column(
              width = 4,
              tags$style("#ALSalaryIncreaseCard {font-size:16px;
                                   color:black;
                                   display:block; }"
              ),
              tags$style("#ALSalaryIncrease {font-size:40px;
                                   color:red;
                                   display:block; }"
              ),
              div(style="text-align:center;
                             box-shadow: 10px 10px 5px #888888;
                             width:250px;
                             height:200px;
                             padding-top:50px;
                             position:relative;",
                  textOutput("ALSalaryIncreaseCard"),
                  textOutput("ALSalaryIncrease"))
              
            ),
            
            ## NL %change card ##
            column(
              width = 4,
              tags$style("#NLSalaryIncreaseCard {font-size:16px;
                                   color:black;
                                   display:block; }"
              ),
              tags$style("#NLSalaryIncrease {font-size:40px;
                                   color:red;
                                   display:block; }"
              ),
              div(style="text-align:center;
                             box-shadow: 10px 10px 5px #888888;
                             width:250px;
                             height:200px;
                             padding-top:50px;
                             position:relative;",
                  textOutput("NLSalaryIncreaseCard"),
                  textOutput("NLSalaryIncrease"))
              
            )
          )
        
 
      ),
                    
                            
        ############################
        #                          #
        # code for 'teams' tab     #
        #                          #
        ############################
      
        tabPanel(h4("Teams"),

            fluidPage(
                 fluidRow(
                          ## Select Teams ##
                          column(width = 3, #menu for selecting teams
                          selectInput(label = h4("Select Team"),
                                      choices=FranchiseCur,
                                      inputId = "team",
                                      selected = "ANA", 
                                      multiple=TRUE
                                      )
                                ),
                        
                        ## Select Years ##  
                        column(width=3,  
                               sliderInput(inputId = "years",
                                           label=h4("Select Years"),
                                           min=min(Salaries$yearID), 
                                           max=2016, step = 1,
                                           value=c(min(Salaries$yearID),2016)
                                           )
                               ),
                        
                        ## Option to include time adjusted values ##
                        column(
                          width=3, 
                          offset = 0,
                          radioButtons(
                            inputId="timeAdj", 
                            label=h4("Show Time Adjusted Values?"), 
                            choices=c("No", "Yes"),
                            selected="No", 
                            inline=TRUE
                            )
                          ),
                        column(
                          width=3, 
                          offset = 0,
                          radioButtons(
                            inputId="showAvg", 
                            label=h4("Show Average Team Salary?"), 
                            choices=c("No", "Yes"),
                            selected="No", 
                            inline=TRUE
                          )
                        )
                         ), #closes fluidRow

                fluidRow(
                  ## inner tabs for selecting line graph or table view ##
                  tabsetPanel(
                    tabPanel(title = "Line Graph",
                    plotOutput("salaryPlot")
                    ),
                    
                    tabPanel(
                      title = "Table",
                      column(width = 10, offset = 1,
                      DT::DTOutput("salaryTable", height = 400))
                      )
                    )
                  )
                )#closes fluid page
            ), #closes tab panel
        
        
        
        ######################################
        #                                    #
        # visuals for 'Player and Teams' tab #
        #                                    #
        ######################################
      
        tabPanel(title = h4("Players and Teams"),
            sidebarLayout(     
                 sidebarPanel(
                   
                     ## Select team menu ##
                     selectInput(
                       label = h4("Select Team"),
                       choices=FranchiseCur,
                       inputId = "team2",
                       selected = "ANA", 
                       multiple =FALSE
                    ),
                    
                    ## Select Year menu ##
                    numericInput(
                      label = h4("Select Year"),
                      inputId = "year2",
                      min=min(Salaries$yearID),
                      max=max(Salaries$yearID),
                      value=min(Salaries$yearID)
                    ),
                     
                     ## Card for selected team's salary ##
                    tags$style("#CardSentence {font-size:18px;
                                               color:black;
                                               display:block; }"
                    ),
                     
                    tags$style("#YearSalary {font-size:36px;
                                             color:red;
                                             display:block; }"
                    ),
                    
                    div(style="text-align:center;
                               box-shadow: 10px 10px 5px #888888;
                               width:250px;
                               height:200px;
                               padding-top:70px;
                               position:relative;",
                         textOutput("CardSentence"),
                         textOutput("YearSalary"),
                     ),
                    
                    ## Card for MLB's average team salary ##
                    tags$style("#CardYearAverage {font-size:18px;
                                                  color:black;
                                                  display:block; }"
                    ),
                         
                    tags$style("#YearAverage {font-size:36px;
                                              color:red;
                                              display:block; }"
                    ),
                    
                    div(style="text-align:center;
                               box-shadow: 10px 10px 5px #888888;
                               width:250px;
                               height:200px;
                               padding-top:70px;
                               position:relative;",
                         textOutput("CardYearAverage"),
                         textOutput("YearAverage")
                    )
                        
                                           
                ),#Closes SidebarPanel
                              
                             
                mainPanel(
                  
                  ## Outputing boxplot to see a teams salary distribution ##
                  plotlyOutput("PlayerTeamDist", height = 200),
                  hr(),
                  hr(),
                  
                  ## Outputting table of all players from selected team
                  DT::dataTableOutput("PlayerTeam", height = 400)
                )
                
            )#closes sidebarlayout
        
        ),#closes tabPanel
                
        
        
        ############################
        #                          #
        # Code for 'Sources' tab   #
        #                          #
        ############################
        tabPanel(
          h4("Sources"),
          fluidRow(tableOutput("DescTable")
                   )
          )
      ),#closes tabsetpanel


    ############################
    #                          #
    # Code for footer          #
    #                          #
    ############################
   hr(style="border-color: black"),
   fluidRow(
     column(
       12, 
       style =list( "background-color:#2a52be; font-color: #FFFFFF;"),
                   p("Created by Caleb Fornshell", style="color: #FFFFFF;"),
                   p("Novemeber 2020",style="color: #FFFFFF;")
       )
     )

)#closes navbarpage






server <- function(input, output) {

############################
#                          #
# visuals for 'League' tab #
#                          #
############################
  
  ##                                           ##
  ## Line Graph for salary for selected league ##
  ##                                           ##
  output$leagueSalary = renderPlot({
    
    ## variables from user input
    league=input$SelectedLeague
    yearlow=input$SelectedYear[1]
    yearhigh=input$SelectedYear[2]
    
    ## baseline plot with no lines added ##
    league.plot = 
      ggplot(data=by.year, aes(x = yearID, y = total_salary, color=lgID)) +
      scale_x_continuous(breaks = seq(yearlow, yearhigh, by=2)) +
      scale_y_continuous(labels = scales::comma, n.breaks=8) +
      ylab("Total Salary(USD)") + 
      xlab("Year") + 
      labs(color="League") +
      theme(text = element_text(size=14), axis.text.x = element_text(angle=45))
    
    ## Adding line for AL if selected
    if("AL" %in% league == TRUE){
      
      league.plot = league.plot +
        geom_line(data = by.year %>% filter(lgID == "AL",
                                            between(yearID, yearlow, yearhigh)),
                  size = 1.2)
    }
    
    ## Adding line for NL if selected
    if("NL" %in% league == TRUE){
      
      league.plot = league.plot + 
        geom_line(data= by.year %>% filter(lgID=="NL",
                                           between(yearID,yearlow,yearhigh)),
                  size=1.2)
      
      
    } 
    
    if("MLB" %in% league == TRUE) {
      
      ## Have to reorganize data ##
      MLB = by.year %>% 
        filter(between(yearID, yearlow, yearhigh)) %>%
        group_by(yearID) %>%
        summarize(total_salary = sum(total_salary), lgID = "MLB")
                  
      league.plot = league.plot + geom_line(data = MLB,size = 1.2)
      
    }
    
    league.plot
  })
  
  ##                               ##
  ## Card: MLB % change over range ##
  ##                               ##
  
  output$mlbSalaryIncreaseCard = renderText({
    
    ## variables from user input
    yearlow=input$SelectedYear[1]
    yearhigh=input$SelectedYear[2]
    
    paste("Average total MLB salary percent change between", 
          yearlow, "and", yearhigh)
    
    })
  
  output$mlbSalaryIncrease = renderText({
     
    #variable from user input
    yearlow=input$SelectedYear[1]
    yearhigh=input$SelectedYear[2]
    
    dat=by.year %>%
      group_by(yearID) %>%
      summarize(total_salary=sum(total_salary)) %>%
      filter(yearID %in% input$SelectedYear)
    
    #finding average % change
    #Solving LastSalary = FirstSalary * x^(number of years) for x
    paste(100*round(-1 +exp(log(dat[2,2]/dat[1,2])/(yearhigh-yearlow)), 4), "%",
          sep = "")
    
    })
  
  
  ##                              ##
  ## Card: AL % change over range ##
  ##                              ##
  output$ALSalaryIncreaseCard = renderText(
    
    paste("Average total AL salary percent change
           between", min(input$SelectedYear), "and", max(input$SelectedYear))
    
  )
  
  output$ALSalaryIncrease = renderText({
    
    dat=by.year %>%
      mutate(lgID=as.character(lgID))%>%
      filter(yearID %in% input$SelectedYear, lgID=="AL" )%>%
      summarize(total_salary=sum(total_salary)) 
      
    
    #exp(log(3750137392/261964696)/31)
    paste(100*round(-1+exp(log(dat[2,2]/dat[1,2])/(dat[2,1]-dat[1,1])),4),"%", sep="")
    
  })
  
  
  ##                              ##
  ## Card: NL % change over range ##
  ##                              ##
  output$NLSalaryIncreaseCard = renderText(
    
    paste("Average total NL salary percent change
           between", min(input$SelectedYear), "and", max(input$SelectedYear))
    
  )
  
  output$NLSalaryIncrease = renderText({
    
    dat=by.year %>%
      mutate(lgID=as.character(lgID))%>%
      filter(yearID %in% input$SelectedYear, lgID=="NL" ) %>%
    summarize(total_salary=sum(total_salary)) 
      
      
      #exp(log(3750137392/261964696)/31)
      paste(100*round(-1+exp(log(dat[2,2]/dat[1,2])/(dat[2,1]-dat[1,1])),4),"%", sep="")
    
  })
 
  
############################
#                          #
# Visuals for 'teams' tab  #
#                          #
############################
  
  ## query used in the following chuncks ##
  by.year.team = inner_join(
    inner_join(
      x = People,
      y = Salaries,
      by = c("playerID" = "playerID")
    ) %>%
      select(playerID, nameGiven, salary, teamID, yearID),
    Teams,
    by = c("teamID" = "teamID", "yearID" = "yearID")
  ) %>%
    select(playerID, nameGiven, salary, teamID, yearID, franchID, name) %>%
    group_by(franchID, yearID) %>%
    summarise(
      number_salaries = n(),
      total_salary = sum(salary),
      avg_salary = round(mean(salary), 0)
    )
  
  ##                                                          ##    
  ## line graph for selected teams salaries in years selected ##
  ##                                                          ##
  
  output$salaryPlot <- renderPlot({
   
    ## input variables from user 
    Loyear=input$years[1]
    Hiyear=input$years[2]
     
      #subsetting data for line graphs
      Team= by.year.team %>% 
        filter(franchID %in% input$team, yearID %in% Loyear:Hiyear) %>%
        mutate(total_salaryAdj. = total_salary*1.0265^(2016-yearID))
        #.0265 is the annual inflation rate from 1985-2016
      
      #creating line graph
      p = ggplot(data=Team, aes(x=yearID, y=total_salary, color=franchID)) +
          geom_line(size=1.2) +
          scale_y_continuous(name = "Team Salary(USD)", 
                             labels = scales::comma,
                             n.breaks=6) +
          scale_x_continuous(name="Year", breaks=seq(Loyear, Hiyear, by=2)) +
          theme(legend.position = "bottom", text = element_text(size = 14)) +
          labs(color="Franchise") 
      
      ## Adding time adjusted lines if radio button is yes
      if(input$timeAdj=="Yes"){
        
        p=p + 
          geom_line(aes(y=total_salaryAdj.), linetype="dashed") +
          labs(caption = "Dashed lines represents amount in 2016 USD. \n
                            Based on yearly inflation rate of 2.65%")
      }
      
      #include average line
      if(input$showAvg == "Yes"){
        mlbavg = 
          by.year.team %>% 
          group_by(yearID)%>%
          filter(yearID %in% Loyear:Hiyear) %>%
          summarize(total_salary=mean(total_salary), franchID="MLB Average")
        
        p = p + 
            geom_line(data=mlbavg,size=1.1, linetype="twodash")
      }
      
      p
      
  })
 
  ##                                                                ##    
  ## Table that displays selected teams' salaries over chosen years ##
  ##                                                                ##
    output$salaryTable=DT::renderDataTable({
      
      Loyear=input$years[1]
      Hiyear=input$years[2]
        
        Team=by.year.team %>% 
          filter(franchID %in% input$team, yearID %in% Loyear:Hiyear)%>%
          mutate(total_salaryAdj. = round(total_salary*1.0265^(2016-yearID), 0))
        
        DT::datatable(Team, options = list(paging=FALSE),fillContainer = TRUE)
    })
    
    

    
    
    
    
    
#######################################
#                                     #
# Visuals for 'Players and Teams' tab #
#                                     #
#######################################
    
    ##                                                          ##    
    ## Card that displays selected team's salary in chosen year ##
    ##                                                          ##
    
    output$CardSentence = renderText({
      
      paste("The salary for ", input$team2, " in ", input$year2, " was:")
      
    })
    
    
    output$YearSalary = renderText({
      
      ##input variables from users
      SelTeam = input$team2
      SelYear = input$year2
        
        Team.Data = 
          #join Teams so I have access to the franchID column
          inner_join(
            #first join people and salaries to get salary for each player
            inner_join(x =People, y = Salaries, by=c("playerID"="playerID")) %>%
               select(nameLast,nameFirst, salary, teamID, yearID), 
            Teams, 
            by=c("teamID"="teamID", "yearID"="yearID")) %>%
          select(nameLast,nameFirst, salary,yearID, franchID) %>%
          filter(franchID == SelTeam, yearID==SelYear)
                    
        paste("$",(scales::comma(sum(Team.Data$salary))), sep = "")
    })
    
    
    
    ##                                                             ##    
    ## Card that displays MLB's average team salary in chosen year ##
    ##                                                             ##
    
    output$CardYearAverage = renderText({
      
      paste("The average team salary in ", input$year2, " was:")
      
    })
    
    
    output$YearAverage = renderText({
      
      Team.Data = 
        #joining Team so I have access to franch ID
        inner_join(
          #first joining peple and salaries to get salary for each player
          inner_join(x = People, y = Salaries, by=c("playerID"="playerID")) %>%
        select(nameLast,nameFirst, salary, teamID, yearID), 
        Teams, 
        by=c("teamID"="teamID", "yearID"="yearID")) %>%
        select(salary,yearID, franchID) %>%
        filter(yearID==input$year2 ) %>%
        group_by(franchID) %>%
        summarize(yearly_average=round(mean(salary)),2)
      
      paste("$",(scales::comma(sum(Team.Data$yearly_average))), sep = "")
      
    })
    
    
    
    ##                                                            ##    
    ##  Table that gives salary for every player on selected team ##
    ##                                                            ##
    
    output$PlayerTeam = DT::renderDataTable({
        
      Team.Data = 
        #joining with teams to get franchID
        inner_join(
          #joining people and salaries to get salary for each player
          inner_join(x = People, y = Salaries, by=c("playerID"="playerID")) %>%
          select(nameLast,nameFirst, salary, teamID, yearID), 
          Teams, 
          by=c("teamID"="teamID", "yearID"="yearID")) %>%
        select(nameLast,nameFirst, salary, yearID, franchID) %>%
        filter(franchID == input$team2, yearID==input$year2) %>%
        select(nameFirst, nameLast, salary, yearID) %>%
        arrange(desc(salary)) %>%
        mutate(salary=scales::comma(salary))
        
        DT::datatable(Team.Data, 
                      options = list(paging=FALSE), 
                      fillContainer = TRUE
                      )
    })
  
    ##                                                                 ##    
    ##  Generating interactive boxplot to see distribution chosen team ##
    ##                                                                 ##
    
    output$PlayerTeamDist = renderPlotly({
      
      ## input variables from user ##
      SelTeam = input$team2
      SelYear = input$year2
      
      ## query to select specified year, team, franchise
      Team.Data = 
        #joint with Teams to get franchID
        inner_join(
          #joing people and salaries to get player salaries
          inner_join(x = People, y = Salaries, by=c("playerID"="playerID")) %>%
          select(nameLast,nameFirst, salary, teamID, yearID), 
          Teams, #adding the franchise information
          by=c("teamID"="teamID", "yearID"="yearID")) %>%
        select(nameLast,nameFirst, salary, yearID, franchID)  %>%
        filter(franchID == SelTeam, yearID == SelYear ) %>%
        select(nameFirst, nameLast, salary, yearID, franchID) %>%
        arrange(desc(salary))
        
      
      ##query to get average and median team salaries for specified year
      ## similar to above query
      league.avg = 
        inner_join(
          inner_join(x = People, y = Salaries, by=c("playerID"="playerID")) %>%
          select(nameLast,nameFirst, salary, teamID, yearID), 
          Teams,
          by=c("teamID"="teamID", "yearID"="yearID")) %>%
        select(salary, yearID) %>%
        filter(yearID==input$year2 ) %>%
        summarize(lg.mean=mean(salary), lg.med=median(salary))
      
    
        ##generating the interactive boxplot using the previous queries
      ggplotly(
        tooltip = c("nameLast", "salary"),
        ggplot(data = Team.Data, aes(x =franchID, y =salary, label =nameLast)) +
           geom_boxplot() +
           geom_point(size = 1.5, position = position_jitter()) +
           geom_hline(aes(yintercept = league.avg$lg.mean), color = "red") +
           geom_hline(aes(yintercept = league.avg$lg.med), color = "green") +
           coord_flip() +
           scale_y_continuous(labels = scales::comma) +
           labs(title = "Green and red lines are league median and mean") +
           theme(text = element_text(size = 14),
                 plot.title = element_text(size = 10)) +
           xlab("") +
           ylab("Salary(USD)")
        )
        
        
    })
    
 
#############################
#                           #
# visuals for 'Sources' tab #
#                           #
#############################
   
################### Source Description table for Sources tab
    output$DescTable =renderTable(
        
        DescriptionTable, striped = TRUE, bordered = TRUE, align = "c"
    )  
    
} #closes server functioin


# Run the application 
shinyApp(ui = ui, server = server)




