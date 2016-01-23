# ZMX - Zip Matrix

Zip matrix (or ZMX) is a file format developed by Parsons Brinckerhoff for storing matrices in compressed form.  The file is easy to read and write and only requires a library that understands zip files. 
 
Overview

The file is a zip archive that contains the following files:

    _version
    _description
    _name
    _external column numbers
    _external row numbers
    _columns
    _rows
    row_<i>; where <i> is a matrix row of data

Here is an example of the contents of each file:

    2
    Distance matrix
    DIST
    100 101 102
    100 101 102
    3
    3
    row_1: 10.21 45.34 23.35
    row_2: 9.45 4.56 2.34
    row_3: 1.23 2.45 2.34

Each row_<i> file is a series of bytes stored as big-endian floats.
