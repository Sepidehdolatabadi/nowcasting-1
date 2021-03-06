#' @title Plot for the nowcast output function
#' @description Make plots to visualize the output of the nowcast function
#' @param out output of the nowcast function.
#' @param type 'fcst', 'factors', 'eigenvalues','eigenvectors' or 'month_y'. The latter is only available for the EM method, while 'eigenvalues' and 'eigenvectors' are only available for the two stages methods.
#' @examples
#' \dontrun{
#' gdp <- month2qtr(x = USGDP$base[,"RGDPGR"])
#' gdp_position <- which(colnames(USGDP$base) == "RGDPGR")
#' base <- Bpanel(base = USGDP$base[,-gdp_position],
#'                trans = USGDP$legend$Transformation[-gdp_position],
#'                aggregate = TRUE)
#' now2sq <- nowcast(y = gdp, x = base, r = 2, p = 2, q = 2, method = '2s')
#' 
#' nowcast.plot(now2sq, type = "fcst")
#' nowcast.plot(now2sq, type = "factors")
#' nowcast.plot(now2sq, type = "eigenvalues")
#' nowcast.plot(now2sq, type = "eigenvectors")
#' 
#' base <- Bpanel(base = USGDP$base[,-gdp_position],
#'                trans = USGDP$legend$Transformation[-gdp_position],
#'                aggregate = FALSE)
#' now2sm <- nowcast(y = gdp, x = base, r = 2, p = 2, q = 2, method = '2s_agg')
#' 
#' nowcast.plot(now2sm, type = "fcst")
#' nowcast.plot(now2sm, type = "factors")
#' nowcast.plot(now2sm, type = "eigenvalues")
#' nowcast.plot(now2sm, type = "eigenvectors")
#' }
#' @export

