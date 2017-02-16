fit_crawl <- function(d) {
  init = list(a = c(coordinates(d)[1, 1], 0,
                    coordinates(d)[1, 2], 0),
              P = diag(c(10 ^ 2, 10 ^ 2,
                         10 ^ 2, 10 ^ 2)))
  
  fixPar = c(1, 1, NA, NA)
  
  constr = list(lower = c(-Inf, -4), upper = (c(Inf, 4)))
  
  ln_prior = function(par) {
    dnorm(par[2], 4, 4, log = TRUE)
  }
  
  lap_prior = function(par) {
    -abs(par[2] - 4) / 5
  }
  reg_prior = function(par) {
    dt(par[2] - 3,
       df = 1,
       log = TRUE)
  }
  
  fit <- crawl::crwMLE(
    #crawl::displayPar(
    mov.model =  ~ 1,
    err.model = list(
      x =  ~ ln.sd.x - 1,
      y =  ~ ln.sd.y - 1,
      rho =  ~ error.corr
    ),
    data = d,
    Time.name = "date_time",
    initial.state = init,
    fixPar = fixPar,
    #prior = ln_prior,
    constr = constr,
    attempts = 1,
    control = list(
      maxit = 30,
      trace = 0,
      REPORT = 1
    ),
    initialSANN = list(
      maxit = 1000,
      trace = 1,
      REPORT = 1
    )
  )
  fit
}
