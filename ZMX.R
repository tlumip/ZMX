
#Read/write a PB ZMX file
#
#Ben Stabler, stabler@pbworld.com, 080509
#Brian Gregor, Brian.J.GREGOR@odot.state.or.us, 052913
#Write updated to use 7zip - requires 7zip installed: http://www.7-zip.org
# Ben Stabler, ben.stabler@rsginc.com, 01/23/15
#Read updated to use gzcon and unz, which is much faster than before
# Ben Stabler, ben.stabler@rsginc.com, 01/22/16
#
#readZipMat("sovDistAm.zmx")
#writeZipMat(Matrix, "sovDistAm.zmx")

#Read ZMX File
readZipMat = function(FileName) {
  
  #Read matrix attributes
  NumRows = as.integer(scan(unz( FileName, "_rows"), what="", quiet=T ) )
  NumCols = as.integer(scan(unz( FileName, "_columns" ), what="", quiet=T ) )
  RowNames = strsplit(scan(unz( FileName, "_external row numbers" ), what="", quiet=T ),"," )[[1]]
  ColNames = strsplit(scan(unz( FileName, "_external column numbers" ), what="", quiet=T ),"," )[[1]]
  options(warn=-1)
  closeAllConnections()
  options(warn=0)
  
  #Initialize matrix to hold values
  Result.ZnZn = matrix( 0, NumRows, NumCols )
  rownames( Result.ZnZn ) = RowNames
  colnames( Result.ZnZn ) = ColNames
  
  #Read matrix data by row and place in initialized matrix
  RowDataEntries. = paste("row_", 1:NumRows, sep="")
  for(i in 1:NumRows) {
    Result.ZnZn[ i, ] = readBin( gzcon(unz( FileName, RowDataEntries.[i] )),
      what=double(), n=NumCols, size=4, endian="big" )
    closeAllConnections()
  }
  
  #Return the matrix
  Result.ZnZn
}

#Write ZMX File
writeZipMat = function(Matrix, FileName, SevenZipExe="C:/Program Files/7-Zip/7z.exe") {
  
  #Make a temporary directory to put unzipped files into
  tempDir = tempdir()
  print(tempDir)
  oldDir = getwd()
  setwd(tempDir)

  #Write matrix attributes
  cat(2, file="_version")
  cat(FileName, file="_name")
  cat(FileName, file="_description")
  
  cat(nrow(Matrix), file="_rows")
  cat(ncol(Matrix), file="_columns")
  cat(paste(rownames(Matrix),collapse=","), file="_external row numbers")
  cat(paste(colnames(Matrix),collapse=","), file="_external column numbers")
  
  #Write rows
  for(i in 1:nrow(Matrix)) {
    writeBin(Matrix[i,], paste("row_", i, sep=""), size=4, endian="big")
  }
  
  #Create file
  filesToInclude = normalizePath(dir(tempDir, full.names=T))
  filesToInclude = paste(paste('"', filesToInclude, '"\n', sep=""), collapse=" ")
  listFileName = paste(tempDir, "\\listfile.txt", sep="")
  write(filesToInclude, listFileName)
  setwd(oldDir)
  command = paste(paste('"', SevenZipExe, '"', sep=""), " a -tzip ", FileName, " @", listFileName, sep="")
  system(command)
}
