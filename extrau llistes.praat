# It runs over many files within a folder and extracts all their values into a single file.
# It allows the user to extract information from homonime textgrids placed in the same folder.
# For each interval tier, it adds 2 additional columns for each point: tier name and interval label.
# For each point tier, it adds 4 additional columns for each point: floor (immediately previous) point label and its distance in time, and ceiling (immediately next) point label and its distance in time.

form Select directory and measures to extract
    # Please write the slash at the end of the directory
    sentence directory D:\audiofiles\
    sentence initialsubstring 
    optionmenu variable: 1
        option pitch
        option formants
        option intensity
    real min_pitch_hz 75
    real max_pitch_hz 800
    boolean extract_textgrid_information 1
    word specific_tier_to_extract Phonetics
endform

filedelete 'directory$''variable$'.txt
Create Strings as file list... list 'directory$''initialsubstring$'*.wav
numberfiles = Get number of strings

if variable$ = "pitch"
    fileappend "'directory$''variable$'.txt" file'tab$'time'tab$'pitch_hz'tab$'pitch_st100'tab$'pitch_erb
    object_of_interest$ = "Pitch"
elsif variable$ = "formants"
    fileappend "'directory$''variable$'.txt" file'tab$'time'tab$'f1'tab$'f2'tab$'f3
    object_of_interest$ = "Formant"
elsif variable$ = "intensity"
    fileappend "'directory$''variable$'.txt" file'tab$'time'tab$'intensity
    object_of_interest$ = "Intensity"
endif

if specific_tier_to_extract$ != ""
    fileappend "'directory$''variable$'.txt" 'tab$''specific_tier_to_extract$''newline$'
else
    fileappend "'directory$''variable$'.txt" 'newline$'
endif

for k from 1 to numberfiles
    select Strings list
    currenttoken$ = Get string... 'k'
    currenttoken$ = currenttoken$ - ".wav"
    Read from file... 'directory$''currenttoken$'.textgrid
    number_of_tiers = Get number of tiers
    Read from file... 'directory$''currenttoken$'.wav
    if variable$ = "pitch"
        To Pitch: 0, min_pitch_hz, max_pitch_hz
    elsif variable$ = "formants"
        To Formant (burg): 0, 5, 5500, 0.025, 50
    elsif variable$ = "intensity"
        To Intensity: 100, 0, "yes"
    endif
    number_of_frames = Get number of frames
    for iframe to number_of_frames
        time = Get time from frame: iframe
        if variable$ = "pitch"
            pitch_hz = Get value in frame: iframe, "Hertz"
            pitch_st100 = Get value in frame: iframe, "semitones re 100 Hz"
            pitch_erb = Get value in frame: iframe, "ERB"
            current_value = Get value in frame: iframe, "Hertz"
        elsif variable$ = "formants"
            formant1 = Get value at time: 1, time, "hertz", "linear"
            formant2 = Get value at time: 2, time, "hertz", "linear"
            formant3 = Get value at time: 3, time, "hertz", "linear"
            current_value = Get value at time: 1, time, "hertz", "linear"
        elsif variable$ = "intensity"
            intensity = Get value in frame: iframe
            current_value = Get value in frame: iframe
        endif
        if current_value != undefined
            if variable$ = "pitch"
                appendInfo: currenttoken$, tab$, fixed$ (time, 4), tab$, fixed$ (pitch_hz, 4), tab$, fixed$ (pitch_st100, 4), tab$, fixed$ (pitch_erb, 4)
            elsif variable$ = "formants"
                appendInfo: currenttoken$, tab$, fixed$ (time, 4), tab$, fixed$ (formant1, 4), tab$, fixed$ (formant2, 4), tab$, fixed$ (formant3, 4)
            elsif variable$ = "intensity"
                appendInfo: currenttoken$, tab$, fixed$ (time, 4), tab$, fixed$ (intensity, 4)
            endif
            if extract_textgrid_information = 1
                if specific_tier_to_extract$ = ""
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
                        elsif is_interval = 0
                            tier_name$ = Get tier name... 'tier_number'
                            if tier_name$ = ""
                                tier_name$ = "Tier " + string$('tier_number')
                            endif
                            appendInfo: tab$, tier_name$
                            floor_point_number = Get low index from time: tier_number, time
                            ceiling_point_number = Get high index from time: tier_number, time
                            if floor_point_number != 0
                                floor_point_label$ = Get label of point: tier_number, floor_point_number
                                floor_point_time = Get time of point: tier_number, floor_point_number
                                floor_point_distance = time - floor_point_time
                                appendInfo: tab$, fixed$ (floor_point_distance, 4), tab$, floor_point_label$
                            else
                                appendInfo: tab$, tab$
                            endif
                            number_of_points = Get number of points: tier_number
                            if ceiling_point_number <= number_of_points
                                ceiling_point_label$ = Get label of point: tier_number, ceiling_point_number
                                ceiling_point_time = Get time of point: tier_number, ceiling_point_number
                                ceiling_point_distance = ceiling_point_time - time
                                appendInfo: tab$, fixed$ (ceiling_point_distance, 4), tab$, ceiling_point_label$
                            endif
                        endif
                    endfor
                else
                    for tier_number to number_of_tiers
                        select TextGrid 'currenttoken$'
                        is_interval = Is interval tier... 'tier_number'
                        if is_interval = 1
                            tier_name$ = Get tier name... 'tier_number'
                            if tier_name$ = specific_tier_to_extract$
                                interval_number = Get interval at time: tier_number, time
                                interval_label$ = Get label of interval: tier_number, interval_number
                                appendInfo: tab$, interval_label$
                            endif
                        elsif is_interval = 0
                            tier_name$ = Get tier name... 'tier_number'
                            if tier_name$ = specific_tier_to_extract$
                                floor_point_number = Get low index from time: tier_number, time
                                ceiling_point_number = Get high index from time: tier_number, time
                                if floor_point_number != 0
                                    floor_point_label$ = Get label of point: tier_number, floor_point_number
                                    floor_point_time = Get time of point: tier_number, floor_point_number
                                    floor_point_distance = time - floor_point_time
                                    appendInfo: tab$, fixed$ (floor_point_distance, 4), tab$, floor_point_label$
                                else
                                    appendInfo: tab$, tab$
                                endif
                                number_of_points = Get number of points: tier_number
                                if ceiling_point_number <= number_of_points
                                    ceiling_point_label$ = Get label of point: tier_number, ceiling_point_number
                                    ceiling_point_time = Get time of point: tier_number, ceiling_point_number
                                    ceiling_point_distance = ceiling_point_time - time
                                    appendInfo: tab$, fixed$ (ceiling_point_distance, 4), tab$, ceiling_point_label$
                                endif
                            endif
                        endif
                    endfor
                endif
            endif
            appendInfo: newline$
        endif
        select 'object_of_interest$' 'currenttoken$'
    endfor
    Remove
    appendFile: "'directory$''variable$'.txt", info$( )
    clearinfo
    select TextGrid 'currenttoken$'
    plus Sound 'currenttoken$'
    Remove
endfor
select Strings list
Remove
