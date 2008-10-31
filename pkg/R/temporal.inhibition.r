temporal.inhibition <- function(npoints,h,theta,delta,p,recent="all",t.region,discrete.time=FALSE,replace=FALSE,inhibition=TRUE)
  {
  #
  # Simulate an inhibition or a contagious temporal point process in T
  #
  # Requires Splancs.
  #  
  # Arguments:
  #  
  #  t.region: vector containing the minimum and maximum values of
  #            the time interval.
  #
  #         h: a function of the distance between times and theta.
  #            If inhibition=TRUE, h is monotone, increasing, and must tend
  #            to 1 when the distance tends to infinity. 0<= h(d,theta,delta) <= 1.
  #            Else, h is monotone, decreasing, and must tend
  #            to 1 when the distance tends to 0. 0<= h(d,theta,delta) <= 1.
  #  
  #         p: a function among "min", "max", "prod".  
  #  
  #   replace: logical allowing times repetition.
  #
  #   npoints: number of points to simulate. 
  #
  #
  # Value:
  #  pattern: list containing times t of the simulated process.
  #
  ##
  ## E. GABRIEL, 26/03/2007
  ##
  ## last modification: 31/10/2008
  ##
  ##
  
  if (missing(t.region)) t.region <- c(0,1)

  if (!(is.function(h)))
	{
      models <- c("step","gaussian")
      if (sum(h==models)==0)
       	{
          	message <- paste("this model is not implemented, please choose among: ",paste(models,"",sep=" ",collapse="and "))
          	stop(message)
        	}
      if (h=="step")
      	{
          	hk <- function(d,theta,delta)
            	{
              	res <- rep(1,length(d))
		  	if (inhibition==TRUE) res[d<=delta] <- theta
		  	else res[d>=delta] <- theta
              	return(res)
            	}
        	}
      if (h=="gaussian")
      	{
          	hk <- function(d,theta,delta)
            	{
              	if (inhibition==TRUE) 
				{
				res=NULL
				for(i in 1:length(d))
					{	
					if (d[i]<=delta) res=c(res,0)
					if (d[i]>(delta+theta/2)) res=c(res,1)
					if (d[i]>delta & d[i]<=(delta+theta/2)) res=c(res,exp(-((d[i]-delta-theta/2)^2)/(2*(theta/8)^2)))
					}
				}
		  	else
				{
				res=NULL
				for(i in 1:length(d))
					{	
					if (d[i]<delta) res=c(res,1)
					else res=c(res,exp(-((d[i]-delta)^2)/(2*(theta/8)^2)))
					}
				}
	   	  	return(res)
			}
	  	}
	}
  else
	{
       hk <- function(d,theta,delta)
            {
            res <- h(d,theta,delta)
            return(res)
		}
    	}

  pk <- function(d,h,recent,theta,delta)
 	{
      if (recent=="all")
		{
		if (p=="min") res <- min(h(d=d,theta=theta,delta=delta))
		if (p=="max") res <- max(h(d=d,theta=theta,delta=delta))
		if (p=="prod") res <- prod(h(d=d,theta=theta,delta=delta))
		}
      else
            {
            if (is.numeric(recent))
			{
                  if(recent<=length(d))
				{
				if (p=="min") res <- min(h(d=d[(length(d)-recent+1):length(d)],theta=theta,delta=delta))
				if (p=="max") res <- max(h(d=d[(length(d)-recent+1):length(d)],theta=theta,delta=delta))
				if (p=="prod") res <- prod(h(d=d[(length(d)-recent+1):length(d)],theta=theta,delta=delta))
				}
                  else
				{
				if (p=="min") res <- min(h(d=d,theta=theta,delta=delta))
				if (p=="max") res <- max(h(d=d,theta=theta,delta=delta))
				if (p=="prod") res <- prod(h(d=d,theta=theta,delta=delta))
				}
                	}
		 else stop("'recent' must be numeric")
            }
	return(res)
	}
 
  if (discrete.time==FALSE)
    ti <- runif(1,min=t.region[1],max=t.region[1]+delta)
  else
    ti <- sample(floor(t.region[1]):ceiling(t.region[1]+delta),1)
  times <-  ti
  npts <- 1
  if (inhibition==TRUE)
    {
      while(npts < npoints)
        {
          if (discrete.time==FALSE)
            ti <- runif(1,min=t.region[1],max=t.region[2])
          else
            ti <- sample(floor(t.region[1]):ceiling(t.region[2]),1)

          prob <- runif(1)
          
          if (all(abs(ti - times) > delta))
            umax <- 1
          else
            umax <- pk(d=abs(ti - times),hk,recent,theta,delta)
          if (prob<umax)
            {
              times <- c(times,ti)
              npts <- npts+1
            }
        }
    }
  else
    {
      while(npts < npoints)
        {
          prob <- runif(1)
          
          continue <- FALSE
          while(continue==FALSE)
            {
              if (discrete.time==FALSE)
                ti <- runif(1,min=t.region[1],max=t.region[2])
              else
                ti <- sample(floor(t.region[1]):ceiling(t.region[2]),1)
              
              if (abs(ti - times[npts]) < delta)
                umax <- 1            
              else
                umax <- pk(d=abs(ti - times),hk,recent,theta,delta)
              if (prob < umax)
                {
                  times <- c(times,ti)
                  npts <- npts+1
                  continue <- TRUE
                }
            }
        }
    }

  samp <- sample(1:npoints,npoints,replace=replace)
  times <- sort(times[samp])
  
  invisible(return(list(times=times,t.region=t.region)))
}


