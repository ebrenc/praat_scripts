form Select directory, file type, and tiers
    sentence source_directory D:\audiofiles\
    sentence initial_substring 
    sentence interval_tiers segments misc
    sentence point_tiers 
endform

Create Strings as file list... list 'source_directory$''initial_substring$'*.wav
number_files = Get number of strings

## Loop through files and make (or read) grids

for k from 1 to number_files
    select Strings list
    current$ = Get string... k
    Read from file... 'source_directory$''current$'
    short$ = selected$ ("Sound")
    
    full$ = "'source_directory$''short$'.TextGrid"
    if fileReadable (full$)
        Read from file... 'full$'
        Rename... 'short$'
    else
        select Sound 'short$'
        To TextGrid... "'interval_tiers$' 'point_tiers$'" 'point_tiers$'
    endif
    
    plus Sound 'short$'
    
    Edit
    
    pause Annotate tiers, then press continue...
    
    minus Sound 'short$'
    Write to text file... 'source_directory$''short$'.TextGrid
    select all
    minus Strings list
    Remove

endfor

select Strings list
Remove
clearinfo
echo Done. 'number_files' files annotated.
