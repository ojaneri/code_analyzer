#!/bin/bash

# code_analyzer.sh v5
# Universal Bash analyzer for PHP + HTML + JavaScript mixed files.
# Real line numbers in errors AND in context.
# Works with Kilo Code / Roo Code / AI tools with .clinerules

FILE="$1"
TEMP_JS="/tmp/js_extracted_$(date +%s).js"
TEMP_HTML="/tmp/html_extracted_$(date +%s).html"
REPORT="report.txt"

# Terminal Colors
RED='\033[0;31m'
YELLOW='\033[1;33m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Flags
NO_COLOR=false

# Parse params
if [[ "$2" == "--no-color" ]]; then
    NO_COLOR=true
    RED=""
    YELLOW=""
    GREEN=""
    NC=""
fi

# Start
if [ -z "$FILE" ]; then
    echo "⚠️ Usage: ./code_analyzer.sh yourfile.php|html|blade.php"
    exit 1
fi

if [ ! -f "$FILE" ]; then
    echo "❌ File not found: $FILE"
    exit 1
fi

echo "🗂️ Analyzing file: $FILE"
echo "=== REPORT $(date) ===" > "$REPORT"

# ========= JAVASCRIPT =========
echo ""
echo "===== JAVASCRIPT ANALYSIS ====="
echo -e "\n===== JAVASCRIPT ANALYSIS =====" >> "$REPORT"

if command -v eslint >/dev/null 2>&1; then
    USE_ESLINT=true
    echo "✅ eslint found"
    echo "✅ eslint found" >> "$REPORT"
else
    USE_ESLINT=false
    echo "⚠️ eslint NOT found"
    echo "⚠️ eslint NOT found" >> "$REPORT"
fi

# Extract <script> with original line numbers
awk '{
    print NR":"$0
}' "$FILE" | grep -Pzo '(?s)([0-9]+:)?<script[^>]*>.*?</script>' | \
sed -E 's/<script[^>]*>//Ig' | sed -E 's#</script>##Ig' > "$TEMP_JS"

if [ -s "$TEMP_JS" ]; then
    echo "✅ JavaScript extracted to: $TEMP_JS" >> "$REPORT"

    if [ "$USE_ESLINT" = true ]; then
        eslint --no-eslintrc "$TEMP_JS" > /tmp/eslint_out.txt 2>&1
        cat /tmp/eslint_out.txt >> "$REPORT"

        ERR_LINES=$(grep -oP '^\s*[0-9]+:' /tmp/eslint_out.txt | awk -F: '{print $1}' | sort -u)

        for LINE in $ERR_LINES; do
            ORIG_LINE=$(awk "NR==$LINE { split(\$0,a,\":\"); print a[1] }" "$TEMP_JS")
            echo -e "${RED}🚨 JS error at original line $ORIG_LINE:${NC}"
            echo "🚨 JS error at original line $ORIG_LINE:" >> "$REPORT"

            CONTEXT_START=$((ORIG_LINE-3))
            sed -n "${CONTEXT_START},$((ORIG_LINE+3))p" "$FILE" | \
            awk -v start=$CONTEXT_START '{ printf "%5d  %s\n", NR+start-1, $0 }' | tee -a "$REPORT"

            echo "-----------------------" | tee -a "$REPORT"
        done
    fi
else
    echo "ℹ️ No <script> blocks found."
    echo "ℹ️ No <script> blocks found." >> "$REPORT"
fi

# ========= HTML =========
echo ""
echo "===== HTML ANALYSIS ====="
echo -e "\n===== HTML ANALYSIS =====" >> "$REPORT"

# Remove embedded PHP
sed -E 's/<\?php.*?\?>//g' "$FILE" > "$TEMP_HTML"

if command -v tidy >/dev/null 2>&1; then
    tidy -q -errors "$TEMP_HTML" > /tmp/tidy_out.txt 2>&1
    cat /tmp/tidy_out.txt >> "$REPORT"

    HTML_LINES=$(grep -oP 'line\s+\K[0-9]+' /tmp/tidy_out.txt | sort -u)

    for LINE in $HTML_LINES; do
        echo -e "${YELLOW}⚠️ HTML issue at line $LINE:${NC}"
        echo "⚠️ HTML issue at line $LINE:" >> "$REPORT"

        CONTEXT_START=$((LINE-3))
        sed -n "${CONTEXT_START},$((LINE+3))p" "$FILE" | \
        awk -v start=$CONTEXT_START '{ printf "%5d  %s\n", NR+start-1, $0 }' | tee -a "$REPORT"

        echo "-----------------------" | tee -a "$REPORT"
    done
