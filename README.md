# World-Cup-Simulator
Using the historical National team performance data to predict goals. 

## Data

I used the data from 
https://www.kaggle.com/martj42/international-football-results-from-1872-to-2017
It contains all the officially documented national team data, including date, goals, stadiums, and type of game (friendly, regional cups, etc). Here we only used those of the top 100 teams, because teams tends to score way more on teams that ranks really low, and some middle tier teams enjoys playing low ranked teams very much, which inflated their attack stats. 

## Model
This being a toy project, consider a easy model: between the two teams X and Y,
- There are two parameters for each team: an attack/offense working rate A and a defense working rate D. 
- Goals for each team follows a Poisson distribution. For team X this is Pois(A_x-D_y), and for team Y this is Pois(A_y-D_x). 

## Implementation
use the package glmnet, we find a sparse (because some country doesn't really have a meaningful stats) representation of the parameters A and D. 
Specifically, we fitted a penalized poisson regression. 

## Simulated results for games Jun.28 and on

Japan   Poland 

     1      1 
     
Senegal Colombia 

     1      0 
     
England Belgium 

     2      1 
     
Tunisia Panama 

     1      1 
     
++++++++++++++++++++ Round of 16 ++++++++++++++++++++

Uruguay Portugal 

     0      2 
     
Spain   Russia 

     2      1 
     
France  Argentina 

     0      3 
     
Croatia Denmark (Extended time)

     1      0 
     
Brazil  Mexico 

     4      0 
     
Sweden  Switzerland (Extended time)

     3      1 
     
England Japan 

     1      0 
     
Senegal Belgium 

     1      2 
     
++++++++++++++++++++ Quarter Final ++++++++++++++++++++

Portugal Argentina 

     1       0 
     
Brazil   England 

     1       2 
     
Spain    Croatia 

     3       2 
     
Sweden   Belgium 

     1       0 
     
++++++++++++++++++++ Semi Final ++++++++++++++++++++

Portugal  England (Extra time + Penalty)

     4       6 
     
Spain     Sweden 

     1       0 
     
++++++++++++++++++++ Final ++++++++++++++++++++

England   Spain 

     2       1    (Extra time + Penalty)

