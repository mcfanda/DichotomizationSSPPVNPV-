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
       "rpb"=rpb$estimate,"p.pb"=rpb$p.value,"sig.pb"=(rpb$p.value<.05))
  as.data.frame(t(v))
}

myaggregate<-function(results) { 
  a<-aggregate(results,list(sigpe=results$sig.pe,sigpb=results$sig.pb),mean)
  b<-aggregate(results[,1],list(sigpe=results$sig.pe,sigpb=results$sig.pb),length)
  as.data.frame(c(a,b))

}

mycut<-function(x,p) {
  x<-x>quantile(x,p)
  as.numeric(x)
}


mydist<-function(N,means=NULL,excov=NULL) {
  csi<-matrix(rbinom(N,1,means),ncol=1)
  colnames(csi)<-'csi'
  csi
}

model<-simc.model()
eta~csi;edist=rnorm(0,1);options=beta
x ~ csi  ;options=beta
dico ~ x ; options=trans;apply=runcut()
#
exdist(model)<-mydist
exmeans(model)<-.7
model
exogenous(model)
endogenous(model)
runcut<-function(x,q=NULL) mycut(x,.5)


myexper<-experiment(model,N=seq(20,200,20),rep=100,fun.oneblock=myblock,fun.aggregate=myaggregate)
myexper
a<-c(0,.1,.2,.3,.4,.5,.6,.7)
b<-seq(0.3,.9,.1)
b
c<-1
coef.by.term<-list(a,b,c)
coef.by.term
coefs(myexper,mode="by.term.factorial")<-coef.by.term
head(coefs(myexper))
myexper
simc.options(verbose=T)
simdata<-run(myexper)
save(simdata,file='simdata_unbalanced.rda')
info=list(myexper)
head(simdata)
save(info,file='experiment_unbalaced.rda')
write.csv(simdata,file='experiment_unbalanced.csv')
names(simdata)



