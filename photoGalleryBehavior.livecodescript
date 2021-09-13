script "photoGalleryBehavior"
-- Scrolling with 
on rawKeyDown pKey
   switch pKey
      case 65309
         set the vScroll of me to the vScroll of me - 25
         break
      case 65308
         set the vScroll of me to the vScroll of me + 25
         break
      case 65311
         set the hScroll of me to the hScroll of me - 25
         break
      case 65310
         set the hScroll of me to the hScroll of me +25
         break
      default
         pass rawKeyDown
   end switch
      
end rawKeyDown

on preOpenControl
   set the vscroll of me to 0
   set the hscroll of me to 0
end preOpenControl
--------------------------------
constant kPhotoGrid = "PhotoGrid ", kSpace = "    "
local sSetSeletedPhoto

setProp cPhotosArray pArray
    local tNumKeys, tNumGroups, tImagesEx, tNumCol, tPhotoGrid, tCurrentCol = 1, tBehaviorGrid, tBehaviorGridScropt
    
    
    lock screen; lock messages
    
    if pArray is an Array then
        
        put "on mouseUp" & cr & kSpace & "local tItem" & cr & kSpace & "set the itemdel to space" & cr & kSpace & "put item 2 of the short name of me into tItem" & cr & kSpace & "setSeletedPhoto tItem" & cr & kSpace & "pass mouseUp" & cr & "end mouseUp" into tBehaviorGridScropt
        if there is not a button"behaviorGrid" of me 
        then create button"behaviorGrid" in me
        
        set the script of button"behaviorGrid" of me to tBehaviorGridScropt
        set the visible of button"behaviorGrid" of me to false
        put the long id of button"behaviorGrid" of me into tBehaviorGrid
        
        put the cNumCol of me into tNumCol
        if tNumCol is not a number then
            put 3 into tNumCol
            set the cNumCol of me to 3
        end if
        
        put the number of lines of the keys of pArray into tNumKeys
        put the number of images of me into tNumGroups
        
        
        repeat with c = 1 to tNumGroups
            put kPhotoGrid & c into tPhotoGrid
            
            if there is grp tPhotoGrid of me  
            then delete grp tPhotoGrid of me
            
        end repeat
        
        local tMargins, tLeft, tTop, tRaw, tSize
        
        put the margins of me into tMargins
        put the left of me + tMargins into tLeft
        put the top of me + tMargins into tTop
        
        if the vScrollbar of me then
            put trunc(((the width of me - the scrollbarWidth of me)- (tMargins * (tNumCol + 1) )) / tNumCol) into tSize
        else
            put trunc((the width of me - (tMargins * (tNumCol + 1) )) / tNumCol) into tSize
        end if
        
        # Templates
        set the lockloc of  templateImage to true
        set the width of templateImage to tSize
        set the height of templateImage to tSize
        set the alwaysBuffer of templateImage to false
        set the threeD of templateImage to true
        set the resizequality of templateImage to "normal"
        set the showBorder of templateImage to false
        
        set the style of the templateGraphic to rectangle
        set the opaque of the templateGraphic to true
        set the antialiased of the templateGraphic to false
        set the lineSize of the templateGraphic to 1
        set the backgroundColor of the templateGraphic to 0,0,0
        set the foregroundColor of the templateGraphic to 0,255,64
        set the blendLevel of the templateGraphic to 50
        set the width of the templateGraphic to tSize
        set the height of the templateGraphic to tSize
        set the visible of the templateGraphic to false
        set the lockloc of  templateGraphic to true
        
        set the showBorder of templateGroup to false
        set the margins of templateGroup to 0
        set the width of the templateGroup to tSize
        set the height of the templateGroup to tSize
        set the lockloc of  templateGroup to false
        set the behavior of templateGroup to tBehaviorGrid
        
        local tLongIdGrp
        
        repeat with i = 1 to tNumKeys
            put kPhotoGrid & i into tPhotoGrid
            
            if there is not a grp tPhotoGrid of me then
                create grp tPhotoGrid in me
                put it into tLongIdGrp
                create grc "backgrounGrid" in tLongIdGrp
                create image tPhotoGrid in tLongIdGrp
                create grc tPhotoGrid in tLongIdGrp
            end if
            
            if tCurrentCol is 1 then 
                put tPhotoGrid into tRaw
            end if
            
            // Properties of PhotoGrid
            set the filename of image tPhotoGrid of me to pArray[i]["thumbnail"]
            set the cPathPhoto of image tPhotoGrid of me to pArray[i]["image"]
            set the cNumberPhoto of image tPhotoGrid of me to i
            
            set the left of image tPhotoGrid of me  to tLeft
            set the top of image tPhotoGrid of me  to tTop
            
            if tCurrentCol is not tNumCol then
                put the right of image tPhotoGrid of me  + tMargins into tLeft
            else
                put the left of me  + tMargins into tLeft
                put the bottom of image tRaw of me  + tMargins into tTop
                put 0 into tCurrentCol
            end if
            
            
            set the rect of grc "backgrounGrid"  of grp tPhotoGrid of me to the rect of image tPhotoGrid of me
            set the visible of grc "backgrounGrid"  of grp tPhotoGrid of me to true
            set the blendLevel of grc "backgrounGrid"  of grp tPhotoGrid of me to 100
            
            set the rect of grc tPhotoGrid of me to the rect of image tPhotoGrid of me
            set the lockloc of grp tPhotoGrid of me  to true
            
            add 1 to tCurrentCol
        end repeat
    else
        local tListID
        put the childControlIDs of me into tListID
        
        repeat for each line tID in tListID
            if there is a control id tID of me and the short name of control id tID of me begins with "PhotoGrid" then
                delete control id tID of me
            end if
        end repeat
    end if
    
    reset the templateImage
    reset the templateGraphic
    reset the templateGroup
    
    set the vscroll of me to 0
    set the hscroll of me to 0
    
    
    unlock messages; unlock screen
    pass cPhotosArray
