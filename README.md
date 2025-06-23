code_analyzer.sh
Universal Bash analyzer for PHP + HTML + JavaScript mixed files.
Built to be used in CLI environments, terminal-based editors like Roo Code / Kilo Code, or CI/CD pipelines.
It is also designed to work well with AI tools that support custom CLI hooks (such as .clinerules or similar).

Features
✅ Works on .php, .html, .blade.php, .twig, mixed files
✅ Shows real line numbers from source file
✅ Extracts and analyzes:

JavaScript (via eslint)

HTML (via tidy)

PHP syntax (via php -l)

✅ For each error/warning:

Shows 3 lines before, the error line, 3 lines after
✅ Final summary of all issues
✅ Outputs to terminal + report.txt (overwritten every time)
✅ No IDE required — just bash + eslint + tidy + php
✅ Works great with AI tools / editors using .clinerules

Example Output
text
Copiar
Editar
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
Dependencies
bash
Copiar
Editar
sudo apt install tidy
npm install -g eslint
php
How to run
bash
Copiar
Editar
chmod +x code_analyzer.sh

./code_analyzer.sh yourfile.php
Optional param for CI/CD:

bash
Copiar
Editar
./code_analyzer.sh yourfile.php --no-color
Example .clinerules for Roo Code / Kilo Code / AI assistants
You can teach your AI or editor to run code_analyzer.sh automatically
using this .clinerules example:

text
Copiar
Editar
# .clinerules
# Rule to let AI / Roo Code / Kilo Code run code_analyzer.sh
# and display the results in terminal and report.txt

[code_analyzer]
run = ./code_analyzer.sh {file}
display_output = true
highlight_errors = true
generate_report = report.txt
Teaching your AI
When using an AI assistant (for example with an embedded terminal or code workspace):

👉 Add the .clinerules in project root
👉 Teach your AI to run:

bash
Copiar
Editar
./code_analyzer.sh {file}
and then:

👉 Use the output and the generated report.txt to improve your analysis.

Example Prompt to teach AI:

"Before reviewing this PHP/HTML/JS file, please run:
./code_analyzer.sh {file}.
Use the result in report.txt to prioritize issues and improve recommendations."

License
MIT License — feel free to copy, fork, improve 🚀

Credits
Built by: ojaneri
With testing and feedback from real PHP / HTML / JS production code.

If you like it, feel free to give it a ⭐️ or post on Reddit!
Contributions welcome 🚀
