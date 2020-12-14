script "frlGalleryHelper"

constant kVersion = "1.0.5"

setProp cVersion
   return kVersion
end cVersion

# This function is to facilitate obtaining the route to the image files and their corresponding miniatures.
# Parameters
# pFolderIn: Path to the folder where the images are.
# pSizeThumbnails: Thumbnail size. For now they are only square. If pSizeThumbnails is false is not create Thumbnails.

function pathFromGalleryFiles pFolderIn, pSizeThumbnails
   lock screen
   lock messages

   local tLongIdGrp, tLongIdImg, tFolderOut
   local tListImages, tListThumbnailsArray, tBufferHiddenImages, tJPEGQuality

   set the itemdel to "/"
   replace "\" with "/" in pFolderIn
   put the item 1 to - 1 of pFolderIn into pFolderIn
   put pFolderIn & "/.thumbnails/" into tFolderOut

   put _getImagesFiles(pFolderIn) into tListImages

   if the number of lines of tListImages is 0 or there is not a Folder pFolderIn then return empty
   if pSizeThumbnails is not a number and pSizeThumbnails is not a boolean then put 300 into pSizeThumbnails

   if there is not a Folder tFolderOut then create folder tFolderOut

   if _writePermissionIn(tFolderOut) is false then
      put the documents folder & the short name of this wd & "/.thumbnails/" into tFolderOut
      create folder tFolderOut
   end if


   local tFileOut, tCounter = 0

   if pSizeThumbnails is not false then

   	if pSizeThumbnails is true or pSizeThumbnails is not a integer then
         put 300 into pSizeThumbnails
      end if

      // Work to thumbnails
      put the bufferHiddenImages into tBufferHiddenImages
      put the JPEGQuality into tJPEGQuality
      set the bufferHiddenImages to false
      set the locklocation of templateGroup to true
      set the vscrollbar of templateGroup to true
      set the hscrollbar of templateGroup to true
      set the margins of templateGroup to 0
      set the scrollbarwidth of templateGroup to 0

      if the environment is "mobile" then
         set the resizequality of templateImage to "normal"
      else
         set the resizequality of templateImage to "best"
      end if

      set the locklocation of templateImage to true
      set the alwaysBuffer of templateImage to false
      set the threeD of templateImage to true
      set the JPEGQuality to 85

      create grp "WorkThumbnails"
      put it into tLongIdGrp
      create image"Thumbnails" in tLongIdGrp
      put it into tLongIdImg

      set the rect of tLongIdGrp to 0, 0, pSizeThumbnails, pSizeThumbnails
      set the loc of tLongIdGrp to - 1000, - 500 #> Took the group off the screen

      repeat for each line tFilename in tListImages
         add 1 to tCounter
         set the filename of tLongIdImg to tFilename
         put tFolderOut & item - 1 of tFilename into tFileOut

         _thumbnailsSize tLongIdImg, tLongIdGrp,pSizeThumbnails
         _exportImage tLongIdGrp, tFileOut

         put tFileOut into tListThumbnailsArray[tCounter]["thumbnail"]
         put tFilename into tListThumbnailsArray[tCounter]["image"]

      end repeat

      -- Reset all
      delete tLongIdGrp

      set the bufferHiddenImages to tBufferHiddenImages
      set the JPEGQuality to tJPEGQuality

      reset the templateGroup
      reset the templateImage
   else

      repeat for each line tFilename in tListImages
         add 1 to tCounter

         put tFolderOut & item - 1 of tFilename into tFileOut

         put tFileOut into tListThumbnailsArray[tCounter]["thumbnail"]
         put tFilename into tListThumbnailsArray[tCounter]["image"]

      end repeat
   end if

   unlock messages
   unlock screen
   return tListThumbnailsArray
end pathFromGalleryFiles

# Optimize images in a folder.
# Parameter
# pMaxSize: Maximum size of the images
# pJPGQuality: The quality of JPG
# pFolderIn: Folder where the images to continue are located.
# pFolderOut: The processed images will be placed in this folder. If not specified they will be overwritten.
# Returns the name of the files they optimized.

command optimizeImage pFolderIn, pFolderOut, pMaxSize, pJPGQuality
   local tJPEGQuality, tListImages, tBufferHiddenImages, tLongIdImg
   local tFileOut

   lock screen
   lock messages

   put the JPEGQuality into tJPEGQuality
   put the bufferHiddenImages into tBufferHiddenImages

   if pFolderOut is empty or there is not a Folder pFolderOut then put pFolderIn into pFolderOut
   set the itemdel to "/"
   replace "\" with "/" in pFolderIn
   replace "\" with "/" in pFolderOut
   if char -1 of pFolderIn is "/" then delete char -1 of pFolderIn
   if char -1 of pFolderOut is "/" then delete char -1 of pFolderOut

   put _getImagesFiles(pFolderIn) into tListImages

   if _writePermissionIn(pFolderOut) is false or the number of lines of tListImages is 0 then
      set the JPEGQuality to tJPEGQuality
      set the bufferHiddenImages to tBufferHiddenImages
      exit optimizeImage
   end if

   if pMaxSize is not a number then put 1200 into pMaxSize
   if pJPGQuality is not a number then put 85 into pJPGQuality

   // Work to thumbnails
   put the bufferHiddenImages into tBufferHiddenImages
   set the bufferHiddenImages to false

   if the environment is "mobile" then
      set the resizequality of templateImage to "good"
   else
      set the resizequality of templateImage to "best"
   end if

   set the locklocation of templateImage to true
   set the alwaysBuffer of templateImage to false
   set the threeD of templateImage to true
   set the JPEGQuality to pJPGQuality

   create image"OptimizeImage"
   put it into tLongIdImg

   repeat for each line tFilename in tListImages
      set the filename of tLongIdImg to tFilename
      put pFolderOut &"/"& item - 1 of tFilename into tFileOut

      if the formattedWidth of tLongIdImg > pMaxSize or the formattedheight of tLongIdImg > pMaxSize then
         _scaleImage tLongIdImg, pMaxSize, pMaxSize
         set the imageData of tLongIdImg to the imageData of tLongIdImg
         _exportImage tLongIdImg, tFileOut, false
      end if

   end repeat

   delete tLongIdImg
   set the JPEGQuality to tJPEGQuality
   set the bufferHiddenImages to tBufferHiddenImages
   reset the templateImage

   unlock messages
   unlock screen
