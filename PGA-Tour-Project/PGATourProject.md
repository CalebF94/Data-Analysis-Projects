---
title: "PGA Tour Project"
author: "Caleb Fornshell"
date: "11/11/2020"
output:
  html_document:
    keep_md: TRUE
    code_folding: "hide"
    df_print: paged
    toc: TRUE
    toc_depth: '3'
editor_options:
  chunk_output_type: inline
---

<!--
Author: Caleb F
Date: 11/2020

Description: Code for generating the html document PGA-Tour-Project.html.
Player data was scraped from the PGA website and the tournament winner data
is from wikipedia. In the future I plan to use simialar data to perform a 
classification problem.
-->

<style type="text/css">

body, td {
   font-size: 18px;
}
</style>



  
<p>&nbsp;</p>

  
## *Introduction*
*****
The emergence of data analytics has impacted the way sports are played across
the world, and the PGA tour is no different. Over the last few years data has 
greatly impacted the way golfers play and how they are compared to one another. 
The goal of this project is to gain an understanding of which variables of a 
golfers performance are most important to determine whether a golfer will shoot 
low and win a tournament.

  
<p>&nbsp;</p>    
## *Gathering and Cleaning the Data*
*****
The player performance data for this project was scraped from the official
website of the PGA Tour, and the information on tournament winners is from 
Wikipedia. Both sources were scraped using Power Querey. The variables used were
chosen based on my knowledge and interest of golf. In total, 14 variables were 
scraped from the PGA tour website and one from Wikipedia. One variable contained
playerand year combined. These were split into two separate variables, which 
resulted in the variables used in this analysis. A full description of each 
variable can be found [here,](https://tinyurl.com/y4wljbxy) and the structure 
of data set is below.

```r
str(PGAdata)
```

```
## Classes 'spec_tbl_df', 'tbl_df', 'tbl' and 'data.frame':	940 obs. of  17 variables:
##  $ Golfer          : chr  "Aaron Baddeley" "Aaron Baddeley" "Aaron Baddeley" "Aaron Baddeley" ...
##  $ Year            : num  2015 2016 2017 2018 2019 ...
##  $ Player          : chr  "Aaron Baddeley (2015)" "Aaron Baddeley (2016)" "Aaron Baddeley (2017)" "Aaron Baddeley (2018)" ...
##  $ AvgApproachGT100: num  33.7 34.4 36.5 33.7 36.2 ...
##  $ AvgApproachLT100: num  19.1 18 17.2 19.4 16.5 ...
##  $ AvgBallSpeed    : num  175 173 173 171 171 ...
##  $ AvgClubheadSpeed: num  118 116 116 114 114 ...
##  $ LaunchAngle     : num  10.65 9.19 8.32 9.5 7.37 ...
##  $ ProxToHoleARG   : num  7.33 7.08 7.42 7.08 7.08 8.42 7.75 7.42 7.58 7.75 ...
##  $ Putt10_15Made   : num  44.8 33.5 33.9 27.6 36.9 ...
##  $ Putt15_20Made   : num  21.1 19.6 21 20.8 25 ...
##  $ PuttGT20Made    : num  6.91 7.19 6.1 5.67 7.39 7.47 6.08 6.83 6.8 8.98 ...
##  $ PuttLT10Made    : num  88.7 89.8 86 87.6 88.6 ...
##  $ SandSave        : num  59.1 61.1 58.4 57 54.5 ...
##  $ SpinRateOTT     : num  2526 2573 2875 2683 2858 ...
##  $ Winner          : num  1 0 0 0 0 1 0 0 0 0 ...
##  $ StrokeAverage   : num  71.2 70.9 71.5 70.8 70.8 ...
##  - attr(*, "spec")=
##   .. cols(
##   ..   Golfer = col_character(),
##   ..   Year = col_double(),
##   ..   Player = col_character(),
##   ..   AvgApproachGT100 = col_double(),
##   ..   AvgApproachLT100 = col_double(),
##   ..   AvgBallSpeed = col_double(),
##   ..   AvgClubheadSpeed = col_double(),
##   ..   LaunchAngle = col_double(),
##   ..   ProxToHoleARG = col_double(),
##   ..   Putt10_15Made = col_double(),
##   ..   Putt15_20Made = col_double(),
##   ..   PuttGT20Made = col_double(),
##   ..   PuttLT10Made = col_double(),
##   ..   SandSave = col_double(),
##   ..   SpinRateOTT = col_double(),
##   ..   Winner = col_double(),
##   ..   StrokeAverage = col_double()
##   .. )
```

This project uses two response variables, `StrokeAverage` and `Winner`, and
twelve predictor variables which conceptually fall into one of 
three groups:

* Off the Tee Statistics
  + `AvgClubheadSpeed`, `AvgBallSpeed`, `LaunchAngle`, `SpinRateOTT`
* Shots Into the Green
  + `AvgApproachGT100`, `AvgApproachLT100`, `ProxToHoleARG`, `SandSave`
* Putting
  + `PuttGT20Made`, `Putt15_20Made`, `Putt10_15Made`, `PuttLT10Made`
  
  
<p>&nbsp;</p>    
## *Exploratory Data Analysis*
******
To begin, the numer of golfers from each year is determined. The barplot shows
there were around 180-190 golfers from each season.

```r
#Number of qualified golfers each season
ggplot(data=PGAdata, aes(x=Year)) + 
  geom_bar() +
  geom_text(stat='count', 
            aes(label=..count..), 
            vjust=-.1, 
            position =position_dodge(width=.8)) +
  ylab("Number of Golfers")+
  labs(title = "Qualified Golfers Each Year")
```

<img src="PGATourProject_files/figure-html/unnamed-chunk-2-1.png" style="display: block; margin: auto;" />


Next, the distributions of the numeric variables were plotted and displayed. The
histograms and summary statistics table show that these variables are symmetric
and appear uni-modal. There are not any eye-catching anomalies that need to 
be addressed at this time.

:::: {style="display: grid; grid-template-columns: 1fr 1fr; 
grid-column-gap: 10px; "}

::: {}

```r
# density and histogram of all predictor variables OTT
ggplot(data=melt(predStAvg), aes(x=value))+
  geom_density(color="black") + 
  geom_histogram(aes(y = ..density..), bins=20 )+
  facet_wrap(~variable,scales = "free", ncol = 3)+
  labs(title = "Density Plots For All Predictor Variables") +
  theme(strip.text = element_text(size = 14))
```

![](PGATourProject_files/figure-html/unnamed-chunk-3-1.png)<!-- -->
:::

:::{}


```r
#summary statistics table
SummaryStats= tibble(Variable=names(predStAvg),
                     Units=c("Ft","Ft","MPH","MPH","Degrees","Ft",
                           "Perc","Perc","Perc","Perc","Perc","RPM","Strokes"),
                     Mean=round(apply(predStAvg,2,mean),2),
                     Median=round(apply(predStAvg,2,median),2),
                     Std.Dev=round(apply(predStAvg,2,sd),2),
                     Min=round(apply(predStAvg,2,min),2),
                     Max=round(apply(predStAvg,2,max),2))

#knitr::kable(SummaryStats,digits = 2)

SummaryStats
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["Variable"],"name":[1],"type":["chr"],"align":["left"]},{"label":["Units"],"name":[2],"type":["chr"],"align":["left"]},{"label":["Mean"],"name":[3],"type":["dbl"],"align":["right"]},{"label":["Median"],"name":[4],"type":["dbl"],"align":["right"]},{"label":["Std.Dev"],"name":[5],"type":["dbl"],"align":["right"]},{"label":["Min"],"name":[6],"type":["dbl"],"align":["right"]},{"label":["Max"],"name":[7],"type":["dbl"],"align":["right"]}],"data":[{"1":"AvgApproachGT100","2":"Ft","3":"32.69","4":"32.58","5":"1.58","6":"27.42","7":"40.58"},{"1":"AvgApproachLT100","2":"Ft","3":"17.21","4":"17.25","5":"1.92","6":"11.50","7":"27.25"},{"1":"AvgBallSpeed","2":"MPH","3":"169.21","4":"168.69","5":"6.09","6":"152.55","7":"190.70"},{"1":"AvgClubheadSpeed","2":"MPH","3":"113.87","4":"113.50","5":"4.23","6":"100.91","7":"128.18"},{"1":"LaunchAngle","2":"Degrees","3":"10.68","4":"10.78","5":"1.47","6":"5.57","7":"14.71"},{"1":"ProxToHoleARG","2":"Ft","3":"7.54","4":"7.50","5":"0.54","6":"6.08","7":"9.33"},{"1":"Putt10_15Made","2":"Perc","3":"30.24","4":"30.24","5":"3.84","6":"18.69","7":"44.81"},{"1":"Putt15_20Made","2":"Perc","3":"18.67","4":"18.73","5":"3.74","6":"8.00","7":"30.63"},{"1":"PuttGT20Made","2":"Perc","3":"7.16","4":"7.10","5":"1.54","6":"2.62","7":"12.19"},{"1":"PuttLT10Made","2":"Perc","3":"87.50","4":"87.57","5":"1.19","6":"83.12","7":"91.18"},{"1":"SandSave","2":"Perc","3":"50.27","4":"50.35","5":"5.86","6":"32.43","7":"68.66"},{"1":"SpinRateOTT","2":"RPM","3":"2597.24","4":"2583.90","5":"206.73","6":"1966.90","7":"3404.20"},{"1":"StrokeAverage","2":"Strokes","3":"70.95","4":"70.95","5":"0.71","6":"68.70","7":"74.40"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>
:::
::::


It is also important to understand the relationship between the predictor
variables. The correlation plot below shows the linear relationship between all
predictors. One pair of variables that has a very large positive correlation is 
`AvgClubheadSpeed` and `AvgBallSpeed`. This relationship, intuitivaley, is not 
surprising. There are also some negative correlations that are relatively high 
as well. These pair of variables will need to be considered in future analyses.




```r
ggcorrplot::ggcorrplot(cor(pred), method = "square", type = "upper", ggtheme = "minimal") +
  theme(axis.text.x=element_text(angle=35))
```

<img src="PGATourProject_files/figure-html/unnamed-chunk-5-1.png" style="display: block; margin: auto;" />

The EDA demonstrated that the data is complete and is not missing any values
as the PGA kept thorough records for the seasons examined. Thus, there should be
very issues in future analyses.




<p>&nbsp;</p>    
## *Predicting Stroke Average* 
*****
In the following section machine learning models will be used to predict a 
player's stroke average based on the predictor variables described previously.
A few different models such as K-nearest neighbors, regression trees, and random
forests will be used. In an attempt to compare different models, the data will 
be split into training and test sets. The training data will be all observations
from the seasons 2015-2018 and the test dataset will consist of observations 
from 2019.


```r
train = PGAdata[PGAdata$Year!=2019 , c(4:15,17)]
test = PGAdata[PGAdata$Year==2019 , c(4:15,17)]
```
In total ther are 752 observations in the training set and 
188 observations in the test set.

### K-Nearest Neighbors
The first method used will the non-parametric method K-nearest neigbors(KNN). 
The package `caret` contains the `knnreg()`function implemented here. In these 
models the critical parameter is K, the number of neighbors. The chosen K will
be the valuethat minimizes the MSE of the test data. The results of the model 
are shown in the graph below.


```r
#vector to store results
mse.vector = numeric(100)

#Will loop through all values of K and store the MSE. We want min(MSE)
for(i in 1:100){
  
knn.mod = knnreg(StrokeAverage~., data=train, k=i)#generating model with train
knn.test = predict(object = knn.mod, test)#getting predictions for test
MSE=mean((test$StrokeAverage - knn.test)^2)#calculating Test MSE

mse.vector[i]=MSE

}

#getting best K and MSE
bestk=which(mse.vector==min(mse.vector))
bestMSE.knn = min(mse.vector)

#Plot showing trend of test MSEs
plot(x=1:100, y=mse.vector, type = "l", xlab = "K", ylab = "MSE")
title("KNN Mean Square Errors: Test Set")
text(x=50, y=10,paste("Best: K=", bestk, "\nMin MSE=", round(bestMSE.knn,2)))
points(x=bestk, y=min(mse.vector), col="red", pch=19)
```

![](PGATourProject_files/figure-html/unnamed-chunk-7-1.png)<!-- -->



### Tree Based Methods 
Regression trees are another non-parametric method. A simple regression tree and
a random forrest will be implemented using the `tree` and `randomForest`
packages. 

#### *Regression Tree*
First, a simple tree. I will fit a simple tree model. Because there
are a relatively large number of predictors, the tree will be "trimmed" using 
cross validation in the `prune.tree()` and `cv.tree()` functions and choosing
the tree with 10 "leaves" minimizes the MSE on the test set.


```r
set.seed(123)

##unpruned tree
unpruned.tree = tree(StrokeAverage~., data = train)
unpruned.pred = predict(unpruned.tree, test)
#MSE from the test set
unpruned.MSE = mean((unpruned.pred - test$StrokeAverage)^2)


# Pruned Tree chosen by Cross Validation
tree.cv = cv.tree(unpruned.tree, FUN = prune.tree)
#what is the optimal number of leaves
best.size = tree.cv$size[which(tree.cv$dev == min(tree.cv$dev))]#10
pruned.tree = prune.tree(unpruned.tree, best = best.size)
pruned.pred = predict(pruned.tree, test)
pruned.MSE = mean((pruned.pred - test$StrokeAverage)^2)

#plotting the Trees
par(mfrow=c(2,1))
plot(unpruned.tree)
title(paste("Unpruned Tree:\n MSE=", round(unpruned.MSE,2)))
text(unpruned.tree, pretty=0)

plot(pruned.tree)
title(paste("Pruned Tree:\n MSE=", round(pruned.MSE,2)))
text(pruned.tree, pretty=0)
```

![](PGATourProject_files/figure-html/unnamed-chunk-8-1.png)<!-- -->

#### *Random Forest*
Random forests are an improvement over a simple tree because it produces many
uncorrelated trees which results in a smaller variance. It also restricts the
variables that are available at each break in the tree, so it considers the 
effects of all variables even if they are correlated with best single predictor.


```r
set.seed(123)
forest.mse = numeric(12)

#finding tree that minimizes OOB error(MSE)
for(m in 1:12){
  
  #mtry = # of variables randomly selected at each break
  #trying to find best mtry
mod.forest = randomForest(StrokeAverage~., data=train, mtry=m)
forest.pred = predict(mod.forest, test)

forest.mse[m]=mean((forest.pred-test$StrokeAverage)^2)
  
}

best=which(forest.mse == min(forest.mse))

par(mfrow=c(1, 2))
plot(x=1:12, y=forest.mse,type="b",
     xlab = "Number of Variables", ylab = "OOB Error")
title(main = "OOB Error Vs # of Variables At Each Split")
text(paste("Best model uses", 4, "variables at each split\n", 
           "OOB Error=", round(min(forest.mse),4)), x=6, y=.294)
points(x=best, y=min(forest.mse), pch=19, col="red")

varImpPlot(randomForest(StrokeAverage~., data=train, mtry=best),
           main = "Variable Importance Plot")
```

![](PGATourProject_files/figure-html/unnamed-chunk-9-1.png)<!-- -->

Another important feature with using tree based methods is it allows us to make
a statement about which variables are most significant. The pruned and unpruned
tree and the variable importance plot all have `AvgBallSpeed` as the upper
most variable, so we can safely say that a higher `AvgBallSpeed` is an important
factor in predicting `StrokeAverage`. All methods also have `PuttLT10Made` as 
the next highest variable, typically followed by some type of shot to the green. 

### Comparison of Methods {.tabset}
The tables below show a comparison of the methods used above. Random forest was
by far the best method based on minimizing the MSE. KNN, unpruned, and pruned 
regression trees all performed substantially worse. The bottom table compares 
the 2019 golfers' stroke averages to those predicted by the forest table.


#### Summary of Results

```r
tibble(Method = c("K-Nearest Neighbors", "Unpruned Regression Tree",
                  "Pruned Regression Tree", "Random Forest"),
       ImportantParameter = c("K", rep("Terminal Nodes",2), "mtry"),
       BestMSE = c(round(bestMSE.knn,2),round(unpruned.MSE,2),
                   round(pruned.MSE,2), round(min(forest.mse),4)))
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["Method"],"name":[1],"type":["chr"],"align":["left"]},{"label":["ImportantParameter"],"name":[2],"type":["chr"],"align":["left"]},{"label":["BestMSE"],"name":[3],"type":["dbl"],"align":["right"]}],"data":[{"1":"K-Nearest Neighbors","2":"K","3":"0.4200"},{"1":"Unpruned Regression Tree","2":"Terminal Nodes","3":"0.5400"},{"1":"Pruned Regression Tree","2":"Terminal Nodes","3":"0.4900"},{"1":"Random Forest","2":"mtry","3":"0.2797"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

#### Predicted Vs. Observed

```r
SummTable=cbind(PGAdata %>% 
             select(Year, Golfer, StrokeAverage) %>% 
             filter(Year==2019), Predicted=round(forest.pred, 3)) %>%
  mutate(Error=abs(StrokeAverage - Predicted)) %>%
  arrange(Error)

SummTable
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["Year"],"name":[1],"type":["dbl"],"align":["right"]},{"label":["Golfer"],"name":[2],"type":["chr"],"align":["left"]},{"label":["StrokeAverage"],"name":[3],"type":["dbl"],"align":["right"]},{"label":["Predicted"],"name":[4],"type":["dbl"],"align":["right"]},{"label":["Error"],"name":[5],"type":["dbl"],"align":["right"]}],"data":[{"1":"2019","2":"Corey Conners","3":"70.777","4":"70.780","5":"0.003"},{"1":"2019","2":"J.T. Poston","3":"70.633","4":"70.636","5":"0.003"},{"1":"2019","2":"Bud Cauley","3":"70.574","4":"70.563","5":"0.011"},{"1":"2019","2":"Mackenzie Hughes","3":"70.907","4":"70.920","5":"0.013"},{"1":"2019","2":"Jason Day","3":"70.212","4":"70.196","5":"0.016"},{"1":"2019","2":"Jonathan Byrd","3":"71.490","4":"71.472","5":"0.018"},{"1":"2019","2":"Beau Hossler","3":"71.381","4":"71.359","5":"0.022"},{"1":"2019","2":"Adam Hadwin","3":"70.545","4":"70.519","5":"0.026"},{"1":"2019","2":"Brian Gay","3":"71.356","4":"71.321","5":"0.035"},{"1":"2019","2":"Ryan Blaum","3":"71.302","4":"71.337","5":"0.035"},{"1":"2019","2":"Peter Malnati","3":"70.762","4":"70.726","5":"0.036"},{"1":"2019","2":"Tyler Duncan","3":"71.577","4":"71.537","5":"0.040"},{"1":"2019","2":"Marc Leishman","3":"70.436","4":"70.484","5":"0.048"},{"1":"2019","2":"Hank Lebioda","3":"71.002","4":"71.051","5":"0.049"},{"1":"2019","2":"Sung Kang","3":"71.101","4":"71.051","5":"0.050"},{"1":"2019","2":"Bryson DeChambeau","3":"70.178","4":"70.123","5":"0.055"},{"1":"2019","2":"Kevin Streelman","3":"70.763","4":"70.820","5":"0.057"},{"1":"2019","2":"Roberto Castro","3":"71.127","4":"71.069","5":"0.058"},{"1":"2019","2":"Austin Cook","3":"71.201","4":"71.259","5":"0.058"},{"1":"2019","2":"Danny Willett","3":"70.828","4":"70.888","5":"0.060"},{"1":"2019","2":"Russell Henley","3":"70.874","4":"70.814","5":"0.060"},{"1":"2019","2":"Shawn Stefani","3":"70.958","4":"71.022","5":"0.064"},{"1":"2019","2":"Kyle Stanley","3":"71.094","4":"71.028","5":"0.066"},{"1":"2019","2":"Scott Brown","3":"70.960","4":"71.027","5":"0.067"},{"1":"2019","2":"Bronson Burgoon","3":"71.295","4":"71.227","5":"0.068"},{"1":"2019","2":"Josh Teater","3":"70.983","4":"70.915","5":"0.068"},{"1":"2019","2":"Rickie Fowler","3":"69.956","4":"70.024","5":"0.068"},{"1":"2019","2":"Charles Howell III","3":"70.484","4":"70.415","5":"0.069"},{"1":"2019","2":"Kevin Na","3":"71.144","4":"71.214","5":"0.070"},{"1":"2019","2":"Troy Merritt","3":"70.950","4":"70.880","5":"0.070"},{"1":"2019","2":"J.J. Spaun","3":"71.034","4":"71.112","5":"0.078"},{"1":"2019","2":"Ian Poulter","3":"70.502","4":"70.423","5":"0.079"},{"1":"2019","2":"Kramer Hickok","3":"71.243","4":"71.163","5":"0.080"},{"1":"2019","2":"Bubba Watson","3":"70.710","4":"70.795","5":"0.085"},{"1":"2019","2":"Wes Roach","3":"71.228","4":"71.135","5":"0.093"},{"1":"2019","2":"Cameron Champ","3":"71.393","4":"71.298","5":"0.095"},{"1":"2019","2":"Richy Werenski","3":"71.104","4":"71.005","5":"0.099"},{"1":"2019","2":"Harris English","3":"71.055","4":"70.955","5":"0.100"},{"1":"2019","2":"Sam Burns","3":"70.995","4":"70.885","5":"0.110"},{"1":"2019","2":"Jordan Spieth","3":"70.453","4":"70.574","5":"0.121"},{"1":"2019","2":"Vaughn Taylor","3":"70.450","4":"70.571","5":"0.121"},{"1":"2019","2":"C.T. Pan","3":"70.966","4":"71.089","5":"0.123"},{"1":"2019","2":"Martin Laird","3":"70.866","4":"70.743","5":"0.123"},{"1":"2019","2":"Ryan Moore","3":"70.974","4":"71.104","5":"0.130"},{"1":"2019","2":"Pat Perez","3":"71.059","4":"70.927","5":"0.132"},{"1":"2019","2":"Hideki Matsuyama","3":"69.842","4":"69.983","5":"0.141"},{"1":"2019","2":"Kyoung-Hoon Lee","3":"71.307","4":"71.160","5":"0.147"},{"1":"2019","2":"Ben Silverman","3":"71.401","4":"71.242","5":"0.159"},{"1":"2019","2":"Joel Dahmen","3":"70.932","4":"71.093","5":"0.161"},{"1":"2019","2":"Wyndham Clark","3":"70.595","4":"70.433","5":"0.162"},{"1":"2019","2":"Tyrrell Hatton","3":"70.585","4":"70.749","5":"0.164"},{"1":"2019","2":"Jhonattan Vegas","3":"70.765","4":"70.931","5":"0.166"},{"1":"2019","2":"Julián Etulain","3":"71.453","4":"71.284","5":"0.169"},{"1":"2019","2":"Adam Svensson","3":"71.042","4":"70.870","5":"0.172"},{"1":"2019","2":"Jonas Blixt","3":"70.875","4":"71.053","5":"0.178"},{"1":"2019","2":"Justin Rose","3":"69.827","4":"69.643","5":"0.184"},{"1":"2019","2":"Andrew Putnam","3":"70.644","4":"70.832","5":"0.188"},{"1":"2019","2":"Alex Noren","3":"71.046","4":"71.235","5":"0.189"},{"1":"2019","2":"Roberto Díaz","3":"71.207","4":"71.397","5":"0.190"},{"1":"2019","2":"Francesco Molinari","3":"70.974","4":"71.165","5":"0.191"},{"1":"2019","2":"Ryan Palmer","3":"70.679","4":"70.487","5":"0.192"},{"1":"2019","2":"Michael Thompson","3":"70.662","4":"70.862","5":"0.200"},{"1":"2019","2":"Brian Harman","3":"71.016","4":"70.813","5":"0.203"},{"1":"2019","2":"Dylan Frittelli","3":"70.737","4":"70.944","5":"0.207"},{"1":"2019","2":"Sam Ryder","3":"70.912","4":"70.704","5":"0.208"},{"1":"2019","2":"Byeong Hun An","3":"70.480","4":"70.271","5":"0.209"},{"1":"2019","2":"Cameron Davis","3":"70.985","4":"70.771","5":"0.214"},{"1":"2019","2":"Abraham Ancer","3":"70.581","4":"70.797","5":"0.216"},{"1":"2019","2":"Brandt Snedeker","3":"70.521","4":"70.739","5":"0.218"},{"1":"2019","2":"Aaron Wise","3":"70.739","4":"70.959","5":"0.220"},{"1":"2019","2":"Danny Lee","3":"70.997","4":"70.774","5":"0.223"},{"1":"2019","2":"Nate Lashley","3":"70.692","4":"70.917","5":"0.225"},{"1":"2019","2":"Ryan Armour","3":"70.888","4":"70.663","5":"0.225"},{"1":"2019","2":"Matt Jones","3":"70.810","4":"70.574","5":"0.236"},{"1":"2019","2":"Adam Long","3":"71.464","4":"71.226","5":"0.238"},{"1":"2019","2":"Sepp Straka","3":"70.987","4":"71.230","5":"0.243"},{"1":"2019","2":"Bill Haas","3":"71.056","4":"71.302","5":"0.246"},{"1":"2019","2":"Brice Garnett","3":"71.067","4":"71.320","5":"0.253"},{"1":"2019","2":"J.J. Henry","3":"72.135","4":"71.880","5":"0.255"},{"1":"2019","2":"Joaquin Niemann","3":"70.621","4":"70.358","5":"0.263"},{"1":"2019","2":"Xander Schauffele","3":"69.836","4":"70.100","5":"0.264"},{"1":"2019","2":"Kiradech Aphibarnrat","3":"70.911","4":"71.180","5":"0.269"},{"1":"2019","2":"Billy Horschel","3":"70.644","4":"70.914","5":"0.270"},{"1":"2019","2":"Stephan Jaeger","3":"71.201","4":"70.931","5":"0.270"},{"1":"2019","2":"Curtis Luck","3":"72.001","4":"71.731","5":"0.270"},{"1":"2019","2":"Cameron Smith","3":"70.814","4":"70.542","5":"0.272"},{"1":"2019","2":"Kelly Kraft","3":"71.529","4":"71.257","5":"0.272"},{"1":"2019","2":"Dustin Johnson","3":"69.896","4":"70.169","5":"0.273"},{"1":"2019","2":"José de Jesús Rodríguez","3":"71.420","4":"71.139","5":"0.281"},{"1":"2019","2":"Max Homa","3":"71.110","4":"70.816","5":"0.294"},{"1":"2019","2":"Brian Stuard","3":"70.999","4":"70.696","5":"0.303"},{"1":"2019","2":"Si Woo Kim","3":"70.963","4":"70.656","5":"0.307"},{"1":"2019","2":"Scott Piercy","3":"70.333","4":"70.640","5":"0.307"},{"1":"2019","2":"Ernie Els","3":"71.548","4":"71.235","5":"0.313"},{"1":"2019","2":"Graeme McDowell","3":"70.591","4":"70.913","5":"0.322"},{"1":"2019","2":"Denny McCarthy","3":"70.546","4":"70.871","5":"0.325"},{"1":"2019","2":"Jim Knous","3":"71.483","4":"71.148","5":"0.335"},{"1":"2019","2":"Scott Langley","3":"71.605","4":"71.265","5":"0.340"},{"1":"2019","2":"Dominic Bozzelli","3":"71.023","4":"70.681","5":"0.342"},{"1":"2019","2":"Robert Streb","3":"71.629","4":"71.285","5":"0.344"},{"1":"2019","2":"Adam Scott","3":"69.695","4":"70.042","5":"0.347"},{"1":"2019","2":"Adam Schenk","3":"70.817","4":"70.466","5":"0.351"},{"1":"2019","2":"Andrew Landry","3":"71.265","4":"70.909","5":"0.356"},{"1":"2019","2":"Gary Woodland","3":"70.231","4":"70.588","5":"0.357"},{"1":"2019","2":"Branden Grace","3":"71.421","4":"71.053","5":"0.368"},{"1":"2019","2":"Zach Johnson","3":"70.644","4":"71.017","5":"0.373"},{"1":"2019","2":"Sergio Garcia","3":"70.321","4":"70.699","5":"0.378"},{"1":"2019","2":"Joey Garber","3":"71.713","4":"71.331","5":"0.382"},{"1":"2019","2":"Daniel Berger","3":"70.443","4":"70.830","5":"0.387"},{"1":"2019","2":"Harold Varner III","3":"70.716","4":"70.325","5":"0.391"},{"1":"2019","2":"David Hearn","3":"71.697","4":"71.306","5":"0.391"},{"1":"2019","2":"Russell Knox","3":"70.521","4":"70.914","5":"0.393"},{"1":"2019","2":"Chris Stroud","3":"71.644","4":"71.233","5":"0.411"},{"1":"2019","2":"Keegan Bradley","3":"70.849","4":"71.260","5":"0.411"},{"1":"2019","2":"Jason Dufner","3":"71.336","4":"70.919","5":"0.417"},{"1":"2019","2":"Matthew Fitzpatrick","3":"70.525","4":"70.953","5":"0.428"},{"1":"2019","2":"Luke List","3":"71.223","4":"70.794","5":"0.429"},{"1":"2019","2":"Jon Rahm","3":"69.620","4":"70.050","5":"0.430"},{"1":"2019","2":"Patrick Reed","3":"70.209","4":"70.641","5":"0.432"},{"1":"2019","2":"Alex Cejka","3":"72.076","4":"71.643","5":"0.433"},{"1":"2019","2":"Keith Mitchell","3":"71.021","4":"70.579","5":"0.442"},{"1":"2019","2":"Justin Thomas","3":"69.468","4":"69.913","5":"0.445"},{"1":"2019","2":"Charley Hoffman","3":"71.361","4":"70.911","5":"0.450"},{"1":"2019","2":"Nick Taylor","3":"70.697","4":"71.147","5":"0.450"},{"1":"2019","2":"Louis Oosthuizen","3":"70.261","4":"70.712","5":"0.451"},{"1":"2019","2":"Kyle Jones","3":"72.079","4":"71.624","5":"0.455"},{"1":"2019","2":"Carlos Ortiz","3":"71.069","4":"70.603","5":"0.466"},{"1":"2019","2":"Lucas Glover","3":"70.084","4":"70.559","5":"0.475"},{"1":"2019","2":"Roger Sloan","3":"71.034","4":"70.559","5":"0.475"},{"1":"2019","2":"Fabián Gómez","3":"71.484","4":"71.008","5":"0.476"},{"1":"2019","2":"Hudson Swafford","3":"71.350","4":"70.868","5":"0.482"},{"1":"2019","2":"Johnson Wagner","3":"70.847","4":"71.330","5":"0.483"},{"1":"2019","2":"Anirban Lahiri","3":"71.698","4":"71.214","5":"0.484"},{"1":"2019","2":"Aaron Baddeley","3":"70.783","4":"71.273","5":"0.490"},{"1":"2019","2":"Rory Sabbatini","3":"70.409","4":"70.914","5":"0.505"},{"1":"2019","2":"Nick Watney","3":"70.908","4":"70.400","5":"0.508"},{"1":"2019","2":"Kevin Tway","3":"71.020","4":"70.503","5":"0.517"},{"1":"2019","2":"Rory McIlroy","3":"69.058","4":"69.577","5":"0.519"},{"1":"2019","2":"Alex Prugh","3":"71.322","4":"70.800","5":"0.522"},{"1":"2019","2":"Kevin Kisner","3":"70.418","4":"70.961","5":"0.543"},{"1":"2019","2":"Sebastián Muñoz","3":"70.907","4":"70.363","5":"0.544"},{"1":"2019","2":"Paul Casey","3":"69.823","4":"70.370","5":"0.547"},{"1":"2019","2":"Sungjae Im","3":"70.253","4":"70.818","5":"0.565"},{"1":"2019","2":"Cameron Tringale","3":"70.796","4":"70.217","5":"0.579"},{"1":"2019","2":"Chez Reavie","3":"70.248","4":"70.830","5":"0.582"},{"1":"2019","2":"Scott Stallings","3":"71.443","4":"70.852","5":"0.591"},{"1":"2019","2":"Ted Potter, Jr.","3":"72.214","4":"71.587","5":"0.627"},{"1":"2019","2":"Tommy Fleetwood","3":"69.731","4":"70.360","5":"0.629"},{"1":"2019","2":"Jim Herman","3":"71.750","4":"71.118","5":"0.632"},{"1":"2019","2":"Brandon Harkins","3":"71.519","4":"70.885","5":"0.634"},{"1":"2019","2":"Brooks Koepka","3":"69.397","4":"70.050","5":"0.653"},{"1":"2019","2":"Patton Kizzire","3":"71.292","4":"70.636","5":"0.656"},{"1":"2019","2":"Sangmoon Bae","3":"71.762","4":"71.099","5":"0.663"},{"1":"2019","2":"Freddie Jacobson","3":"71.953","4":"71.271","5":"0.682"},{"1":"2019","2":"Hunter Mahan","3":"71.948","4":"71.262","5":"0.686"},{"1":"2019","2":"Rod Pampling","3":"72.304","4":"71.618","5":"0.686"},{"1":"2019","2":"Seth Reeves","3":"72.156","4":"71.465","5":"0.691"},{"1":"2019","2":"Jason Kokrak","3":"70.433","4":"69.727","5":"0.706"},{"1":"2019","2":"Satoshi Kodaira","3":"72.780","4":"72.063","5":"0.717"},{"1":"2019","2":"Tony Finau","3":"69.956","4":"70.709","5":"0.753"},{"1":"2019","2":"Trey Mullinax","3":"71.194","4":"70.434","5":"0.760"},{"1":"2019","2":"Chase Wright","3":"71.233","4":"70.471","5":"0.762"},{"1":"2019","2":"Tom Hoge","3":"71.608","4":"70.841","5":"0.767"},{"1":"2019","2":"Brendan Steele","3":"71.893","4":"71.124","5":"0.769"},{"1":"2019","2":"Patrick Cantlay","3":"69.308","4":"70.078","5":"0.770"},{"1":"2019","2":"Jim Furyk","3":"70.090","4":"70.880","5":"0.790"},{"1":"2019","2":"Talor Gooch","3":"70.629","4":"69.806","5":"0.823"},{"1":"2019","2":"Anders Albertson","3":"71.772","4":"70.939","5":"0.833"},{"1":"2019","2":"Brady Schnell","3":"71.944","4":"71.105","5":"0.839"},{"1":"2019","2":"Jimmy Walker","3":"71.262","4":"70.417","5":"0.845"},{"1":"2019","2":"Rafa Cabrera Bello","3":"70.780","4":"71.628","5":"0.848"},{"1":"2019","2":"Henrik Stenson","3":"70.089","4":"70.963","5":"0.874"},{"1":"2019","2":"Emiliano Grillo","3":"70.814","4":"71.714","5":"0.900"},{"1":"2019","2":"Webb Simpson","3":"69.378","4":"70.337","5":"0.959"},{"1":"2019","2":"Phil Mickelson","3":"71.331","4":"70.350","5":"0.981"},{"1":"2019","2":"Sam Saunders","3":"71.493","4":"70.498","5":"0.995"},{"1":"2019","2":"Cody Gribble","3":"72.096","4":"71.042","5":"1.054"},{"1":"2019","2":"Patrick Rodgers","3":"71.365","4":"70.308","5":"1.057"},{"1":"2019","2":"Matt Kuchar","3":"69.918","4":"71.030","5":"1.112"},{"1":"2019","2":"John Chin","3":"72.485","4":"71.356","5":"1.129"},{"1":"2019","2":"Chesson Hadley","3":"71.453","4":"70.313","5":"1.140"},{"1":"2019","2":"J.B. Holmes","3":"71.735","4":"70.573","5":"1.162"},{"1":"2019","2":"Ollie Schniederjans","3":"71.873","4":"70.592","5":"1.281"},{"1":"2019","2":"Peter Uihlein","3":"71.512","4":"70.146","5":"1.366"},{"1":"2019","2":"Martin Trainer","3":"72.343","4":"70.897","5":"1.446"},{"1":"2019","2":"Whee Kim","3":"72.474","4":"71.019","5":"1.455"},{"1":"2019","2":"Seamus Power","3":"72.026","4":"70.509","5":"1.517"},{"1":"2019","2":"Michael Kim","3":"73.569","4":"71.202","5":"2.367"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

<p>&nbsp;</p>    
## *Predicting Winners* 
*****
In professional sports, winning is everything. Based on the years 2015-2018, 
models to predict winners on the PGA tour can be constructed. The models 
constructed below won't be used to predict winners of individual tournaments, 
but instead will classify a player based on if he should or shouldn't have won a
tournament in a particular year(predicting the value of variable `Winner`) based
on the predictor variables used earlier and `StrokeAverage`. Three different
models will be constructed and their accuracy examined.

### Logistic Regression
A logistic model will be used to determine the probability a golfer should
have at least one victory in a year using the `glm()` function. The results of 
fitting a logistic model show that only some variables appear significant, so a 
simpler model using only those significant variables was also constructed. 

```r
#setting up training and testing set
train = PGAdata[PGAdata$Year!=2019 , c(4:15,17,16)]
test = PGAdata[PGAdata$Year==2019 , c(4:15,17,16)]
train$Winner=as.factor(train$Winner)
test$Winner=as.factor(test$Winner)
```


```r
log.full = glm(Winner~., data=train, family="binomial")
summary(log.full)
```

```
## 
## Call:
## glm(formula = Winner ~ ., family = "binomial", data = train)
## 
## Deviance Residuals: 
##     Min       1Q   Median       3Q      Max  
## -1.6283  -0.5528  -0.3771  -0.2136   2.6385  
## 
## Coefficients:
##                    Estimate Std. Error z value Pr(>|z|)    
## (Intercept)      93.7311739 23.5407448   3.982 6.84e-05 ***
## AvgApproachGT100 -0.1421038  0.0856585  -1.659   0.0971 .  
## AvgApproachLT100 -0.0852134  0.0614581  -1.387   0.1656    
## AvgBallSpeed     -0.1279860  0.0713736  -1.793   0.0729 .  
## AvgClubheadSpeed  0.2456039  0.1026812   2.392   0.0168 *  
## LaunchAngle       0.0247367  0.0959078   0.258   0.7965    
## ProxToHoleARG     0.6216127  0.2560033   2.428   0.0152 *  
## Putt10_15Made     0.0326956  0.0326756   1.001   0.3170    
## Putt15_20Made     0.0300706  0.0319691   0.941   0.3469    
## PuttGT20Made      0.0561272  0.0775961   0.723   0.4695    
## PuttLT10Made      0.0733638  0.1112178   0.660   0.5095    
## SandSave         -0.0075551  0.0234515  -0.322   0.7473    
## SpinRateOTT      -0.0010718  0.0006697  -1.600   0.1095    
## StrokeAverage    -1.4989650  0.2467491  -6.075 1.24e-09 ***
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## (Dispersion parameter for binomial family taken to be 1)
## 
##     Null deviance: 639.90  on 751  degrees of freedom
## Residual deviance: 515.22  on 738  degrees of freedom
## AIC: 543.22
## 
## Number of Fisher Scoring iterations: 5
```

```r
log.simple = glm(Winner~AvgApproachGT100 + StrokeAverage + AvgClubheadSpeed +
                   AvgBallSpeed + ProxToHoleARG, data=train,
                 family="binomial")
summary(log.simple)
```

```
## 
## Call:
## glm(formula = Winner ~ AvgApproachGT100 + StrokeAverage + AvgClubheadSpeed + 
##     AvgBallSpeed + ProxToHoleARG, family = "binomial", data = train)
## 
## Deviance Residuals: 
##     Min       1Q   Median       3Q      Max  
## -1.4974  -0.5691  -0.3840  -0.2147   2.6555  
## 
## Coefficients:
##                   Estimate Std. Error z value Pr(>|z|)    
## (Intercept)      114.37437   16.30100   7.016 2.28e-12 ***
## AvgApproachGT100  -0.13220    0.08008  -1.651  0.09878 .  
## StrokeAverage     -1.69624    0.22042  -7.696 1.41e-14 ***
## AvgClubheadSpeed   0.18940    0.09474   1.999  0.04561 *  
## AvgBallSpeed      -0.10734    0.06697  -1.603  0.10896    
## ProxToHoleARG      0.61742    0.22885   2.698  0.00698 ** 
## ---
## Signif. codes:  0 '***' 0.001 '**' 0.01 '*' 0.05 '.' 0.1 ' ' 1
## 
## (Dispersion parameter for binomial family taken to be 1)
## 
##     Null deviance: 639.90  on 751  degrees of freedom
## Residual deviance: 523.83  on 746  degrees of freedom
## AIC: 535.83
## 
## Number of Fisher Scoring iterations: 5
```

The values of the coefficents demonstrate the most influential varibles appear 
to be similar to those found in the prediction of stroke average along with 
`StrokeAvgerage` itself. Probabilities of winning during the 2019 season, along
with their confusion matrix are calculated below for both models. A golfer was
predicted to have won if he had a probability greater than 0.40.

:::: {style="display: grid; grid-template-columns: 1fr 1fr; 
grid-column-gap: 10px; "}

::: {}

```r
#probabilities
full.pred = predict(log.full, test, type="response")
simple.pred = predict(log.simple, test, type="response")

full.win = (full.pred >= .4)
simple.win = (simple.pred >= .4)


#Confusion Matrices on test data
table(`Full Pred Win` = full.win + 1, `Actual Win` = as.numeric(test$Winner))
```

```
##              Actual Win
## Full Pred Win   1   2
##             1 153  25
##             2   3   7
```

```r
CCR.logF=round(mean(full.win +1 ==as.numeric(test$Winner))*100,2)
```
:::
:::{}


```r
table(`Simple Pred Win` = simple.win+ 1, `Actual Win` = as.numeric(test$Winner))
```

```
##                Actual Win
## Simple Pred Win   1   2
##               1 152  26
##               2   4   6
```

```r
CCR.logR= round(mean(simple.win +1 ==as.numeric(test$Winner))*100,2)
```
:::
::::

### Support Vector Machine
A support vector machine classifier was implemented using the `svm()` function 
from the `e1071` package. The confusion matrix of the best model is shown below.

```r
svmfit = svm(Winner~., data=train, kernel="radial", gamma=1, cost=1000)

#uses CV to select best model
tuned.svm = tune(svm, Winner~., data=train,
                kernel="radial", probability=TRUE,
                ranges=list(cost=c(.1,1,10,100),
                            gamma=c(.5,1,2,3)))

#predictions
svm.pred = predict(tuned.svm$best.model, test, probability = TRUE)
svm.win = attr(svm.pred, "p")[,1] >.4

CCR.svm = round(mean(svm.win +1 ==as.numeric(test$Winner))*100,2)
table(`Predicted Win` = svm.win + 1, `Actual Win` = as.numeric(test$Winner))
```

```
##              Actual Win
## Predicted Win   1   2
##             1 153  30
##             2   3   2
```


### Random Forest Classification 
A random forest was also fit. The most accurate model selected considered ten
variables at each branch and had the following variable importance plot.

```r
set.seed(123)
forest.err = numeric(13)

#finding tree that minimizes OOB error(MSE)
for(m in 1:13){
  
  #mtry = # of variables randomly selected at each break
  #trying to find best mtry
mod.forest = randomForest(Winner~., data=train, mtry=m)
forest.pred = predict(mod.forest, test)

forest.err[m]=mod.forest$confusion[2,3]
  
}

best=min(which(forest.err == min(forest.err)))

par(mfrow=c(1, 2))
plot(x=1:13, y=forest.err,type="b",
     xlab = "Number of Variables", ylab = "Classification Error")
title(main = "Classification Error Vs Variables At Each Split")
text(paste("Best model uses", 4, "variables at each split\n", 
           "OOB Error=", round(min(forest.err),4)), x=6, y=.294)
points(x=best, y=min(forest.err), pch=19, col="red")

varImpPlot(randomForest(Winner~., data=train, mtry=best),
           main = "Variable Importance Plot")
```

![](PGATourProject_files/figure-html/unnamed-chunk-17-1.png)<!-- -->


```r
best.forest=randomForest(Winner~., data=train)

forest.pred = predict(best.forest, test, cutoff = c(.6,.40))

table(`Predicted Win` = forest.pred, `Actual Win`=test$Winner)
```

```
##              Actual Win
## Predicted Win   0   1
##             0 150  26
##             1   6   6
```

```r
CCR.for = round(mean(forest.pred == test$Winner)*100,2)
```
The random forest classification shows that the most important variable is 
stroke average. This agrees with the summary table from the logistic regression 
models.


### Comparison of Methods {.tabset}
The comparison of correct classification rates shows that the accuracy for all 
models is around 80-85%. All models underestimated the number of golfers that 
win a tournament. The models were good at selecting the top ranked golfers in 
the world as demonstrated by the fact that golfers such as Brooks Koepka, Rory
McIlroy, and Xander Schauffele were predicted by multiple models.

#### Classification Rates


```r
tibble(
  Method = c("Full Log. Regr.", "Reduced Log. Regr.", "SVM", "Random Forest"),
  `Correct Classification Rate` = c(CCR.logF, CCR.logR, CCR.svm, CCR.for))
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["Method"],"name":[1],"type":["chr"],"align":["left"]},{"label":["Correct Classification Rate"],"name":[2],"type":["dbl"],"align":["right"]}],"data":[{"1":"Full Log. Regr.","2":"85.11"},{"1":"Reduced Log. Regr.","2":"84.04"},{"1":"SVM","2":"82.45"},{"1":"Random Forest","2":"82.98"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>

#### Predictions Vs. Observed


```r
summaryTab=cbind( PGAdata%>%filter(Year==2019)%>%select(Golfer, Winner) ,
       `Full Log.` = full.win*1,
       `Red. Log.` = simple.win*1,
       `SVM` = svm.win*1,
       `Rand. Forest` = as.numeric(forest.pred)-1)

summaryTab %>% arrange(desc(Winner))
```

<div data-pagedtable="false">
  <script data-pagedtable-source type="application/json">
{"columns":[{"label":["Golfer"],"name":[1],"type":["chr"],"align":["left"]},{"label":["Winner"],"name":[2],"type":["dbl"],"align":["right"]},{"label":["Full Log."],"name":[3],"type":["dbl"],"align":["right"]},{"label":["Red. Log."],"name":[4],"type":["dbl"],"align":["right"]},{"label":["SVM"],"name":[5],"type":["dbl"],"align":["right"]},{"label":["Rand. Forest"],"name":[6],"type":["dbl"],"align":["right"]}],"data":[{"1":"Adam Long","2":"1","3":"0","4":"0","5":"0","6":"0"},{"1":"Brooks Koepka","2":"1","3":"1","4":"1","5":"0","6":"1"},{"1":"Bryson DeChambeau","2":"1","3":"0","4":"0","5":"0","6":"0"},{"1":"Cameron Champ","2":"1","3":"0","4":"0","5":"0","6":"0"},{"1":"Charles Howell III","2":"1","3":"0","4":"0","5":"0","6":"0"},{"1":"Chez Reavie","2":"1","3":"0","4":"0","5":"0","6":"0"},{"1":"Corey Conners","2":"1","3":"0","4":"0","5":"0","6":"0"},{"1":"Dustin Johnson","2":"1","3":"0","4":"0","5":"0","6":"0"},{"1":"Dylan Frittelli","2":"1","3":"0","4":"0","5":"0","6":"0"},{"1":"Francesco Molinari","2":"1","3":"0","4":"0","5":"0","6":"0"},{"1":"Gary Woodland","2":"1","3":"1","4":"1","5":"1","6":"0"},{"1":"Graeme McDowell","2":"1","3":"0","4":"0","5":"0","6":"0"},{"1":"Jim Herman","2":"1","3":"0","4":"0","5":"0","6":"0"},{"1":"Justin Rose","2":"1","3":"1","4":"0","5":"0","6":"1"},{"1":"Justin Thomas","2":"1","3":"0","4":"1","5":"0","6":"1"},{"1":"Keith Mitchell","2":"1","3":"0","4":"0","5":"0","6":"0"},{"1":"Kevin Kisner","2":"1","3":"0","4":"0","5":"0","6":"0"},{"1":"Kevin Na","2":"1","3":"0","4":"0","5":"0","6":"0"},{"1":"Kevin Tway","2":"1","3":"0","4":"0","5":"0","6":"0"},{"1":"Marc Leishman","2":"1","3":"0","4":"0","5":"0","6":"0"},{"1":"Martin Trainer","2":"1","3":"0","4":"0","5":"0","6":"0"},{"1":"Matt Kuchar","2":"1","3":"0","4":"0","5":"0","6":"0"},{"1":"Max Homa","2":"1","3":"0","4":"0","5":"0","6":"0"},{"1":"Nate Lashley","2":"1","3":"0","4":"0","5":"0","6":"0"},{"1":"Patrick Cantlay","2":"1","3":"1","4":"1","5":"0","6":"1"},{"1":"Patrick Reed","2":"1","3":"0","4":"0","5":"0","6":"0"},{"1":"Paul Casey","2":"1","3":"0","4":"0","5":"0","6":"0"},{"1":"Phil Mickelson","2":"1","3":"0","4":"0","5":"0","6":"0"},{"1":"Rickie Fowler","2":"1","3":"1","4":"0","5":"1","6":"1"},{"1":"Rory McIlroy","2":"1","3":"1","4":"1","5":"0","6":"1"},{"1":"Ryan Palmer","2":"1","3":"0","4":"0","5":"0","6":"0"},{"1":"Xander Schauffele","2":"1","3":"1","4":"1","5":"0","6":"0"},{"1":"Aaron Baddeley","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Aaron Wise","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Abraham Ancer","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Adam Hadwin","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Adam Schenk","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Adam Scott","2":"0","3":"0","4":"1","5":"0","6":"1"},{"1":"Adam Svensson","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Alex Cejka","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Alex Noren","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Alex Prugh","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Anders Albertson","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Andrew Landry","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Andrew Putnam","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Anirban Lahiri","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Austin Cook","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Beau Hossler","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Ben Silverman","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Bill Haas","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Billy Horschel","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Brady Schnell","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Branden Grace","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Brandon Harkins","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Brandt Snedeker","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Brendan Steele","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Brian Gay","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Brian Harman","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Brian Stuard","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Brice Garnett","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Bronson Burgoon","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Bubba Watson","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Bud Cauley","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Byeong Hun An","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"C.T. Pan","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Cameron Davis","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Cameron Smith","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Cameron Tringale","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Carlos Ortiz","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Charley Hoffman","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Chase Wright","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Chesson Hadley","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Chris Stroud","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Cody Gribble","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Curtis Luck","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Daniel Berger","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Danny Lee","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Danny Willett","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"David Hearn","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Denny McCarthy","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Dominic Bozzelli","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Emiliano Grillo","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Ernie Els","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Fabián Gómez","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Freddie Jacobson","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Hank Lebioda","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Harold Varner III","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Harris English","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Henrik Stenson","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Hideki Matsuyama","2":"0","3":"0","4":"0","5":"0","6":"1"},{"1":"Hudson Swafford","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Hunter Mahan","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Ian Poulter","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"J.B. Holmes","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"J.J. Henry","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"J.J. Spaun","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"J.T. Poston","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Jason Day","2":"0","3":"1","4":"0","5":"1","6":"1"},{"1":"Jason Dufner","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Jason Kokrak","2":"0","3":"0","4":"0","5":"1","6":"1"},{"1":"Jhonattan Vegas","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Jim Furyk","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Jim Knous","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Jimmy Walker","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Joaquin Niemann","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Joel Dahmen","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Joey Garber","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"John Chin","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Johnson Wagner","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Jon Rahm","2":"0","3":"1","4":"1","5":"0","6":"1"},{"1":"Jonas Blixt","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Jonathan Byrd","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Jordan Spieth","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Josh Teater","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"José de Jesús Rodríguez","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Julián Etulain","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Keegan Bradley","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Kelly Kraft","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Kevin Streelman","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Kiradech Aphibarnrat","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Kramer Hickok","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Kyle Jones","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Kyle Stanley","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Kyoung-Hoon Lee","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Louis Oosthuizen","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Lucas Glover","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Luke List","2":"0","3":"0","4":"0","5":"1","6":"0"},{"1":"Mackenzie Hughes","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Martin Laird","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Matt Jones","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Matthew Fitzpatrick","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Michael Kim","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Michael Thompson","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Nick Taylor","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Nick Watney","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Ollie Schniederjans","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Pat Perez","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Patrick Rodgers","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Patton Kizzire","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Peter Malnati","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Peter Uihlein","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Rafa Cabrera Bello","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Richy Werenski","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Robert Streb","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Roberto Castro","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Roberto Díaz","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Rod Pampling","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Roger Sloan","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Rory Sabbatini","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Russell Henley","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Russell Knox","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Ryan Armour","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Ryan Blaum","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Ryan Moore","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Sam Burns","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Sam Ryder","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Sam Saunders","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Sangmoon Bae","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Satoshi Kodaira","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Scott Brown","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Scott Langley","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Scott Piercy","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Scott Stallings","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Seamus Power","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Sebastián Muñoz","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Sepp Straka","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Sergio Garcia","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Seth Reeves","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Shawn Stefani","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Si Woo Kim","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Stephan Jaeger","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Sung Kang","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Sungjae Im","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Talor Gooch","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Ted Potter, Jr.","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Tom Hoge","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Tommy Fleetwood","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Tony Finau","2":"0","3":"0","4":"1","5":"0","6":"0"},{"1":"Trey Mullinax","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Troy Merritt","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Tyler Duncan","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Tyrrell Hatton","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Vaughn Taylor","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Webb Simpson","2":"0","3":"1","4":"1","5":"0","6":"1"},{"1":"Wes Roach","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Whee Kim","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Wyndham Clark","2":"0","3":"0","4":"0","5":"0","6":"0"},{"1":"Zach Johnson","2":"0","3":"0","4":"0","5":"0","6":"0"}],"options":{"columns":{"min":{},"max":[10]},"rows":{"min":[10],"max":[10]},"pages":{}}}
  </script>
</div>


<p>&nbsp;</p>

  
## *Further Research*
*****

In the future, other variables should also be studied to determine what are the
best predictors of both `StrokeAverage` and `Winner`. The PGA website has a wide
range of statistics and numerous possibilites exist to find the best 
combination. The prediction of `StrokeAverage` could probably be improved by 
incorporating more iron play statistics rather than just `AvgApproachGT100`, but
overall the models were able to predict most golfer's average to within a stroke
and a half. The prediction of `Winner` was dominated by `StrokeAverage`. Perhaps
determining better secondary predictors would increase accuracy. The models 
could also be improved by finding the optimal hurdle in deciding whether to 
predict the golfer as a winner because, in general the models predicted too 
few winners.
