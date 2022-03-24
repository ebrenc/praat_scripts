# It runs over many files within a folder and extracts lists of values (pitch, formants, intensity), one for each time frame.
# It can extract the entire file or only for label-matching intervals ("specific_labels_to_extract") for a specific tier ("specific_tier_to_extract").
# If label-matching intervals are specified, a proportion interest of that interval can be requested so that only the time frames occupying that central region will be extracted.
# It allows the user to extract information from homonime textgrids placed in the same folder.
# It can extract the coocurrent information for all tiers or just for a specific tier ("specific_coocurrent_tier").
# For each interval tier, it adds 2 additional columns for each time frame: tier name and interval label.
# For each point tier, it adds 4 additional columns for each time frame: floor (immediately previous) point label and its distance in time, and ceiling (immediately next) point label and its distance in time.

form Select directory and measures to extract
    # Please write the slash at the end of the directory:
    sentence directory D:\audiofiles\
    sentence initialsubstring 
    optionmenu variable: 1
        option pitch
        option formants
        option intensity
    real min_pitch_hz 75
    real max_pitch_hz 800
    boolean extract_textgrid_information 1
    word specific_tier_to_extract Segments
    # Please use spaces to separate labels:
    sentence specific_labels_to_extract tS V
    word specific_coocurrent_tier Words
    # Please specify a number between 0 and or 1
    positive interval_proportion_to_extract_from 1/3
endform

specific_labels_to_extract$# = splitByWhitespace$#(specific_labels_to_extract$)

filedelete 'directory$''variable$'.txt
Create Strings as file list... list 'directory$''initialsubstring$'*.wav
numberfiles = Get number of strings

if variable$ = "pitch"
    fileappend "'directory$''variable$''initialsubstring$'.txt" file'tab$'time'tab$'pitch_hz'tab$'pitch_st100'tab$'pitch_erb'newline$'
    object_of_interest$ = "Pitch"
elsif variable$ = "formants"
    fileappend "'directory$''variable$''initialsubstring$'.txt" file'tab$'time'tab$'f1'tab$'f2'tab$'f3'newline$'
    object_of_interest$ = "Formant"
elsif variable$ = "intensity"
    fileappend "'directory$''variable$''initialsubstring$'.txt" file'tab$'time'tab$'intensity'newline$'
    object_of_interest$ = "Intensity"
endif

