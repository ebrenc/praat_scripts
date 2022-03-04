# It runs over many files within a folder and extracts all their values into a single file.
# That file must be manually amended using Excel to get a fully operative data table.

form Select directory and measures to extract
    # Please write the slash at the end of the directory
    sentence directory D:\audiofiles\
    sentence initialsubstring 
    optionmenu variable: 1
        option pitch
        option formants
        option intensity
    optionmenu pitch_measure: 1
        option Hertz
        option semitones re 100 Hz
        option ERB
    real min_pitch_hz 75
    real max_pitch_hz 800
    endform

if variable$ = "pitch" and pitch_measure$ = "Hertz"
    variable$ = "pitch_hz"
elsif variable$ = "pitch" and pitch_measure$ = "semitones re 100 Hz"
    variable$ = "pitch_st"
elsif variable$ = "pitch" and pitch_measure$ = "ERB"
    variable$ = "pitch_erb"
endif

filedelete 'directory$''variable$'.txt
fileappend "'directory$''variable$'.txt" 'directory$''newline$''newline$'
Create Strings as file list... list 'directory$''initialsubstring$'*.wav
numberfiles = Get number of strings

for k from 1 to numberfiles
    
    select Strings list
    currenttoken$ = Get string... 'k'
    currenttoken$ = currenttoken$ - ".wav"
    Open long sound file... 'directory$''currenttoken$'.wav
    select LongSound 'currenttoken$'
    pointS = Get start time
    pointE = Get end time
    length = pointE - pointS
    View
    editor LongSound 'currenttoken$'
    
    Pitch settings: min_pitch_hz, max_pitch_hz, pitch_measure$, "autocorrelation", "automatic"
    # Advanced pitch settings: 0, 0, "yes", 15, 0.035, 0.3, 0.06, 1, 0.3
    # Formant settings: 4000, 3, 0.005, 30, 0.5
    
    Select... pointS pointE
    
    if variable$ = "intensity"
        Show analyses... no no yes no no length
        values$ = Intensity listing
    endif
    
    if variable$ = "formants"
        Show analyses... no no no yes no length
        values$ = Formant listing
    endif
    
    if variable$ = "pitch_hz" or variable$ = "pitch_st" or variable$ = "pitch_erb"
        Show analyses... no yes no no no length
        values$ = Pitch listing
    endif
    
    endeditor
    fileappend "'directory$''variable$'.txt" 'currenttoken$''newline$''values$''newline$'
    select LongSound 'currenttoken$'
    Remove
    
endfor

select all
Remove