else
    echo "⚠️ tidy not found — install with: sudo apt install tidy"
    echo "⚠️ tidy not found — install with: sudo apt install tidy" >> "$REPORT"
fi

# ========= PHP =========
echo ""
echo "===== PHP ANALYSIS ====="
echo -e "\n===== PHP ANALYSIS =====" >> "$REPORT"

if command -v php >/dev/null 2>&1; then
    php -l "$FILE" > /tmp/php_out.txt 2>&1
    cat /tmp/php_out.txt >> "$REPORT"

    LINE=$(grep -oP 'on line \K[0-9]+' /tmp/php_out.txt)

    if [ -n "$LINE" ]; then
        echo -e "${RED}🚨 PHP error at line $LINE:${NC}"
        echo "🚨 PHP error at line $LINE:" >> "$REPORT"

        CONTEXT_START=$((LINE-3))
        sed -n "${CONTEXT_START},$((LINE+3))p" "$FILE" | \
        awk -v start=$CONTEXT_START '{ printf "%5d  %s\n", NR+start-1, $0 }' | tee -a "$REPORT"

        echo "-----------------------" | tee -a "$REPORT"
    else
        echo -e "${GREEN}✅ PHP OK — no syntax errors${NC}"
        echo "✅ PHP OK — no syntax errors" >> "$REPORT"
    fi
else
    echo "⚠️ PHP not found"
    echo "⚠️ PHP not found" >> "$REPORT"
fi

# ========= SUMMARY =========
echo ""
echo "===== SUMMARY ====="
echo -e "\n===== SUMMARY =====" >> "$REPORT"

JS_ERR_COUNT=$(grep -c "JS error at original line" "$REPORT")
HTML_WARN_COUNT=$(grep -c "HTML issue at line" "$REPORT")
PHP_ERR_COUNT=$(grep -c "PHP error at line" "$REPORT")

if [[ "$PHP_ERR_COUNT" == "0" ]]; then
    PHP_STATUS="OK"
else
    PHP_STATUS="$PHP_ERR_COUNT error(s)"
fi

echo "JS errors:    $JS_ERR_COUNT"
echo "HTML issues:  $HTML_WARN_COUNT"
echo "PHP:          $PHP_STATUS"

echo "JS errors:    $JS_ERR_COUNT" >> "$REPORT"
echo "HTML issues:  $HTML_WARN_COUNT" >> "$REPORT"
echo "PHP:          $PHP_STATUS" >> "$REPORT"

# ========= Errors Detected At =========
JS_ERR_LINES=$(grep "JS error at original line" "$REPORT" | grep -oP '\d+' | tr '\n' ',' | sed 's/,$//')
HTML_ERR_LINES=$(grep "HTML issue at line" "$REPORT" | grep -oP '\d+' | tr '\n' ',' | sed 's/,$//')
PHP_ERR_LINES=$(grep "PHP error at line" "$REPORT" | grep -oP '\d+' | tr '\n' ',' | sed 's/,$//')

echo ""
echo "🚨 Errors detected at:"
if [[ -n "$JS_ERR_LINES" ]]; then
    echo "JS lines:    $JS_ERR_LINES"
fi
if [[ -n "$HTML_ERR_LINES" ]]; then
    echo "HTML lines:  $HTML_ERR_LINES"
fi
if [[ -n "$PHP_ERR_LINES" ]]; then
    echo "PHP lines:   $PHP_ERR_LINES"
fi

echo "" >> "$REPORT"
echo "🚨 Errors detected at:" >> "$REPORT"
if [[ -n "$JS_ERR_LINES" ]]; then
    echo "JS lines:    $JS_ERR_LINES" >> "$REPORT"
fi
if [[ -n "$HTML_ERR_LINES" ]]; then
    echo "HTML lines:  $HTML_ERR_LINES" >> "$REPORT"
fi
if [[ -n "$PHP_ERR_LINES" ]]; then
    echo "PHP lines:   $PHP_ERR_LINES" >> "$REPORT"
fi

# END
echo ""
echo "🏁 Analysis complete!"
echo "�� Report saved to: $REPORT"

# Cleanup
rm -f "$TEMP_JS" "$TEMP_HTML"
