source=M_calculus.md
html_template=GitHub.html5
css_template=$(HOME)/.local/share/pandoc/templates/src/GitHub.css
meta_flags= -M date="`date "+%B%e, %Y"`" 
pdf_template=
html_flags=--standalone --mathjax 
mainfont='D2Coding' -
pdf_flags=--pdf-engine=xelatex -V mainfont="D2Coding" 
tex_flags=--listings --pdf-engine=xelatex -V mainfont="D2Coding" 
syntax_highlight=--highlight-style tango

base_src=$(basename $(source))
html_target=$(addsuffix .html, $(base_src))
pdf_target=$(addsuffix .pdf, $(base_src))
tex_target=$(addsuffix .tex, $(base_src))
common_flags=-s $(meta_flags) $(syntax_highlight)

ifneq ($(strip $(html_template)),)
	html_flags += --template $(html_template)
endif
ifneq ($(strip $(css_template)),) 
	html_flags += --css $(css_template)
endif
ifneq ($(strip $(pdf_template)),) 
	pdf_flags += --template $(pdf_template)
	tex_flags += --template $(pdf_template)
endif

ifneq ($(strip $(source)),)
all: $(html_target) $(pdf_target)
else
all:;@echo 'Nothing to make'
endif

html: $(html_target)
pdf: $(pdf_target)
tex: $(tex_target)

$(html_target): $(source)
	pandoc $^ -o $@ $(html_flags) $(common_flags)

$(pdf_target): $(source)
	pandoc $^ -o $@ $(pdf_flags) $(common_flags)

$(tex_target): $(source)
	pandoc $^ -o $@ $(tex_flags) $(common_flags)

clean:
	\rm $(html_target) $(pdf_target)