end cPhotosArray

local sMouseDown, sScrolling, sStartVScroll, sStartHScroll, sStartLoc, sScrollbarDrag
before mouseDown
    put true into sMouseDown
end mouseDown

before mouseMove pNewMouseH, pNewMouseV
    
    if  sMouseDown is true and sScrolling is not true and sScrollbarDrag is not true then
        
        if sStartLoc is a point and sScrolling is false then
            put _distance(item 1 of sStartLoc, item 2 of sStartLoc, pNewMouseH, pNewMouseV) >= 10 into sScrolling
            
        else
            put false into sScrolling
            put  pNewMouseH, pNewMouseV into sStartLoc
        end if
        
    end if
    pass mouseMove
end mouseMove

on scrollbarDrag pNewPosition
   put true into sScrollbarDrag
   pass scrollbarDrag
end scrollbarDrag

before mouseUp
    put false into sMouseDown
    
    _selecctPhoto
end mouseUp

before mouseRelease pButtonNumber
    put false into sMouseDown
    _selecctPhoto
    pass mouseRelease
end mouseRelease


private function _distance pXo, pYo, pX, pY
   return sqrt((pXo - pX)^2 + (pYo - pY)^2 )
end _distance


private command _selecctPhoto
    
    if the mouse is down 
    then exit _selecctPhoto
    
    if sScrolling is not true 
    then send "seletedPhoto sSetSeletedPhoto"
    
    delete local sScrolling
    delete local sStartLoc
    delete local sScrollbarDrag
    
end _selecctPhoto

on seletedPhoto pPhotoNumber

end seletedPhoto

on resizeControl
    if the long id of target is the long id of me  then
        set the cPhotosArray of me to the cPhotosArray of me
    end if
end resizeControl

command setSeletedPhoto pNumber
   put pNumber into sSetSeletedPhoto
end setSeletedPhoto

