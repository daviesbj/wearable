## See if aggregate() is doing what I think
dumb_aggregate <- function( the.frame, subject, activity, variable="tBodyAcc-mean()-X" ){
  rows <- the.frame$subject == subject & the.frame$activity == activity
  values <- the.frame[rows,variable]
  result <- sum(values) / length(values)
  result
}