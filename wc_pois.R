library(readr)
results <- read_csv("results.csv")

teams<-c("Egypt","Uruguay","Russia","Saudi Arabia",
         "Spain","Portugal","Iran","Morocco",
         "France","Denmark","Peru","Australia",
         "Croatia","Argentina","Nigeria", "Iceland",
         "Brazil","Switzerland","Serbia","Costa Rica",
         "Mexico","Germany","Korea Republic","Sweden",
         "England","Belgium","Tunisia","Panama",
         "Japan","Senegal","Colombia","Poland")

rteamsall<-results[-seq(22336),]
allteams<-levels(as.factor(c(rteamsall$home_team,rteamsall$away_team)))
wcteams<-which(allteams %in% teams)
rdatall<-cbind(match(rteamsall$home_team,allteams),
               match(rteamsall$away_team,allteams),
               rteamsall$home_score,rteamsall$away_score)


att<-rep(0,282)
dfd<-rep(0,282)

for (jj in 1:20){
  # update a
  att<-sapply(1:282,function(i){
    gf<-c(rdatall[rdatall[,1]==i,3],rdatall[rdatall[,2]==i,4])
    gdfd<-dfd[c(rdatall[rdatall[,1]==i,2],rdatall[rdatall[,2]==i,1])]
    tatt<-gf+gdfd
    av<-mean(tatt[gf!=0],trim=0.05)
    return(ifelse(is.na(av),0,av))
  })
  # update b
  dfd<-sapply(1:282,function(i){
    ga<-c(rdatall[rdatall[,1]==i,4],rdatall[rdatall[,2]==i,3])
    gatt<-att[c(rdatall[rdatall[,1]==i,2],rdatall[rdatall[,2]==i,1])]
    tdfd<-gatt-ga
    dv<-mean(tdfd[ga!=0],trim=0.05)
    return(ifelse(is.na(dv),0,dv))
  })
}
performance<-rbind(att,dfd)
colnames(performance)<-allteams

# trim the data to throw away really weak teams
top100<-names(rev(sort(colSums(performance)))[1:100])
rteamsall<-rteamsall[rteamsall$home_team %in% top100 & rteamsall$away_team %in% top100,  ]
allteams<-top100
wcteams<-which(allteams %in% teams)

rdatall<-cbind(match(rteamsall$home_team,allteams),
               match(rteamsall$away_team,allteams),
               rteamsall$home_score,rteamsall$away_score)

att<-rep(0,100)
dfd<-rep(0,100)

XX<-Reduce('rbind',lapply(1:dim(rdatall)[1], function(i){
  r<-matrix(0,2,200)
  r[1,rdatall[i,1]]<-1
  r[1,100+rdatall[i,2]]<-1
  r[2,100+rdatall[i,1]]<-1
  r[2,rdatall[i,2]]<-1
  return(r)
}))
YY<-as.vector(t(rdatall[,3:4]))
lmod<-cv.glmnet(XX,YY,family = 'poisson',intercept=F)

rgoal<-function(a,b){
  a<-which(top100==teams[a])
  b<-which(top100==teams[b])
  r<-matrix(0,2,200)
  r[1,a]<-1
  r[1,100+b]<-1
  r[2,100+a]<-1
  r[2,b]<-1
  rp<-predict(lmod,r,type='response')
  r<-c(rpois(1,rp[1]),
       rpois(1,rp[2]))
  names(r)<-top100[c(a,b)]
  return(r)
}


GGames<-bdiag(rep(list(matrix(c(1,-1,0,0,
                                1,0,-1,0,
                                1,0,0,-1,
                                0,1,-1,0,
                                0,1,0,-1,
                                0,0,1,-1),
                              byrow = T,6,4)),8))

