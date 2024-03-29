form Select directory and measures to extract
    sentence directory D:\audiofiles\
    sentence initialsubstring 
    boolean pitch 1
    boolean formants 1
    boolean intensity 1
    boolean voice 1
    boolean get_data_from_empty_labels 1
    positive interval_proportion_to_average_from 1/3
endform

Create Strings as file list... list 'directory$''initialsubstring$'*.wav
number_files = Get number of strings

filedelete 'directory$'output.txt
fileappend "'directory$'output.txt" file'tab$'tier'tab$'label'tab$'time1'tab$'time2'tab$'duration

if pitch
fileappend "'directory$'output.txt" 'tab$'hz'tab$'st
endif
if formants
fileappend "'directory$'output.txt" 'tab$'f1'tab$'f2'tab$'f3
endif
if intensity
fileappend "'directory$'output.txt" 'tab$'db
endif
if voice
fileappend "'directory$'output.txt" 'tab$'jitter'tab$'shimmer
endif

for file_num from 1 to number_files
    select Strings list
    current_token$ = Get string... 'file_num'
    Read from file... 'directory$''current_token$'
    object_name$ = selected$ ("Sound")
    
    if pitch
    select Sound 'object_name$'
        To Pitch (ac)... 0.005 75 15 no 0.03 0.45 0.01 0.35 0.14 600
    endif
    if formants
    select Sound 'object_name$'
        To Formant (burg): 0, 3, 5500, 0.025, 50
    endif
    if intensity
    select Sound 'object_name$'
        To Intensity: 100, 0, "no"
    endif
    if voice
    select Sound 'object_name$'
        To PointProcess (periodic, cc): 75, 600
    endif
    
    Read from file... 'directory$''object_name$'.TextGrid
    select TextGrid 'object_name$'
    number_of_tiers = Get number of tiers
    for tier_num from 1 to number_of_tiers
        select TextGrid 'object_name$'
        tier$ = Get tier name... 'tier_num'
        is_interval = Is interval tier... 'tier_num'
        if is_interval
            number_intervals = Get number of intervals... 'tier_num'
            for interval_num from 1 to number_intervals
                select TextGrid 'object_name$'
                interval_label$ = Get label of interval... 'tier_num' 'interval_num'
                u_s = Get start point... 'tier_num' 'interval_num'
                u_e = Get end point... 'tier_num' 'interval_num'
                u_d = u_e - u_s
                original_u_s = u_s
                original_u_e = u_e
                if interval_proportion_to_average_from < 1
                    interval_proportion_duration = u_d * interval_proportion_to_average_from
                    u_c = (u_s + u_e) / 2
                    u_s = u_c - (interval_proportion_duration / 2)
                    u_e = u_c + (interval_proportion_duration / 2)
                endif
                if pitch
                    select Pitch 'object_name$'
                    f0 = Get mean: 'u_s', 'u_e', "Hertz"
                    f0_st = Get mean: 'u_s', 'u_e', "semitones re 100 Hz"
                endif    
                if formants
                    select Formant 'object_name$'
                    f1 = Get mean: 1, 'u_s', 'u_e', "Hertz"
                    f2 = Get mean: 2, 'u_s', 'u_e', "Hertz"
                    f3 = Get mean: 3, 'u_s', 'u_e', "Hertz"
                endif
                if intensity
                    select Intensity 'object_name$'
                    db = Get mean: 'u_s', 'u_e', "dB"
                endif
                if voice
                    select PointProcess 'object_name$'
                    jit = Get jitter (local): 'u_s', 'u_e', 0.0001, 0.02, 1.3
                    select Sound 'object_name$'
                    plus PointProcess 'object_name$'
                    shi = Get shimmer (local): 'u_s', 'u_e', 0.0001, 0.02, 1.3, 1.6
                endif
                if get_data_from_empty_labels
                    fileappend "'directory$'output.txt" 'newline$''object_name$''tab$''tier$''tab$''interval_label$''tab$''original_u_s''tab$''original_u_e''tab$''u_d'
                    if pitch
                        fileappend "'directory$'output.txt" 'tab$''f0''tab$''f0_st'
                    endif
                    if formants
                        fileappend "'directory$'output.txt" 'tab$''f1''tab$''f2''tab$''f3'
                    endif
                    if intensity
                        fileappend "'directory$'output.txt" 'tab$''db'
                    endif
                    if voice
                        fileappend "'directory$'output.txt" 'tab$''jit''tab$''shi'
                    endif
                elsif interval_label$ <> ""
                    fileappend "'directory$'output.txt" 'newline$''object_name$''tab$''tier$''tab$''interval_label$''tab$''original_u_s''tab$''original_u_e''tab$''u_d'
                    if pitch
                        fileappend "'directory$'output.txt" 'tab$''f0''tab$''f0_st'
                    endif
                    if formants
                        fileappend "'directory$'output.txt" 'tab$''f1''tab$''f2''tab$''f3'
                    endif
                    if intensity
                        fileappend "'directory$'output.txt" 'tab$''db'
                    endif
                    if voice
                        fileappend "'directory$'output.txt" 'tab$''jit''tab$''shi'
                    endif
                endif
            endfor
        elsif is_interval = 0
            number_of_points = Get number of points... 'tier_num'
            for interval_num from 1 to number_of_points
                select TextGrid 'object_name$'
                point_label$ = Get label of point... 'tier_num' 'interval_num'
                u_p = Get time of point... 'tier_num' 'interval_num'
                if pitch
                    select Pitch 'object_name$'
                    f0 = Get value at time: 'u_p', "Hertz", "Linear"
                    f0_st = Get value at time: 'u_p', "semitones re 100 Hz", "Linear"
                endif
                if formants
                    select Formant 'object_name$'
                    f1 = Get value at time: 1, 'u_p', "Hertz", "Linear"
                    f2 = Get value at time: 2, 'u_p', "Hertz", "Linear"
                    f3 = Get value at time: 3, 'u_p', "Hertz", "Linear"
                endif
                if intensity
                    select Intensity 'object_name$'
                    db = Get value at time: 'u_p', "Linear"
                endif
                if get_data_from_empty_labels
                    fileappend "'directory$'output.txt" 'newline$''object_name$''tab$''tier$''tab$''point_label$''tab$''u_p''tab$''tab$'
                    if pitch
                        fileappend "'directory$'output.txt" 'tab$''f0''tab$''f0_st'
                    endif
                    if formants
                        fileappend "'directory$'output.txt" 'tab$''f1''tab$''f2''tab$''f3'
                    endif
                    if intensity
                        fileappend "'directory$'output.txt" 'tab$''db'
                    endif
                    if voice
                        fileappend "'directory$'output.txt" 'tab$''jit''tab$''shi'
                    endif
                elsif interval_label$ <> ""
                    fileappend "'directory$'output.txt" 'newline$''object_name$''tab$''tier$''tab$''point_label$''tab$''u_p''tab$''tab$'
                    if pitch
                        fileappend "'directory$'output.txt" 'tab$''f0''tab$''f0_st'
                    endif
                    if formants
                        fileappend "'directory$'output.txt" 'tab$''f1''tab$''f2''tab$''f3'
                    endif
                    if intensity
                        fileappend "'directory$'output.txt" 'tab$''db'
                    endif
                    if voice
                        fileappend "'directory$'output.txt" 'tab$''jit''tab$''shi'
                    endif
                endif
            endfor
        endif
    endfor
    select all
    minus Strings list
    Remove
endfor
select all
Remove
