## run_analysis
## Starts with a directory containing UCI HAR Dataset.zip (or whatever you've called it)
## Then it does the following:
##   (1) Loads and merges the test and train datasets as a single file
##   (2) Optionally saves them as one honkin' big CSV, if the full_csv parameter is a nonempty string
##   (3) Creates a frame containing only the -mean() and -std() columns
##   (4) By default, saves to a file called UCI_HAR_means.csv
##   (5) Summarizes columns to their means by activity & subject
##   (6) By default, saves to a file called UCI_HAR_summary.csv
##
## The filenames used for steps 2, 4 and 6 are set in the string parms full_csv, means_csv and summary_csv
## By default, you get a running commentary. To suppress it, set logical parm verbose=FALSE
##
## Necessary auxiliary functions included at the end of this file

run_analysis <- function( verbose=TRUE, startfile='UCI HAR Dataset.zip',
                          full_csv='', means_csv='UCI_HAR_means.csv', summary_csv='UCI_HAR_summary.csv' ){
  
  if( ! file.exists(startfile)) stop( "FAIL: please setwd() to a directory containing ", startfile )
  if(verbose) message( "Unzipping ", startfile )
  unzip(startfile)
  if( ! file.exists('UCI HAR Dataset')) stop( "Something went wrong unzipping" )
  
  dataset.dir <- paste( getwd(), '/UCI HAR Dataset', sep='' )
  
  if( verbose ) message( "Assembling test dataset" )
  test.frame <- assemble_dataset( 'test', source.dir=dataset.dir, verbose=verbose )
  
  if( verbose ) message( "Assembling train dataset" )
  train.frame <- assemble_dataset( 'train', source.dir=dataset.dir, verbose=verbose )
  
  if( verbose ) message( "Merging datasets" )
  full.frame <- full.frame <- rbind( test.frame, train.frame )
  rm( test.frame, train.frame )
  if( full_csv != '' ){
    if(verbose) message( "Writing full dataset to ", full_csv)
    write.csv(full.frame,full_csv,row.names=FALSE)
  }
  
  if(verbose) message( "Selecting only -mean() and -std() columns" )
  ##
  ## CHANGE FOLLOWING STATEMENT TO CHANGE FEATURE SELECTION
  ##
  wanted.cols <- grep( 'subject|activity|-mean[(]|-std[(]', colnames(full.frame) )
  meanavg.frame <- full.frame[,wanted.cols]
  if( means_csv != '' ){
    if(verbose) message( "Writing means/stds dataset to ", means_csv)
    write.csv(meanavg.frame,means_csv,row.names=FALSE)
  }
  
  if(verbose) message( "Calculating averages by activity and subject" )
  interim.agg.frame<-aggregate(meanavg.frame,by=list(meanavg.frame$subject,meanavg.frame$activity),mean)
  agg.headings.wanted <- colnames(interim.agg.frame)[!grepl('subject|activity', colnames(interim.agg.frame))]
  agg.frame <- interim.agg.frame[,agg.headings.wanted]
  agg.headings.wanted[1]<-'activity'
  agg.headings.wanted[2]<-'subject'
  colnames(agg.frame)<-agg.headings.wanted
  if( summary_csv != '' ){
    if(verbose) message( "Writing summary dataset to ", summary_csv)
    write.csv(agg.frame,summary_csv,row.names=FALSE)
  }
}


## assemble_dataset
## Returns a dataframe for a UCI HAR dataset contained in & below the directory that the distribution unzips into
## Key files in unzip directory, per-set fils in named subdirectory
## Checks file availability, and if so assembles the dataset
## Changes activity to a factor, and adds headings to 561 feature values and 3x3x128 raw data values per record
## Returns a dataframe, optionally saves it to a file
assemble_dataset <- function( set.name, source.dir = "~/wearable/UCI HAR Dataset", verbose=TRUE, savefile = "" ){
  
  if( verbose ) message( " ... checking file availability for dataset '", set.name, "'" )
  file.list <- file_info( set.name, source.dir = source.dir, verbose = verbose )
  if( any( ! file.list$ok) ) stop( "Something wrong with data files -- run file_info and investigate")
  if( verbose ) message( " ... looks good!" )
  
  if( verbose ) message( " ... reading ", "activity_labels.txt" )
  activity_labels.frame <- read.table( as.character(file.list["activity_labels.txt",]$file) )
  
  if( verbose ) message( " ... reading ", "features.txt" )
  features_desc.frame   <- read.table( as.character(file.list["features.txt",]$file) )
  
  subject.file <- paste( "subject_", set.name, ".txt", sep="" )
  if( verbose ) message( " ... reading ", subject.file )
  subject.frame <- read.table( as.character(file.list[subject.file,]$file) )
  colnames(subject.frame)<-c('subject')
  
  y.file <- paste( "y_", set.name, ".txt", sep="" )
  if( verbose ) message( " ... reading ", y.file )
  y.frame <- read.table( as.character(file.list[y.file,]$file) )
  y.factor <- activity_labels.frame$V2[y.frame$V1]
  y.frame2 <- as.data.frame(y.factor)
  colnames(y.frame2) <- c('activity')
  
  X.file <- paste( "X_", set.name, ".txt", sep="" )
  if( verbose ) message( " ... reading ", X.file )
  X.frame <- read.table( as.character(file.list[X.file,]$file) )
  colnames(X.frame) <- features_desc.frame$V2
  
  if( verbose ) message( " ... starting assembly" )
  result.frame<-cbind(subject.frame,y.frame2,X.frame)
  rm(X.frame)
  
  for( inert.type in c( "body_acc", "body_gyro", "total_acc" ) ){
    for( axis in c( "x", "y", "z") ){
      inert.id <- paste( inert.type, "_", axis, sep="" )
      inert.file <- paste( inert.id, "_", set.name, ".txt", sep="" )
      if( verbose ) message( " ... reading ", inert.file )
      inert.frame <- read.table( as.character(file.list[inert.file,]$file) )
      inert.labels <- sapply( c(1:128), function(x){ sprintf( paste( inert.id, '.', "%03d", sep="" ), x ) } )
      colnames(inert.frame) <- inert.labels
      result.frame <- cbind(result.frame,inert.frame)
      rm(inert.frame)
    }
  }
  
  if( savefile != "" ){
    if( verbose ) message(  " ... attempting to write to ", savefile )
    write.csv( result.frame, savefile )
  }
  
  result.frame
}


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
