setwd("~/Skinner/Papers/Working/NoSplitting/Significance/newSoft")
library(simCity)

myblock<-function(simdata,arguments) {
  modelcoefs<-arguments$coefs
  n.case<-dim(simdata)[1]
  rpe=cor.test(simdata$x,simdata$eta)
  rpb=cor.test(simdata$dico,simdata$eta)
  rho<-modelcoefs[1]
  rel<-modelcoefs[2]
   v<-c("ncase"=n.case,"rho"=rho,"rel"=rel,
     "rpe"=rpe$estimate,"p.pe"=rpe$p.value,"sig.pe"=(rpe$p.value<.05),
     "rpb"=rpb$estimate,"p.pb"=rpb$p.value,"sig.pb"=(rpb$p.value<.05),
     "both"=((rpe$p.value<.05)*(rpb$p.value<.05)),
     "onlype"=((rpe$p.value<.05) & (rpb$p.value>=.05)),
     "onlypb"=((rpe$p.value>=.05) & (rpb$p.value<.05)))
      as.data.frame(t(v))
}

myaggregate<-function(results) { 
  aggregate(results,list(onlype=results$onlype,onlypb=results$onlypb),mean)
}

mycut<-function(x,p) {
                    x<-x>quantile(x,p)
                    as.numeric(x)
}


model<-simc.model()
eta ~ csi  
x ~ csi  
dico ~ x ; options=trans;apply=runcut()
#
model
exogenous(model)
endogenous(model)
runcut<-function(x,q=NULL) mycut(x,.5)


myexper<-experiment(model,N=seq(20,200,20),rep=10,fun.oneblock=myblock,fun.aggregate=myaggregate)
myexper
a<-c(0,.5)
b<-seq(0,.9,.1)
c<-1
coef.by.term<-list(a,b,c)

coefs(myexper,mode="by.term.factorial")<-coef.by.term
coefs(myexper)
myexper
simc.options(verbose=T)
simdata<-run(myexper)
head(simdata)
save(simdata,file='simdata.rda')
write.csv(d,'')