for k from 1 to numberfiles
    select Strings list
    currenttoken$ = Get string... 'k'
    currenttoken$ = currenttoken$ - ".wav"
    if extract_textgrid_information = 1
        Read from file... 'directory$''currenttoken$'.textgrid
        number_of_tiers = Get number of tiers
    endif
    Read from file... 'directory$''currenttoken$'.wav
    currenttoken$ = replace$ (currenttoken$, " ", "_", 0)
    currenttoken$ = replace$ (currenttoken$, ",", "_", 0)
    currenttoken$ = replace$ (currenttoken$, "'", "_", 0)
    currenttoken$ = replace$ (currenttoken$, ".", "_", 0)
    currenttoken$ = replace$ (currenttoken$, "(", "_", 0)
    currenttoken$ = replace$ (currenttoken$, ")", "_", 0)
    if variable$ = "pitch"
        To Pitch: 0, min_pitch_hz, max_pitch_hz
    elsif variable$ = "formants"
        To Formant (burg): 0, 5, 5500, 0.025, 50
    elsif variable$ = "intensity"
        To Intensity: 100, 0, "yes"
    endif
    if size(specific_labels_to_extract$#) > 0
        for tier_number to number_of_tiers
            select TextGrid 'currenttoken$'
            is_interval = Is interval tier: tier_number
            if is_interval = 1
                tier_name$ = Get tier name: tier_number
                if tier_name$ = specific_tier_to_extract$
                    number_of_intervals = Get number of intervals: tier_number
                    # appendInfo: number_of_intervals, newline$
                    for interval_number from 1 to number_of_intervals
                    select TextGrid 'currenttoken$'
                        interval_label$ = Get label of interval: tier_number, interval_number
                        for i from 1 to size(specific_labels_to_extract$#)
                            
                            if specific_labels_to_extract$#[i] = interval_label$
                            
                                interval_start = Get start point: tier_number, interval_number
                                interval_end = Get end point: tier_number, interval_number
                                
                                if interval_proportion_to_extract_from < 1
                                    interval_duration = interval_end - interval_start
                                    interval_proportion_duration = interval_duration * interval_proportion_to_extract_from
                                    interval_center = (interval_start + interval_end) / 2
                                    interval_start = interval_center - (interval_proportion_duration / 2)
                                    interval_end = interval_center + (interval_proportion_duration / 2)
                                endif
                                
                                select 'object_of_interest$' 'currenttoken$'
                                time_step = Get time step
                                first_frame_of_interest = Get frame number from time: interval_start
                                last_frame_of_interest = Get frame number from time: interval_end
                                first_frame_of_interest = ceiling(first_frame_of_interest)
                                last_frame_of_interest = floor(last_frame_of_interest)
                                number_of_frames = last_frame_of_interest - first_frame_of_interest + 1
                                
                                for iframe from first_frame_of_interest to last_frame_of_interest
                                    select 'object_of_interest$' 'currenttoken$'
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
                                            appendInfo: currenttoken$, tab$, fixed$(time, 4), tab$, fixed$(pitch_hz, 4), tab$, fixed$(pitch_st100, 4), tab$, fixed$(pitch_erb, 4), tab$, interval_label$, tab$, fixed$(interval_number, 0)
                                        elsif variable$ = "formants"
                                            appendInfo: currenttoken$, tab$, fixed$(time, 4), tab$, fixed$(formant1, 4), tab$, fixed$(formant2, 4), tab$, fixed$(formant3, 4), tab$, interval_label$, tab$, fixed$(interval_number, 0)
                                        elsif variable$ = "intensity"
                                            appendInfo: currenttoken$, tab$, fixed$(time, 4), tab$, fixed$(intensity, 4), tab$, interval_label$, tab$, fixed$(interval_number, 0)
                                        endif
                                        if extract_textgrid_information = 1
                                            if specific_coocurrent_tier$ = ""
                                                for coocurrent_tier_number to number_of_tiers
                                                    select TextGrid 'currenttoken$'
                                                    is_interval = Is interval tier... 'coocurrent_tier_number'
                                                    if is_interval = 1
                                                        coocurrent_tier_name$ = Get tier name... 'coocurrent_tier_number'
                                                        if coocurrent_tier_name$ != specific_tier_to_extract$
                                                            if coocurrent_tier_name$ = ""
                                                                coocurrent_tier_name$ = "Tier " + string$('coocurrent_tier_number')
                                                            endif
                                                            coocurrent_interval_number = Get interval at time: coocurrent_tier_number, time
                                                            coocurrent_interval_label$ = Get label of interval: coocurrent_tier_number, coocurrent_interval_number
                                                            appendInfo: tab$, coocurrent_tier_name$, tab$, coocurrent_interval_label$
                                                        endif
                                                    elsif is_interval = 0
                                                        coocurrent_tier_name$ = Get tier name... 'coocurrent_tier_number'
                                                        if coocurrent_tier_name$ = ""
                                                            coocurrent_tier_name$ = "Tier " + string$('coocurrent_tier_number')
                                                        endif
                                                        appendInfo: tab$, coocurrent_tier_name$
                                                        floor_point_number = Get low index from time: coocurrent_tier_number, time
                                                        ceiling_point_number = Get high index from time: coocurrent_tier_number, time
                                                        if floor_point_number != 0
                                                            floor_point_label$ = Get label of point: coocurrent_tier_number, floor_point_number
                                                            floor_point_time = Get time of point: coocurrent_tier_number, floor_point_number
                                                            floor_point_distance = time - floor_point_time
                                                            appendInfo: tab$, fixed$ (floor_point_distance, 4), tab$, floor_point_label$
                                                        else
                                                            appendInfo: tab$, tab$
                                                        endif
                                                        number_of_points = Get number of points: coocurrent_tier_number
                                                        if ceiling_point_number <= number_of_points
                                                            ceiling_point_label$ = Get label of point: coocurrent_tier_number, ceiling_point_number
                                                            ceiling_point_time = Get time of point: coocurrent_tier_number, ceiling_point_number
                                                            ceiling_point_distance = ceiling_point_time - time
                                                            appendInfo: tab$, fixed$ (ceiling_point_distance, 4), tab$, ceiling_point_label$
                                                        endif
                                                    endif
                                                endfor
                                            else
                                                for coocurrent_tier_number to number_of_tiers
                                                    select TextGrid 'currenttoken$'
                                                    is_interval = Is interval tier... 'coocurrent_tier_number'
                                                    if is_interval = 1
                                                        coocurrent_tier_name$ = Get tier name... 'coocurrent_tier_number'
                                                        if coocurrent_tier_name$ != specific_tier_to_extract$
                                                            coocurrent_tier_name$ = Get tier name... 'coocurrent_tier_number'
                                                            if coocurrent_tier_name$ = specific_coocurrent_tier$
                                                                coocurrent_interval_number = Get interval at time: coocurrent_tier_number, time
                                                                coocurrent_interval_label$ = Get label of interval: coocurrent_tier_number, coocurrent_interval_number
                                                                appendInfo: tab$, coocurrent_interval_label$
                                                            endif
                                                        endif
                                                    elsif is_interval = 0
                                                        coocurrent_tier_name$ = Get tier name... 'coocurrent_tier_number'
                                                        if coocurrent_tier_name$ = specific_coocurrent_tier$
                                                            floor_point_number = Get low index from time: coocurrent_tier_number, time
                                                            ceiling_point_number = Get high index from time: coocurrent_tier_number, time
                                                            if floor_point_number != 0
                                                                floor_point_label$ = Get label of point: coocurrent_tier_number, floor_point_number
                                                                floor_point_time = Get time of point: coocurrent_tier_number, floor_point_number
                                                                floor_point_distance = time - floor_point_time
                                                                appendInfo: tab$, fixed$ (floor_point_distance, 4), tab$, floor_point_label$
                                                            else
                                                                appendInfo: tab$, tab$
                                                            endif
                                                            number_of_points = Get number of points: coocurrent_tier_number
                                                            if ceiling_point_number <= number_of_points
                                                                ceiling_point_label$ = Get label of point: coocurrent_tier_number, ceiling_point_number
                                                                ceiling_point_time = Get time of point: coocurrent_tier_number, ceiling_point_number
                                                                ceiling_point_distance = ceiling_point_time - time
                                                                appendInfo: tab$, fixed$ (ceiling_point_distance, 4), tab$, ceiling_point_label$
                                                            endif
                                                        endif
                                                    endif
                                                endfor
                                            endif
                                        endif
                                        appendInfo: newline$
                                        appendFile: "'directory$''variable$''initialsubstring$'.txt", info$( )
                                        clearinfo
                                    endif
                                endfor
                            endif
                        endfor
                    endfor
                endif
            endif
        endfor
        select 'object_of_interest$' 'currenttoken$'
        Remove
    else
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
                                appendInfo: tab$, tier_name$, tab$, interval_label$, tab$, fixed$(interval_number, 0)
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
                                    appendInfo: tab$, interval_label$, tab$, fixed$(interval_number, 0)
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
        appendFile: "'directory$''variable$''initialsubstring$'.txt", info$( )
    endif
    clearinfo
    select Sound 'currenttoken$'
    if extract_textgrid_information = 1
        plus TextGrid 'currenttoken$'
    endif
    Remove
endfor
select Strings list
Remove
