# It runs over many files within a folder and extracts all their values into a single file.

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
Create Strings as file list... list 'directory$''initialsubstring$'*.wav
numberfiles = Get number of strings

if variable$ = "formants"
    fileappend "'directory$''variable$'.txt" file'tab$'time'tab$'f1'tab$'f2'tab$'f3'newline$'
else
    fileappend "'directory$''variable$'.txt" file'tab$'time'tab$''variable$''newline$'
endif

for k from 1 to numberfiles
    
    select Strings list
    currenttoken$ = Get string... 'k'
    currenttoken$ = currenttoken$ - ".wav"
    Read from file... 'directory$''currenttoken$'.wav
    Read from file... 'directory$''currenttoken$'.textgrid
    select Sound 'currenttoken$'
    pointS = Get start time
    pointE = Get end time
    length = pointE - pointS
    
    if variable$ = "intensity"
        select TextGrid 'currenttoken$'
        number_of_tiers = Get number of tiers
        select Sound 'currenttoken$'
        To Intensity: 100, 0, "yes"
        number_of_frames = Get number of frames
        for iframe to number_of_frames
            time = Get time from frame: iframe
            intensity = Get value in frame: iframe
            if intensity != undefined
                appendInfo: currenttoken$, tab$, fixed$ (time, 6), tab$, fixed$ (intensity, 3)
                for tier_number to number_of_tiers
                    select TextGrid 'currenttoken$'
                    is_interval = Is interval tier... 'tier_number'
                    if is_interval = 1
                        tier_name$ = Get tier name... 'tier_number'
                        if tier_name$ = ""
                            tier_name$ = "Tier " + string$('tier_number')
                        endif
                        interval_number = Get interval at time: tier_number, time
                        interval_label$ = Get label of interval: tier_number, interval_number
                        appendInfo: tab$, tier_name$, tab$, interval_label$
                    endif
                endfor
                appendInfo: newline$
                select Intensity 'currenttoken$'
            endif
        endfor
        select Intensity 'currenttoken$'
        Remove
    endif
    
    if variable$ = "formants"
        select TextGrid 'currenttoken$'
        number_of_tiers = Get number of tiers
        select Sound 'currenttoken$'
        To Formant (burg): 0, 5, 5500, 0.025, 50
         number_of_frames = Get number of frames
        for iframe to number_of_frames
            time = Get time from frame: iframe
            formant1 = Get value at time: 1, time, "hertz", "linear"
            formant2 = Get value at time: 2, time, "hertz", "linear"
            formant3 = Get value at time: 3, time, "hertz", "linear"
            if formant1 != undefined
                appendInfo: currenttoken$, tab$, fixed$ (time, 6), tab$, fixed$ (formant1, 3), tab$, fixed$ (formant2, 3), tab$, fixed$ (formant3, 3)
                for tier_number to number_of_tiers
                    select TextGrid 'currenttoken$'
                    is_interval = Is interval tier... 'tier_number'
                    if is_interval = 1
                        tier_name$ = Get tier name... 'tier_number'
                        if tier_name$ = ""
                            tier_name$ = "Tier " + string$('tier_number')
                        endif
                        interval_number = Get interval at time: tier_number, time
                        interval_label$ = Get label of interval: tier_number, interval_number
                        appendInfo: tab$, tier_name$, tab$, interval_label$
                    endif
                endfor
                appendInfo: newline$
                select Formant 'currenttoken$'
            endif
        endfor
        select Formant 'currenttoken$'
        Remove
    endif
    
    if variable$ = "pitch_hz" or variable$ = "pitch_st" or variable$ = "pitch_erb"
        select TextGrid 'currenttoken$'
        number_of_tiers = Get number of tiers
        select Sound 'currenttoken$'
        To Pitch: 0, min_pitch_hz, max_pitch_hz
        number_of_frames = Get number of frames
        for iframe to number_of_frames
            time = Get time from frame: iframe
            pitch = Get value in frame: iframe, pitch_measure$
            if pitch != undefined
                appendInfo: currenttoken$, tab$, fixed$ (time, 6), tab$, fixed$ (pitch, 3)
                for tier_number to number_of_tiers
                    select TextGrid 'currenttoken$'
                    is_interval = Is interval tier... 'tier_number'
                    if is_interval = 1
                        tier_name$ = Get tier name... 'tier_number'
                        if tier_name$ = ""
                            tier_name$ = "Tier " + string$('tier_number')
                        endif
                        interval_number = Get interval at time: tier_number, time
                        interval_label$ = Get label of interval: tier_number, interval_number
                        appendInfo: tab$, tier_name$, tab$, interval_label$
                    endif
                endfor
                appendInfo: newline$
                select Pitch 'currenttoken$'
            endif
        endfor
        select Pitch 'currenttoken$'
        Remove
    endif
    
    appendFile: "'directory$''variable$'.txt", info$( )
    clearinfo
    select TextGrid 'currenttoken$'
    plus Sound 'currenttoken$'
    Remove
    
endfor
select Strings list
Remove
