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
