# World-Cup-Simulator
Using the historical National team performance data to predict goals. 

## Data

I used the data from 
https://www.kaggle.com/martj42/international-football-results-from-1872-to-2017
It contains all the officially documented national team data, including date, goals, stadiums, and type of game (friendly, regional cups, etc). 

## Model
This being a toy project, consider a easy model: between the two teams X and Y,
- There are two parameters for each team: an attack/offense working rate A and a defense working rate D. 
- Goals for each team follows a Poisson distribution. For team X this is Pois(A_x-D_y), and for team Y this is Pois(A_y-D_x). 
- Zeros: When A_x-D_y<0, that is, when one team's attach cannot penatrate the other's defense, the random variable is truncated at 0. 

## Implementation
The MLE for this mixture distribution does not have closed form. I used a non-rigorous iterative algorithm to alternatively optimize the vector A and D. 
