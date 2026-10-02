# ============================================================
# Paul's Statistical Style Checker
# A small Praat script in honour of Paul's retirement.
#
# Purpose:
#   Scan a UTF-8 plain-text manuscript line by line and flag
#   statistical-reporting formats that Paul repeatedly corrected.
#
# Input:
#   A plain-text (.txt) manuscript.
#
# Output:
#   Praat Info window: line number, rule, original line, suggestion.
#
# Notes:
#   - This script REPORTS issues; it does not alter the manuscript.
#   - Word formatting such as italics is not preserved in .txt, so
#     this script cannot check whether p and t are italicised.
#   - Some context-dependent rules are marked [REVIEW].
# ============================================================

fileName$ = chooseReadFile$: "Choose manuscript text file"
if fileName$ = ""
    exitScript: "No file selected."
endif

lines$# = readLinesFromFile$# (fileName$)
numberOfLines = size (lines$#)

nAuto = 0
nReview = 0

writeInfoLine: "Paul's Statistical Style Checker"
appendInfoLine: "File: ", fileName$
appendInfoLine: "Lines checked: ", numberOfLines
appendInfoLine: "------------------------------------------------------------"

for i from 1 to numberOfLines
    line$ = lines$# [i]

    # --------------------------------------------------------
    # 1. "odd ratio" -> "odds ratio"
    # --------------------------------------------------------
    if index_regex (line$, "(?i)<odd[ \t]+ratios?>") <> 0
        nAuto = nAuto + 1
        appendInfoLine: "[AUTO] Line ", i, " | ODDS RATIO"
        appendInfoLine: "  Found:      ", line$
        appendInfoLine: "  Suggestion: use 'odds ratio' / 'odds ratios', not 'odd ratio'."
        appendInfoLine: ""
    endif

    # --------------------------------------------------------
    # 2. Do not report SPSS-style p < 0.001; give actual p-value
    # --------------------------------------------------------
    if index_regex (line$, "(?i)<p>[ \t]*[<≤][ \t]*0?\.?[0-9]+") <> 0
        nAuto = nAuto + 1
        appendInfoLine: "[AUTO] Line ", i, " | ACTUAL P-VALUE"
        appendInfoLine: "  Found:      ", line$
        appendInfoLine: "  Suggestion: report the actual p-value instead of 'p < ...' and give it to two significant digits."
        appendInfoLine: ""
    endif

    # --------------------------------------------------------
    # 3. p-values: exactly two significant digits
    #    Examples:
    #       p = 0.001   -> flag (prefer 0.0010)
    #       p = 0.023   -> OK
    #       p = 0.00123 -> flag
    # --------------------------------------------------------

    # One significant digit
    if index_regex (line$, "(?i)<p>[ \t]*=[ \t]*0\.0*[1-9](?=[^0-9]|$)") <> 0
        nAuto = nAuto + 1
        appendInfoLine: "[AUTO] Line ", i, " | P-VALUE PRECISION"
        appendInfoLine: "  Found:      ", line$
        appendInfoLine: "  Suggestion: p-values should have two significant digits (e.g. p = 0.0010, not p = 0.001)."
        appendInfoLine: ""
    endif

    # Three or more significant digits
    if index_regex (line$, "(?i)<p>[ \t]*=[ \t]*0\.0*[1-9][0-9]{2,}(?=[^0-9]|$)") <> 0
        nAuto = nAuto + 1
        appendInfoLine: "[AUTO] Line ", i, " | P-VALUE PRECISION"
        appendInfoLine: "  Found:      ", line$
        appendInfoLine: "  Suggestion: round the p-value to two significant digits."
        appendInfoLine: ""
    endif

    # --------------------------------------------------------
    # 4. Scientific notation: mantissa should normally have
    #    two significant digits.
    #
    #    The script recognises forms such as:
    #       1.10^-6
    #       2 x 10^-11
    #       2 × 10^-11
    #       2 · 10^-11
    #
    #    Marked REVIEW because notation varies across manuscripts.
    # --------------------------------------------------------

    # Mantissa with only one significant digit
    if index_regex (line$, "(?i)(^|[^0-9.])[1-9][ \t]*(\.|·|×|x)[ \t]*10\^[+-]?[0-9]+") <> 0
        nReview = nReview + 1
        appendInfoLine: "[REVIEW] Line ", i, " | SCIENTIFIC NOTATION"
        appendInfoLine: "  Found:      ", line$
        appendInfoLine: "  Check:      use two significant digits in the mantissa (e.g. 1.0 × 10^-6 rather than 1 × 10^-6)."
        appendInfoLine: ""
    endif

    # Mantissa with three or more significant digits
    if index_regex (line$, "(?i)(^|[^0-9.])[1-9]\.[0-9]{2,}[ \t]*(\.|·|×|x)[ \t]*10\^[+-]?[0-9]+") <> 0
        nReview = nReview + 1
        appendInfoLine: "[REVIEW] Line ", i, " | SCIENTIFIC NOTATION"
        appendInfoLine: "  Found:      ", line$
        appendInfoLine: "  Check:      round the mantissa to two significant digits."
        appendInfoLine: ""
    endif

    # e/E notation: flag for manual conversion/check
    if index_regex (line$, "(?i)[0-9]+(\.[0-9]+)?[eE][+-]?[0-9]+") <> 0
        nReview = nReview + 1
        appendInfoLine: "[REVIEW] Line ", i, " | SCIENTIFIC NOTATION"
        appendInfoLine: "  Found:      ", line$
        appendInfoLine: "  Check:      convert/check scientific notation and retain two significant digits."
        appendInfoLine: ""
    endif

    # --------------------------------------------------------
    # 5. t-values: positive values should carry a '+' sign
    #    Examples:
    #       t = 2.345   -> flag
    #       t = +2.345  -> OK
    #       t(31) = +2.345 -> OK
    # --------------------------------------------------------
    if index_regex (line$, "(?i)<t>([ \t]*\([^)]*\))?[ \t]*=[ \t]*[0-9]+(\.[0-9]+)?(?=[^0-9]|$)") <> 0
        nAuto = nAuto + 1
        appendInfoLine: "[AUTO] Line ", i, " | T-VALUE SIGN"
        appendInfoLine: "  Found:      ", line$
        appendInfoLine: "  Suggestion: t-values are signed quantities; prepend positive values with '+'."
        appendInfoLine: ""
    endif

    # --------------------------------------------------------
    # 6. t-values: exactly three digits after decimal point
    # --------------------------------------------------------

    # Integer, one decimal, or two decimals
    if index_regex (line$, "(?i)<t>([ \t]*\([^)]*\))?[ \t]*=[ \t]*[+-]?[0-9]+(\.[0-9]{1,2})?(?=[^0-9.]|$)") <> 0
        nAuto = nAuto + 1
        appendInfoLine: "[AUTO] Line ", i, " | T-VALUE PRECISION"
        appendInfoLine: "  Found:      ", line$
        appendInfoLine: "  Suggestion: write t-values with exactly three digits after the decimal point (±x.xxx)."
        appendInfoLine: ""
    endif

    # Four or more decimals
    if index_regex (line$, "(?i)<t>([ \t]*\([^)]*\))?[ \t]*=[ \t]*[+-]?[0-9]+\.[0-9]{4,}(?=[^0-9]|$)") <> 0
        nAuto = nAuto + 1
        appendInfoLine: "[AUTO] Line ", i, " | T-VALUE PRECISION"
        appendInfoLine: "  Found:      ", line$
        appendInfoLine: "  Suggestion: round t-values to exactly three digits after the decimal point (±x.xxx)."
        appendInfoLine: ""
    endif

    # --------------------------------------------------------
    # 7. Estimate + CI precision
    #    Report only ONE review message per line, even if both CI
    #    endpoints and the point estimate use inconsistent precision.
    #
    #    Paul's rule:
    #    keep the point estimate and CI at the same precision,
    #    usually two decimal places.
    # --------------------------------------------------------

    precisionProblem = 0

    # First CI endpoint: one decimal or three+ decimals
    if index_regex (line$, "(?i)<CI>[ \t]*(from[ \t]+|=[ \t]*)?[\[\(]?[ \t]*[+-]?[0-9]+\.[0-9](?=[^0-9]|$)") <> 0
        precisionProblem = 1
    endif
    if index_regex (line$, "(?i)<CI>[ \t]*(from[ \t]+|=[ \t]*)?[\[\(]?[ \t]*[+-]?[0-9]+\.[0-9]{3,}(?=[^0-9]|$)") <> 0
        precisionProblem = 1
    endif

    # Second CI endpoint: one decimal or three+ decimals
    if index_regex (line$, "(?i)<CI>.{0,60}(to|,)[ \t]*[+-]?[0-9]+\.[0-9](?=[^0-9]|$)") <> 0
        precisionProblem = 1
    endif
    if index_regex (line$, "(?i)<CI>.{0,60}(to|,)[ \t]*[+-]?[0-9]+\.[0-9]{3,}(?=[^0-9]|$)") <> 0
        precisionProblem = 1
    endif

    # Point estimate: one decimal or three+ decimals
    if index_regex (line$, "(?i)(<estimate>|<ratio>|<coefficient>|<beta>|<OR>|<b>)[ \t]*=[ \t]*[+-]?[0-9]+\.[0-9](?=[^0-9]|$)") <> 0
        precisionProblem = 1
    endif
    if index_regex (line$, "(?i)(<estimate>|<ratio>|<coefficient>|<beta>|<OR>|<b>)[ \t]*=[ \t]*[+-]?[0-9]+\.[0-9]{3,}(?=[^0-9]|$)") <> 0
        precisionProblem = 1
    endif

    if precisionProblem = 1
        nReview = nReview + 1
        appendInfoLine: "[REVIEW] Line ", i, " | ESTIMATE & CI PRECISION"
        appendInfoLine: "  Found:      ", line$
        appendInfoLine: "  Check:      report the point estimate and CI at the same precision, usually two decimal places."
        appendInfoLine: ""
    endif

    # --------------------------------------------------------
    # 9. Avoid repeatedly saying "from zero"
    # --------------------------------------------------------
    if index_regex (line$, "(?i)<from[ \t]+zero>") <> 0
        nReview = nReview + 1
        appendInfoLine: "[REVIEW] Line ", i, " | 'FROM ZERO'"
        appendInfoLine: "  Found:      ", line$
        appendInfoLine: "  Check:      omit 'from zero' unless the contrast genuinely needs to be stated."
        appendInfoLine: ""
    endif

endfor

appendInfoLine: "------------------------------------------------------------"
appendInfoLine: "Automatic-format flags: ", nAuto
appendInfoLine: "Context-dependent review flags: ", nReview
appendInfoLine: "Total flags: ", nAuto + nReview

if nAuto + nReview = 0
    appendInfoLine: "No Paul-style issues found. He might still find one."
endif
