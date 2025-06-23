# code_analyzer.sh

**Universal Bash analyzer for PHP + HTML + JavaScript mixed files.**  
Built to be used in CLI environments, code editors like Roo Code / Kilo Code, or CI/CD pipelines.

---

## Features

✅ Works on `.php`, `.html`, `.blade.php`, `.twig`, mixed files  
✅ Shows *real line numbers* from source file  
✅ Extracts and analyzes:
- JavaScript (via eslint)
- HTML (via tidy)
- PHP syntax (via php -l)

✅ For each error/warning:
- Shows **3 lines before**, the error line, **3 lines after**  
✅ Final **summary** of all issues  
✅ Outputs to terminal + `report.txt` (overwritten every time)  
✅ No IDE required — just bash + eslint + tidy + php  
✅ Optional: runs perfectly inside **Roo Code / Kilo Code / other terminal-based editors** using `.clinerules` custom rules

---

## Example Output

```text
===== JAVASCRIPT ANALYSIS =====
🚨 JS error at original line 355:
    352 <div id="ipFeedback"...>
    353 <script>
    354   // comment
    355   document.getElementById('ipForm').addEventListener(...

===== HTML ANALYSIS =====
⚠️ HTML issue at line 182:
...

===== PHP ANALYSIS =====
✅ PHP OK — no syntax errors

===== SUMMARY =====
JS errors:    1
HTML issues:  3
PHP:          OK