end optimizeImage


command createThumbnail pFilePath, pOutFolder, pSizeThumbnails
   lock screen
   lock messages

   local tLongIdGrp, tLongIdImg

   if there is not a file pFilePath or  there is not a folder pOutFolder then exit createThumbnail

   replace "\" with "/" in pFilePath
   replace "\" with "/" in pOutFolder

   if pSizeThumbnails is true or pSizeThumbnails is not a integer then
      put 300 into pSizeThumbnails
   end if

   set the itemdel to "/"

   set the locklocation of templateGroup to true
   set the vscrollbar of templateGroup to true
   set the hscrollbar of templateGroup to true
   set the rect of templateGroup to 0,0,pSizeThumbnails,pSizeThumbnails
   set the margins of templateGroup to 0
   set the scrollbarwidth of templateGroup to 0
   set the resizequality of templateImage to "best"
   set the locklocation of templateImage to true
   set the alwaysBuffer of templateImage to false
   set the threeD of templateImage to true
   set the JPEGQuality to 100

   create group "thumbnailView"
   put it into tLongIdGrp
   create image"Thumbnails" in tLongIdGrp
   put it into tLongIdImg

   set the filename of tLongIdImg to pFilePath

   _thumbnailsSize tLongIdImg, tLongIdGrp, 110

   _exportImage tLongIdGrp, pOutFolder & ( last item of pFilePath), true

   -- Reset all
   delete tLongIdGrp
   reset the templateGroup
   reset the templateImage

   unlock screen
   unlock messages
end createThumbnail

-----------------------------------------------------------------------
-------------------- private command and function ---------------------
-----------------------------------------------------------------------

// Find all files type images.
function _getImagesFiles pPathFolder
   local tImages, tFiles

   set the itemdel to "."

   if there is no an Folder pPathFolder then return empty

   if char -1 of pPathFolder is among the items of "/.\" then delete char -1 of pPathFolder
   put files(pPathFolder) into tFiles

   repeat for each line tFile in tFiles
      if item - 1 of tFile is among the items of "png.jpg.jpeg.gif.bmp"then
         put pPathFolder &"/"& tFile & return after tImages
      end if
   end repeat

   return char 1 to -2 of tImages
end _getImagesFiles

private command _exportImage pLongId, pPathFile, pSnapshot
   local tExtension

   set the itemdel to "."

   put the item - 1 of pPathFile into tExtension

   if pSnapshot is not false then
      switch tExtension
         case "PNG"
            export snapshot from pLongId to file pPathFile as PNG
            break
         case "GIF"
            export snapshot from pLongId to file pPathFile as GIF
            break
         default
            export snapshot from pLongId to file pPathFile as JPEG
      end switch
   else
      switch tExtension
         case "PNG"
            export pLongId to file pPathFile as PNG
            break
         case "GIF"
            export pLongId to file pPathFile as GIF
            break
         default
            export pLongId to file pPathFile as JPEG
      end switch
   end if
end _exportImage

// Function to know if you can write to a folder.
private function _writePermissionIn pPathFolder
   replace "\" with "/" in pPathFolder
   if char -1 of pPathFolder is "/" then delete char -1 of pPathFolder

   if there is not a folder pPathFolder then return false

   put "write" into URL ("file:" & pPathFolder & "/testing.txt")

   if there is a file(pPathFolder & "/testing.txt") then
      delete file (pPathFolder & "/testing.txt")
      return true
   end if

   return false
end _writePermissionIn


-- Size of the thumbnails.
private command _thumbnailsSize pLongIdImg, pLongIdGrp, pSizeThumbnails
   local trueW, trueH

   put the formattedWidth of pLongIdImg into trueW
   put the formattedHeight of pLongIdImg into trueH

   switch
      case trueW > trueH
         set the Width of pLongIdImg to pSizeThumbnails / (trueH/trueW)
         set the Height of pLongIdImg to pSizeThumbnails
         break
      case trueW < trueH
         set the Width of pLongIdImg to pSizeThumbnails
         set the Height of pLongIdImg to pSizeThumbnails / (trueW/trueH)
         break
      default
         set the Width of pLongIdImg to pSizeThumbnails
         set the Height of pLongIdImg to pSizeThumbnails
   end switch

   set the loc of pLongIdImg to the loc of pLongIdGrp
   set the top of pLongIdImg to the top of pLongIdGrp
end _thumbnailsSize


private command _scaleImage pLongIdImage, pWidth, pHeight
   local tTrueWidth, tTrueHeight, tAspectRatio

   put the formattedWidth of pLongIdImage into tTrueWidth
   put the formattedheight of pLongIdImage into tTrueHeight

   if tTrueHeight is 0 or tTrueWidth is 0 or (tTrueWidth < pWidth and tTrueHeight < pHeight)
   then exit _scaleImage

   put min(pHeight/tTrueHeight, pWidth/tTrueWidth) into tAspectRatio
   set the height of pLongIdImage to tTrueHeight * tAspectRatio
   set the width of pLongIdImage to tTrueWidth * tAspectRatio
end _scaleImage
