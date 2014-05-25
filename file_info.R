## file_info
## Check all the files required to build the dataset.
## -- Assemble their basenames and dirnames
## -- Check that they exist
## -- Check their contents are roughly correct (mainly # of rows & columns)
## -- Aggregate these results in a data frame for return from this routine
file_info <- function( dataset, source.dir = "~/wearable/UCI HAR Dataset", verbose = TRUE ){
  
  ## Guard against zealous user leaving / on end of source.dir
  if( length(grep( "[/]$", source.dir ) ) != 0 ){
    if( verbose ) warning( "Removing trailing slash from source.dir=", source.dir )
    source.dir <- substr( source.dir, 1, length(source.dir)-1 )  
  }
  
  ## Check it exists
  if( ! file.exists(source.dir)){
    stop( "Can't find source.dir=", source.dir )
  }
  
  ## dataset dir name, check it exists
  set.dir <- paste( source.dir, "/", dataset, sep="" )
  if( ! file.exists(set.dir)){
    stop( "Can't find dataset directory ", set.dir )
  }
  
  ## Inertial data dir, check it exists
  inert.dir <- paste( set.dir, "/Inertial Signals", sep="" )
  if( ! file.exists(inert.dir)){
    stop( "Can't find Inertial Signals directory ", inert.dir )
  }
  
  ## First three files
  ## First one being activity.label.txt
  ## Use first frame to return overall result, hence name
  if( verbose ) message( " ... checking activity_labels.txt" )
  result.frame <- check_HAR_file( dir=source.dir, name="activity_labels.txt", cols_expected=2 )
  if( ! result.frame$ok ) warning( "Something wrong with activity_labels.txt")
  
  ## Feature descriptors
  if( verbose ) message( " ... checking features.txt" )
  feature.frame <- check_HAR_file( dir=source.dir, name="features.txt", cols_expected=2 )
  if( ! feature.frame$ok ) warning( "Something wrong with features.txt")
  ## Start combining frames
  result.frame <- rbind.names(list(result.frame,feature.frame))
  
  ## subject identifiers for the study
  ## This tells us how many records should be in the othr files
  subject.file <- paste( "subject_", dataset, ".txt", sep="" )
  if( verbose ) message( " ... checking ", subject.file )
  subject.frame <- check_HAR_file( dir=set.dir, name=subject.file, cols_expected=1 )
  if( ! subject.frame$exists ) stop ( "Can't find ", subject.file, " -- no point going on" )
  result.frame <- rbind.names(list(result.frame,subject.frame))
  
  ## Important numbers!
  ntest <- result.frame[subject.file,"rows"]
  if( verbose ) message( subject.file," contains ", ntest, " test records" )
  nfeature <- result.frame[ "features.txt","rows"]
  if( verbose ) message( "features.txt contains ", nfeature, " feature descriptors" )
  
  ## Next two files ...
  X.file <- paste( "X_", dataset, ".txt", sep="" )
  if( verbose ) message( " ... checking ", X.file )
  X.frame <- check_HAR_file( dir=set.dir, name = X.file, rows_expected = ntest, cols_expected = nfeature )
  if( ! X.frame$ok ) warning( "Something wrong with ", X.file )
  result.frame <- rbind.names(list(result.frame,X.frame))
  
  y.file <- paste( "y_", dataset, ".txt", sep="" )
  if( verbose ) message( " ... checking ", y.file )
  y.frame <- check_HAR_file( dir=set.dir, name = y.file, rows_expected = ntest )
  if( ! y.frame$ok ) warning( "Something wrong with ", y.file )
  result.frame <- rbind.names(list(result.frame,y.frame))
  
  ## And loop over Inertial Signals files ...
  inert.types <- c( "body_acc", "body_gyro", "total_acc" )
  for( inert.type in inert.types ){
    for( axis in c( "x", "y", "z") ){
      inert.file <- paste( inert.type, "_", axis, "_", dataset, ".txt", sep="" )
      if( verbose ) message( " ... checking ", inert.file )
      inert.frame <- check_HAR_file( dir=inert.dir, name = inert.file, rows_expected = ntest, cols_expected=128)
      if( ! inert.frame$ok ) warning ( "Something wrong with ", inert.file )
      result.frame <- rbind.names(list(result.frame,inert.frame))
    }
  }
  
result.frame
}

## check_HAR_file
## Generates full filename, does existence check, optionally check specified number of rows and columns
## crack=TRUE  forces row/column count even if not requested
check_HAR_file <- function( dir=NULL, name=NULL, rows_expected=NULL, cols_expected=NULL, crack=FALSE ){
  
  if( is.null(dir) | is.null(name)) stop( "Must specify AT LEAST dir and name in check_HAR_file" )
  
  fullpath <- paste( dir, "/", name, sep="" )
  if( ! file.exists(fullpath)){
    return(data.frame( row.names=name, file=fullpath, exists=FALSE, ok=FALSE, rows=NA, columns=NA ))}
  
  if( is.null(rows_expected) & is.null(cols_expected) & ! crack ){
    return(data.frame( row.names=name, file=fullpath, exists=TRUE, ok=TRUE, rows=NA, columns=NA ))}

  the.frame <- read.table(fullpath,header=FALSE)
  the.dims <- dim(the.frame)
  actual.rows <- the.dims[1]
  actual.cols <- the.dims[2]
  is_ok <- ((( is.null(rows_expected)) || ( actual.rows == rows_expected )) &
           (( is.null(cols_expected)) || ( actual.cols == cols_expected )))
  return(data.frame( row.names=name, file=fullpath, exists=TRUE, ok=is_ok, rows=actual.rows, columns=actual.cols ))
}

## rbind.names
## This is a little service routine to join dataframes with row labels
rbind.names <- function(framelist){
  require(plyr)
  temp <- rbind.fill(framelist)
  rownames(temp) <- unlist(lapply(framelist, row.names))
  temp
}
