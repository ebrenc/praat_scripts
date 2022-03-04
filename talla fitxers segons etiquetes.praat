# A folder has to be selected including a list of wav files + homonime textgrids
# Praat will create a subfolder for each wav file
# Inside each subfolder separate wav files will be creater for each labeled intervals in any tier

form Input directory name with final slash
    comment Input files properties
        sentence directory D:\audiofiles\longfiles\
        sentence initial_substring 
        positive margin 0.001
    comment Output files properties
        boolean append_time no
endform

Create Strings as file list... list 'directory$''initial_substring$'*.wav
numberfiles = Get number of strings

for k from 1 to numberfiles
    
    select Strings list
    currenttoken$ = Get string... 'k'
    currenttoken$ = currenttoken$ - ".wav"
    Open long sound file... 'directory$''currenttoken$'.wav
    Read from file... 'directory$''currenttoken$'.TextGrid
    createFolder: directory$+currenttoken$
    
    select TextGrid 'currenttoken$'
    number_of_tiers = Get number of tiers
    
    for i from 1 to 'number_of_tiers'
        tier_name$ = Get tier name... 'i'
        number_of_intervals = Get number of intervals... 'i'
        for j from 1 to 'number_of_intervals'
            label$ = Get label of interval... 'i' 'j'
            if label$ != ""
                
                # Get time values for start and end of the interval
                begwd = Get starting point... 'i' 'j'                        
                endwd = Get end point... 'i' 'j'
                
                # Add buffers, if specified
                begfile = 'begwd'-'margin'
                endfile = 'endwd'+'margin' 
                
                # Create and save small .wav file
                select LongSound 'currenttoken$'
                Extract part... 'begfile' 'endfile' yes
                if append_time = 1
                    Write to WAV file... 'directory$''currenttoken$'\'label$'-'begwd:2'.wav
                else
                    Write to WAV file... 'directory$''currenttoken$'\'label$'.wav
                endif
                
                select Sound 'currenttoken$'
                Remove
                select TextGrid 'currenttoken$'
                
            endif
        endfor
    
    endfor
    select TextGrid 'currenttoken$'
    plus LongSound 'currenttoken$'
    Remove
endfor

select Strings list
Remove