run_sim<-function(){
  # Group stage
  Gresult<-matrix(0,48,2)
  GGoals<-matrix(0,32,2)
  Gwins<-matrix(0,32,32)
  for (i in 1:48){
    playing=which(GGames[i,]!=0)
    gr<-rgoal(playing[1],playing[2])
    print(gr)
    Gresult[i,]=gr
    GGoals[playing[1],1]<-gr[1]
    GGoals[playing[1],2]<-gr[2]
    GGoals[playing[2],1]<-gr[2]
    GGoals[playing[2],2]<-gr[1]
    if (gr[1]>gr[2]){
      Gwins[playing[1],playing[2]]<-1
    } else {
      Gwins[playing[2],playing[1]]<-1
    }
  }
  rr<-(Gresult[,1]==Gresult[,2])*0+(Gresult[,1]>Gresult[,2])-(Gresult[,1]<Gresult[,2])
  GS<-matrix(0,8,4)
  for (i in 1:8){
    rg<-rr[(6*(i-1)+1):(6*i)]
    gs<-c(sum(c(0,1,3)[2+rg[c(1,2,3)]]),
          sum(c(0,1,3)[2+c(-rg[1],rg[4:5])]),
          sum(c(0,1,3)[2+c(-rg[2],-rg[4],rg[6])]),
          sum(c(0,1,3)[2+c(-rg[3],-rg[5],-rg[6])]))
    GS[i,]<-gs
  }
  GD<-GGoals[,1]-GGoals[,2]
  GS<-GS+
    matrix(GD/(max(GD)+1),byrow = T,8,4)+
    matrix(GGoals[,1]/100,byrow = T,8,4)
  KO<-matrix(0,8,2)
  for(i in 1:8){
    scores<-GS[i,]
    r<-which(scores==max(scores))
    if (length(r)==2){
      if (Gwins[r[1]+4*(i-1),r[2]+4*(i-1)]){
        KO[i,]<-r+4*(i-1)
      } else if (Gwins[r[2]+4*(i-1),r[1]+4*(i-1)]) {
        KO[i,]<-rev(r)+4*(i-1)
      } else {
        sample(r)+4*(i-1)
      }
    } else if (length(r)==3){
      sample(r)[1:2]
    } else if (length(r)==4){
      sample(r)[1:2]
    } else {
      KO[i,1]<-r+4*(i-1)
      r<-which(scores==sort(scores)[3])
      if (length(r)>1){
        if (Gwins[r[1]+4*(i-1),r[2]+4*(i-1)]){
          KO[i,2]<-r[1]+4*(i-1)
        } else {
          KO[i,2]<-r[length(r)]+4*(i-1)
        }
      } else {
        KO[i,2]<-r+4*(i-1)
      }
    }
  }
  print("######## Group Stage ########")
  print(matrix(teams[KO],8,2,dimnames = list(c('A','B','C','D',
                                               'E','F','G','H'),
                                             c('First','Runner-up'))))
  
  KO[,2]<-(KO[,2])[c(2,1,4,3,6,5,8,7)]
  
  KOresult<-matrix(0,8,2)
  print("++++++++++++++++++++")
  for (i in 1:8){
    kr<-rgoal(KO[i,1],KO[i,2])
    if (kr[1]==kr[2]) {
      kr=kr+rgoal(KO[i,1],KO[i,2])
      print("Extended time")
    }
    if (kr[1]==kr[2]){
      print("Penalty")
      while (kr[1]==kr[2]) {
        kr=kr+rgoal(KO[i,1],KO[i,2])
      }
    }
    print(kr)
    print("++++++++++++++++++++")
    KOresult[i,]<-kr
  }
  KO2<-sapply(1:8, function(i)ifelse(KOresult[i,1]>KOresult[i,2],KO[i,1],KO[i,2]))
  print("######## Round of 16 ########")
  print(matrix(teams[KO2],8,1,dimnames = list(c('A1B2','A2B1','C1D2','C2D1',
                                                'E1F2','E2F1','G1H2','G2H1'))))
  KO2<-matrix(KO2[c(1,3,5,7,2,4,6,8)],byrow = T,4,2)
  
  KO2result<-matrix(0,4,2)
  print("++++++++++++++++++++")
  for (i in 1:4){
    kr<-rgoal(KO2[i,1],KO2[i,2])
    if (kr[1]==kr[2]) {
      kr=kr+rgoal(KO2[i,1],KO2[i,2])
      print("Extended time")
    }
    if (kr[1]==kr[2]){
      print("Penalty")
      while (kr[1]==kr[2]) {
        kr=kr+rgoal(KO2[i,1],KO2[i,2])
      }
    }
    print(kr)
    print("++++++++++++++++++++")
    KO2result[i,]<-kr
  }
  KO3<-sapply(1:4, function(i)ifelse(KO2result[i,1]>KO2result[i,2],KO2[i,1],KO2[i,2]))
  print("######## Quarter Final ########")
  print(matrix(teams[KO3],4,1,dimnames = list(c('A1B2 v C1D2',
                                                'E1F2 v G1H2',
                                                'A2B1 v C2D1',
                                                'E2F1 v G2H1'))))
  KO3<-matrix(KO3,byrow = T,2,2)
  KO3result<-matrix(0,2,2)
  print("++++++++++++++++++++")
  for (i in 1:2){
    kr<-rgoal(KO3[i,1],KO3[i,2])
    if (kr[1]==kr[2]) {
      kr=kr+rgoal(KO3[i,1],KO3[i,2])
      print("Extended time")
    }
    if (kr[1]==kr[2]){
      print("Penalty")
      while (kr[1]==kr[2]) {
        kr=kr+rgoal(KO3[i,1],KO3[i,2])
      }
    }
    print(kr)
    print("++++++++++++++++++++")
    KO3result[i,]<-kr
  }
  KO4<-sapply(1:2, function(i)ifelse(KO3result[i,1]>KO3result[i,2],KO3[i,1],KO3[i,2]))
  print("######## Semi Final ########")
  print(matrix(teams[KO4],1,2,dimnames = list('team',c('Left','Right'))))
  
  kr<-rgoal(KO4[1],KO4[2])
  if (kr[1]==kr[2]) {
    kr=kr+rgoal(KO4[1],KO4[2])
    print("Extended time")
  }
  if (kr[1]==kr[2]){
    print("Penalty")
    while (kr[1]==kr[2]) {
      kr=kr+rgoal(KO4[1],KO4[2])
    }
  }
  print(kr)
  print("++++++++++++++++++++")
  winner<-KO4[which.max(kr)]
  print("######## Final ########")
  print(teams[winner])
}

