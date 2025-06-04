function(directions){
  f <- function(spec,param){
    return(directions$instructions[[param]][[spec[[param]]]])
  }
}