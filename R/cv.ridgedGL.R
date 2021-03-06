cv.ridgedGL <-
function(y, X, index, lam.path = NULL, nlam = 100, thresh = 10^(-4), maxit=100, nfold=10, min.lam.frac = 0.05, alpha = 0.95, is.pen = rep(1,length(index))){


  fit <- ridgedGL(y, X, index, thresh = thresh, maxit = maxit, alpha = alpha, min.lam.frac = min.lam.frac, nlam = nlam, is.pen = is.pen)
  lam.path <- fit$lam.path

  nlam <- length(lam.path)
  lldiff <- matrix(0, ncol = nlam, nrow = nfold)

  size.small <- floor(nrow(X)/nfold)
  num.small <- (nrow(X)/nfold - floor(nrow(X)/nfold)) * nfold
  if(num.small == 0){
    num.small <- nfold
  }


  ind <- sample(1:nrow(X), replace = FALSE)
  end <- 1
  
  for(i in 1:nfold){
    if(i <= num.small){
      ind.out <- ind[end:(end + size.small - 1)]
      ind.in <- ind[-(end:(end + size.small - 1))]
      end <- end + size.small
    }
    if(i > num.small){
      ind.out <- ind[end:(end + size.small)]
      ind.in <- ind[-(end:(end + size.small))]
      end <- end + size.small + 1
    }

    newX <- X[ind.in,]
    newy <- y[ind.in]
  
    new.sol <- ridgedGL(newy, newX, index, lam.path, thresh, maxit, alpha = alpha)$beta
  
    for(k in 1:nlam){
      
      lldiff[i,k] <- lldiff[i,k] + sum((y[ind.out] - X[ind.out,] %*% new.sol[ ,k])^2) / 2
    }
    out <- paste("NFOLD ", i)
    write(out, "")
    write(" ************ ","")
  }
  cvNegLL <- apply(lldiff, 2, sum)
  cvNegLLsd <- apply(lldiff, 2, sd)*sqrt(nfold)
  lambda.min <- lam.path[which.min(cvNegLL)]
  obj <- list(cvNegLL = cvNegLL, cvNegLLsd = cvNegLLsd, lambdas = lam.path, lambda.min = lambda.min, fit = fit)
  class(obj)="cv.standGL"
  return(obj)
}

