
#Read/write ZMX files
#Ben Stabler, stabler@pbworld.com, 11/11/12
######################################################################

#load libraries
import sys, os.path, zipfile, struct, array

#write ZMX file
def writeZMX(fileName, zoneNames, mat):

	#calculate numZones to remove trailing zeros
	numZones = len(zoneNames)

	#write header files
	z = zipfile.ZipFile(fileName, "w")
	z.writestr("_version", str(2))
	z.writestr("_description", fileName)
	z.writestr("_name", os.path.splitext(os.path.basename(fileName))[0])
	z.writestr("_external column numbers", ",".join(zoneNames))
	z.writestr("_external row numbers", ",".join(zoneNames))
	z.writestr("_columns", str(numZones))
	z.writestr("_rows", str(numZones))
	
	#write rows, trim unused zones, big-endian floats
	for i in range(1,numZones+1):
		fileNameRow = "row_" + str(i)
		data = struct.pack(">" + "f"*numZones,*mat[i-1][0:numZones])
		z.writestr(fileNameRow, data)

	#close connections
	z.close()

#read ZMX file
def readZMX(fileName):

	#read header files
	z = zipfile.ZipFile(fileName, "r")
	version = z.read("_version")
	description = z.read("_description")
	name = z.read("_name")
	zoneNames = z.read("_external column numbers")
	rowZoneNames = z.read("_external row numbers")
	columns = z.read("_columns")
	rows = int(z.read("_rows"))
	
	#read rows, big-endian floats
	mat = []
	for i in range(1,rows+1):
		fileNameRow = "row_" + str(i)
		data = z.read(fileNameRow)
		mat.append(struct.unpack(">" + "f"*rows,data))
	
	#close connections
	z.close()
	
	#return matrix data, zone names, matrix name
	return(mat, zoneNames, name)

