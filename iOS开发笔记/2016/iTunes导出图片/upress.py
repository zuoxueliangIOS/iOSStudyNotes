import sys,os.path,shutil
import zipfile
from struct import *
from zlib import *
import md5



def getNormalizedPNG(filename):
    pngheader = "\x89PNG\r\n\x1a\n"
    
    file = open(filename, "rb")
    oldPNG = file.read()
    file.close()

    if oldPNG[:8] != pngheader:
        return None
    
    newPNG = oldPNG[:8]
    
    chunkPos = len(newPNG)
    
    # For each chunk in the PNG file    
    while chunkPos < len(oldPNG):
        
        # Reading chunk
        chunkLength = oldPNG[chunkPos:chunkPos+4]
        chunkLength = unpack(">L", chunkLength)[0]
        chunkType = oldPNG[chunkPos+4 : chunkPos+8]
        chunkData = oldPNG[chunkPos+8:chunkPos+8+chunkLength]
        chunkCRC = oldPNG[chunkPos+chunkLength+8:chunkPos+chunkLength+12]
        chunkCRC = unpack(">L", chunkCRC)[0]
        chunkPos += chunkLength + 12

        # Parsing the header chunk
        if chunkType == "IHDR":
            width = unpack(">L", chunkData[0:4])[0]
            height = unpack(">L", chunkData[4:8])[0]

        # Parsing the image chunk
        if chunkType == "IDAT":
            try:
                # Uncompressing the image chunk
                bufSize = width * height * 4 + height
                chunkData = decompress( chunkData, -8, bufSize)
                
            except Exception, e:
                # The PNG image is normalized
                return None

            # Swapping red & blue bytes for each pixel
            newdata = ""
            for y in xrange(height):
                i = len(newdata)
                newdata += chunkData[i]
                for x in xrange(width):
                    i = len(newdata)
                    newdata += chunkData[i+2]
                    newdata += chunkData[i+1]
                    newdata += chunkData[i+0]
                    newdata += chunkData[i+3]

            # Compressing the image chunk
            chunkData = newdata
            chunkData = compress( chunkData )
            chunkLength = len( chunkData )
            chunkCRC = crc32(chunkType)
            chunkCRC = crc32(chunkData, chunkCRC)
            chunkCRC = (chunkCRC + 0x100000000) % 0x100000000

        # Removing CgBI chunk        
        if chunkType != "CgBI":
            newPNG += pack(">L", chunkLength)
            newPNG += chunkType
            if chunkLength > 0:
                newPNG += chunkData
            newPNG += pack(">L", chunkCRC)

        # Stopping the PNG file parsing
        if chunkType == "IEND":
            break
        
    return newPNG

def updatePNG(filename):
    data = getNormalizedPNG(filename)
    if data != None:
	tempfil = filename.replace('/','_')	
	finname = 'icons/'+tempfil
#	print finname
        file = open(finname, "wb")
        file.write(data)
        file.close()
        return True
    return data


def analyseFile(filename):
#    print filename
    if len(filename)>4:
	if filename[-4:]=='.ipa':
	    print filename
	    temName = filename[0:-4]
	    if os.path.exists(temName)==False:
		os.mkdir(temName)
#	    print temName
	    newfile = temName+'.zip'
	    os.rename(filename,newfile)
	    zfile=zipfile.ZipFile(newfile)
	    zfile.extractall(temName)
	    tempPath = temName+'/'+'Payload'
	    filepath = os.path.join(tempPath)
	    apps = os.listdir(filepath)
            for aItem in apps:
		fp = tempPath+'/'+aItem
		finalPath = os.path.join(fp)
		
		images = os.listdir(finalPath)
		for img in images:
		    if img[-4:].lower() == '.png':
#			print img
			imgPath = finalPath+'/'+img
			imgPath = os.path.join(imgPath)
			updatePNG(imgPath)		                   
    
def func():
    if os.path.exists("icons")==False:
	os.mkdir("icons")
    files = os.listdir(os.getcwd())
    for item in files:
	analyseFile(item)


if __name__ == "__main__":
    if len(sys.argv)==2:
	if os.path.exists("icons")==False:
	    os.mkdir("icons")
	analyseFile(sys.argv[1])
    else:
	func()
