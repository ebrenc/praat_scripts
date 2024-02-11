form Input directory name with final slash
    comment Properties
        sentence directory D:\Feina\Núria Sagarra\jv754 cut sentences\S\
        sentence output_directory D:\Feina\Núria Sagarra\jv754 cut sentences\S_mono\
        sentence initial_substring 
        sentence final_substring 
endform

Create Strings as file list... list 'directory$''initial_substring$'*'final_substring$'.wav
numberfiles = Get number of strings
createFolder: output_directory$

for k from 1 to numberfiles
    select Strings list
    currenttoken$ = Get string... 'k'
    currenttoken$ = currenttoken$ - ".wav"
    Read from file... 'directory$''currenttoken$'.wav
    Convert to mono
    Write to WAV file... 'output_directory$''currenttoken$'.wav
    select Sound 'currenttoken$'
    plus Sound 'currenttoken$'_mono
    Remove
endfor

select Strings list
Remove
