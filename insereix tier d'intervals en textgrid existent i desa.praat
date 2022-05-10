form Select directory, file type, and tiers
    sentence source_directory D:\audiofiles\
    sentence initial_substring 
    sentence new_tier_name nsyll
    sentence duplicate_the_following_tier silences
    boolean remove_interval_labels 1
    boolean place_at_bottom 1
    boolean pause_to_annotate 1
endform

Create Strings as file list... list 'source_directory$''initial_substring$'*.TextGrid
number_files = Get number of strings

## Loop through files and add tiers

for k from 1 to number_files
    select Strings list
    current$ = Get string... k
    Read from file... 'source_directory$''current$'
    short$ = selected$ ("TextGrid")
    ntiers = Get number of tiers
    
    if duplicate_the_following_tier$ = ""
        if place_at_bottom = 1
            Insert interval tier: ntiers+1, new_tier_name$
        else
            Insert interval tier: 1, new_tier_name$
        endif
    else
        for ntier from 1 to ntiers
            ntiername$ = Get tier name: ntier
            if ntiername$ = duplicate_the_following_tier$
                if place_at_bottom = 1
                    Duplicate tier: ntier, ntiers+1, new_tier_name$
                else
                    Duplicate tier: ntier, 1, new_tier_name$
                endif
            endif
        endfor
    endif
    
    if remove_interval_labels = 1
        nintervals = Get number of intervals: ntiers+1
        for ninterval from 1 to nintervals
            Set interval text: ntiers+1, ninterval, ""
        endfor
    endif
    
    if pause_to_annotate = 1
        Edit
        pause Annotate tiers, then press continue...
    endif
    
    Write to text file... 'source_directory$''short$'.TextGrid
    select all
    minus Strings list
    Remove

endfor

select Strings list
Remove
clearinfo
echo Done. 'number_files' textgrids modified.