nowcast.plot <- function(out, type = "fcst"){
  

  
  if(type == "fcst"){
    
    data <- data.frame(date = as.Date(out$yfcst), out$yfcst)
    data[max(which(is.na(data$out))),"out"] <- data[max(which(is.na(data$out))),"in."] 
    
    graphics::par(mar=c(5.1, 4.1, 4.1, 5), xpd = F)
    graphics::plot(data[,"y"], xaxt = "n", main = "",  bty = "l",
         col = "#FFFFFF", ylab = "y unit", xlab = "Time")
    graphics::axis(1, at = seq(1,nrow(data),frequency(out$yfcst)), labels = substr(data[seq(1,nrow(data),frequency(out$yfcst)),"date"],1,7), las=1, cex = 0.7)
    graphics::abline(v = seq(1,nrow(data),frequency(out$yfcst)), lty = 3, col = "#D9D9D9")
    graphics::grid(col = "#D9D9D9", nx = NA, ny = NULL)
    graphics::lines(data[,"y"], type = "l", lty = 1, col = 1)
    graphics::lines(data[,"in."], type = "l", lty = 1, lwd = 2, col = "dodgerblue")
    graphics::lines(data[,"out"], type = "l", lty = 4, lwd = 2, col = "orangered")
    graphics::par(xpd = T)
    add_legend("topright", legend=c("y","yhat","fcst"), bty = "n",
           lty = c(1,1,4), lwd = c(1,2,2), col = c(1,"dodgerblue","orangered"))
    graphics::title(main = list("Forecasting", font = 1, cex = 0.9))

  }else if(type == "eigenvalues"){
  
    if(!("reg" %in% names(out))){
      stop('Graph not available for EM method')
    }
    
    graphics::par(mar = c(5.1,4.1,4.1,2.1), xpd = F)
    eig <- out$factors$eigen$values/sum(out$factors$eigen$values)*100
    n <- min(20,length(eig))
    graphics::barplot(eig[1:n], col = "#ADD8E6", border = "steelblue", names.arg = 1:n, ylim = c(0, seq(0,100,5)[min(which(!(max(eig[1:n]) > seq(0,100,5))))]),
            xlab = "eigenvalues", ylab = "%")
    graphics::grid(col = "#D9D9D9")
    graphics::title(main = list("eigenvalues: percentage variance", font = 1, cex = 0.9))

  }else if(type == "eigenvectors"){
    
    if(!("reg" %in% names(out))){
      stop('Graph not available for EM method')
    }
    
    graphics::par(mar = c(5.1,4.1,4.1,5), xpd = F)
    vec <- out$factors$eigen$vectors[,1]
    pvec <- (out$factors$eigen$vectors[,1]^2)*100
    color <- ifelse(vec >= 0, "dodgerblue", "orangered")
    graphics::plot(pvec, main = "",  bty = "l", xaxt = "n", type = "h", ylab = "weight (%)", xlab = "variable", col = color)
    graphics::axis(1, at = seq(1,length(vec),1), labels = seq(1,length(vec),1), las=1, cex = 0.7)
    graphics::title(main = list("Variable Percentage Weight in Factor 1", font = 1, cex = 0.9))
    graphics::par(xpd = T)
    graphics::text(y = max(pvec), x = length(pvec)*1.1, labels = "signal weights:", col = 1, cex = 0.8)
    graphics::text(y = max(pvec)*0.94, x = length(pvec)*1.1, labels = "positive", col = "dodgerblue", cex = 0.8)
    graphics::text(y = max(pvec)*0.88, x = length(pvec)*1.1, labels = "negative", col = "orangered", cex = 0.8)

    
  }else if(type == "factors"){
    
    graphics::par(mar=c(5.1, 4.1, 4.1, 5), xpd = F)
    n <- ncol(data.frame(out$factors$dynamic_factors))
    stats::ts.plot(out$factors$dynamic_factors, col = c(1,"orangered","blue"), lty = c(1,2,3), gpars = list(bty = "l"))
    anos <- unique(as.numeric(substr(as.Date(out$factors$dynamic_factors),1,4)))
    graphics::grid()
    graphics::par(xpd = T)
    graphics::title(main = list("Estimated Factors", font = 1, cex = 1))
    
    if("month_y" %in% names(out)){
      leg <- colnames(out$factors$dynamic_factors)
    }else{
      leg <- paste("Factor", 1:n)
    }
    add_legend("topright", legend = leg, bty = "n",
           col = c(1,"orangered","blue"), lty = c(1,2,3), lwd = c(1,1,1,2,2,2), cex = 0.9)
    
  }else if(type == 'month_y'){
    
    if("reg" %in% names(out)){
      stop("Graph not available for '2sq' and '2sm' methods")
    }
    
    Y<-stats::ts(rep(out$yfcst[,1],each=3),end=end(qtr2month(out$yfcst[,1])),frequency = 12)
    YY<-cbind(out$month_y,Y)
    ## add extra space to right margin of plot within frame
    graphics::par(mar=c(5, 4, 4, 5.7) + 0.1,xpd=F)
    ## Plot first set of data and draw its axis
    graphics::plot(zoo::as.Date(YY), YY[,2], type='l', axes=FALSE, xlab="", ylab="", 
         col="black",lty=1,
         ylim = c(0-1.1*max(abs(range(YY[,2],na.rm = T))),0+1.1*max(abs(range(YY[,2],na.rm = T)))))
    graphics::axis(2, ylim=c(0,1),col="black",las=1)  ## las=1 makes horizontal labels
    graphics::mtext("y unit",side=2,line=2.5)
    # graphics::box()
    ## Allow a second plot on the same graph
    graphics::par(new=TRUE,xpd=F)
    ## Plot the second plot and put axis scale on right
    graphics::plot(zoo::as.Date(YY), YY[,1], xlab="", ylab="",
         axes=FALSE, type="l", col="orangered",lty=2,
         ylim = c(0-1.1*max(abs(range(YY[,1],na.rm = T))),0+1.1*max(abs(range(YY[,1],na.rm = T)))))
    ## a little farther out (line=4) to make room for labels
    graphics::mtext("monthly y unit",side=4,col="orangered",line=4)
    graphics::axis(4, ylim=c(0,1), col="orangered",col.axis="orangered",las=1)
    ## Draw the time axis
    graphics::axis(1,at = zoo::as.Date(YY)[seq(1,length(zoo::as.Date(YY)),by = 10)],labels = zoo::as.Date(YY)[seq(1,length(zoo::as.Date(YY)),by = 10)],las=1)
    graphics::mtext("Time",side=1,col="black",line=2.5)  
    ## Add Legend
    graphics::grid(col = "#D9D9D9")
    graphics::par(xpd = T)
    graphics::legend("topright",legend=c("y","monthly y"),inset=-0.17,
           text.col=c("black","orangered"),lty=c(1,2),col=c("black","red"),cex = 0.9,bty="n")
    graphics::title(main = list("Monthly Dependent Variable", font = 1, cex = 0.9))
  }
}

