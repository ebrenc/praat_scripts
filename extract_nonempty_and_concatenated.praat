# Praat: Batch extract non-empty intervals by tier and concatenate (recoverably)
# ---------------------------------------------------------------------------
# Description
#   Processes *.TextGrid + *.wav pairs from an input directory. For each pair,
#   it extracts all non-empty intervals from a chosen tier, concatenates them
#   recoverably, and saves the resulting Sound and TextGrid to the output
#   directory using the SAME base filename.
#
#   - TextGrid is saved as a *text* .TextGrid file (readable in VCS).
#   - Sound is saved as .wav.
#
# Usage
#   1) Set input/output directories and tier number in the form below.
#   2) Run the script. Results are written alongside a final summary in the
#      Info window.
#
# Notes
#   - Works on Windows/Mac/Linux; both '\\' and '/' path separators are handled.
#   - Intervals are extracted with 'preserve original times' = "no".
#   - If a pair has no non-empty intervals in the requested tier, it is skipped.
#   - The output files are named <base>.wav and <base>.TextGrid in the output dir.
# ---------------------------------------------------------------------------

form Process batch of files
    sentence input_directory C:\Input dir
    sentence output_directory C:\Output dir
    natural tier_number 3
endform

input$  = input_directory$
output$ = output_directory$
tier    = tier_number

# -- Ensure trailing separator on directories (accepts \\ or /) --
if right$ (input$, 1) <> "\\" and right$ (input$, 1) <> "/"
    input$ = input$ + "\\"
endif
if right$ (output$, 1) <> "\\" and right$ (output$, 1) <> "/"
    output$ = output$ + "\\"
endif

createDirectory: output$

# -- List TextGrids in the input folder --
Create Strings as file list: "tgList", input$ + "*.TextGrid"
n = Get number of strings
if n = 0
    printline No s'han trobat fitxers .TextGrid a: 'input$'
    removeObject: "Strings tgList"
    exit
endif

processed = 0
skipped   = 0

for i to n
    selectObject: "Strings tgList"
    tgEntry$ = Get string: i

    # Filename (strip any path parts returned by file list)
    p1 = rindex (tgEntry$, "/")
    p2 = rindex (tgEntry$, "\\")
    p  = max (p1, p2)
    if p > 0
        tgFile$ = mid$ (tgEntry$, p + 1)
    else
        tgFile$ = tgEntry$
    endif

    # Base name and full paths
    if index (tgFile$, ".TextGrid") > 0
        base$ = replace$ (tgFile$, ".TextGrid", "", 0)
    else
        skipped = skipped + 1
        echo "AVÍS: no és un TextGrid vàlid: " + tgFile$
        continue
    endif

    fullTgPath$ = input$ + tgFile$
    wavPath$    = input$ + base$ + ".wav"

    if fileReadable (fullTgPath$) = 0
        skipped = skipped + 1
        echo "AVÍS: no es pot llegir el TextGrid: " + fullTgPath$
        continue
    endif
    if fileReadable (wavPath$) = 0
        skipped = skipped + 1
        echo "AVÍS: falta el WAV per a '" + base$ + "' — s'omet."
        continue
    endif

    # -- Read pair --
    Read from file: fullTgPath$
    Read from file: wavPath$

    # -- Extract non-empty intervals from the requested tier --
    selectObject: "TextGrid " + base$
    plusObject:   "Sound " + base$
    Extract non-empty intervals: tier, "no"

    # Ensure we actually got Sound fragments to concatenate
    nSel = numberOfSelected ("Sound")
    if nSel = 0
        # Cleanup objects created in this iteration (except the list)
        select all
        minusObject: "Strings tgList"
        Remove
        skipped = skipped + 1
        echo "AVÍS: cap interval no buit al tier " + string$ (tier) + " per a '" + base$ + "'."
        continue
    endif

    # -- Concatenate recoverably -> produces 'Sound chain' + 'TextGrid chain' --
    Concatenate recoverably

    # Save both outputs explicitly by selecting each
    selectObject: "Sound chain"
    Save as WAV file: output$ + base$ + ".wav"
    selectObject: "TextGrid chain"
    Save as text file: output$ + base$ + ".TextGrid"

    # Cleanup for this iteration: remove everything except the list
    select all
    minusObject: "Strings tgList"
    Remove

    processed = processed + 1
endfor

# Final summary
removeObject: "Strings tgList"
clearinfo
appendInfoLine: "Procés completat."
appendInfoLine: "Processats: ", processed, " | Omesos: ", skipped
appendInfoLine: "Sortida: ", output$
appendInfoLine: "Tier processat: ", tier
