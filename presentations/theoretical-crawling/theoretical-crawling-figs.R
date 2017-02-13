setwd("~/research/projects/crawl_workshop/presentations/theoretical-crawling")
library(cowplot)
library(dplyr)
library(mvtnorm)
theme_update(plot.background = element_rect(fill=gray(0.95)))

###
# Random walk
###
set.seed(123)
rw_dat = data.frame(
  time = 0:100,
  x = cumsum(c(0,rnorm(100,0,0.1))),
  y = cumsum(c(0,rnorm(100,0,0.1)))
  )

p1 = ggplot(data=rw_dat) + geom_path(aes(x=x, y=y), lwd=0.25) + ggtitle("random walk (n = 100)") +
  theme(axis.text = element_blank(), axis.ticks = element_blank())
save_plot("rw.pdf", p1, base_height = 3, base_width = 4)

###
# VAR(1)
###
set.seed(123)
n = 100
mu_bar = c(0,0)
gamma = 0.9
sigma=0.1*matrix(c(1,0.0,0.0,1), 2, 2)

var_dat = data.frame(
  time = 0:n,
  x = c(0,rep(NA, n)),
  y = c(0,rep(NA, n))
)
for(i in 2:(n+1)){
  var_dat[i,2:3] = gamma*var_dat[i-1,2:3] + (1-gamma)*mu_bar + rmvnorm(1, sigma=sigma)
}

p2 = ggplot(data=var_dat) + geom_path(aes(x=x, y=y), lwd=0.5) + 
  stat_ellipse(aes(x=x,y=y), col="red", lwd=1.1) + ggtitle(paste0("VAR(1) (n = ",n,")")) +
  theme(axis.text = element_blank(), axis.ticks = element_blank())
save_plot("var.pdf", p2, base_height = 3, base_width = 4)

###
# Discrete-time CRW
###

dtcrw_dat = var_dat %>% mutate(x = cumsum(x), y=cumsum(y))

p3 = ggplot(data=dtcrw_dat) + geom_path(aes(x=x, y=y), lwd=0.5)  + ggtitle(paste0("discrete time CRW (n = ",n,")")) +
  theme(axis.text = element_blank(), axis.ticks = element_blank())
save_plot("dtcrw.pdf", p3, base_height = 3, base_width = 4)

###
# BM example
###
set.seed(123)
n=10000
bm_dat = data.frame(
  time = 0:n,
  x = cumsum(c(0,rnorm(n,0,0.001))),
  y = cumsum(c(0,rnorm(n,0,0.001)))
) 

p4 = ggplot(data=bm_dat) + geom_path(aes(x=x, y=y), lwd=0.25) + ggtitle("Brownian motion") + 
  theme(axis.text = element_blank(), axis.ticks = element_blank())
save_plot("bm.pdf", p4, base_height = 3, base_width = 4)


###
# OU 
###
set.seed(123)
n = 10000
mu_bar = c(0,0)
beta = exp(-3)
corr = round(exp(-beta),2)
sigma=0.00001*matrix(c(1,0.0,0.0,1), 2, 2)

ou_dat = data.frame(
  time = 0:n,
  x = c(0,rep(NA, n)),
  y = c(0,rep(NA, n))
)
for(i in 2:(n+1)){
  ou_dat[i,2:3] = exp(-beta)*ou_dat[i-1,2:3] + (1-exp(-beta))*mu_bar + rmvnorm(1, sigma=sigma)
}

p5 = ggplot(data=ou_dat) + geom_path(aes(x=x, y=y), lwd=0.25) + ggtitle("Ornstein-Uhlenbeck motion", subtitle = paste0("corr = ", corr)) +
  theme(axis.text = element_blank(), axis.ticks = element_blank())
save_plot("ou.pdf", p5, base_height = 3, base_width = 4)

###
# Continuous-time CRW
###

ctcrw_dat = ou_dat %>% mutate(x = cumsum(x), y=cumsum(y))

p6 = ggplot(data=ctcrw_dat) + geom_path(aes(x=x, y=y), lwd=0.5)  + ggtitle("Continuous-time CRW") +
  theme(axis.text = element_blank(), axis.ticks = element_blank())
save_plot("ctcrw.pdf", p6, base_height = 3, base_width = 4)



