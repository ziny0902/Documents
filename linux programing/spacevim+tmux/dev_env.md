# 편집 환경

## spacevim

### [설치](https://spacevim.org/quick-start-guide/ "spacevim home page 설치 가이드 페이지")

```
curl -sLf https://spacevim.org/install.sh | bash
```

### 환경 설정

사용자 정의 환경 파일은 ~/.SpaceVim.d/init.toml 이다.

```
#=============================================================================
# dark_powered.toml --- dark powered configuration example for SpaceVim
# Copyright (c) 2016-2020 Wang Shidong & Contributors
# Author: Wang Shidong < wsdjeg at 163.com >
# URL: https://spacevim.org
# License: GPLv3
#=============================================================================

# All SpaceVim option below [option] section
[options]
    # set spacevim theme. by default colorscheme layer is not loaded,
    # if you want to use more colorscheme, please load the colorscheme
    # layer
    colorscheme = "dracula"
    colorscheme_bg = "dark"
    # Disable guicolors in basic mode, many terminal do not support 24bit
    # true colors
    enable_guicolors = true
    # Disable statusline separator, if you want to use other value, please
    # install nerd fonts
    statusline_separator = "arrow"
    statusline_iseparator = "arrow"
    buffer_index_type = 4
    enable_tabline_filetype_icon = true
    enable_statusline_mode = true


# Enable autocomplete layer
[[layers]]
name = 'autocomplete'
auto_completion_return_key_behavior = "complete"
auto_completion_tab_key_behavior = "smart"

[[layers]]
name = 'shell'
default_position = 'top'
default_height = 30

[[layers]]
name = "VersionControl"

[[layers]]
name = "git"

[[layers]]
name = "fzf"

[[layers]]
name = "lang#markdown"

[[custom_plugins]]
repo = "dracula/vim"
name = "dracula"
merged = false

[[custom_plugins]]
repo = "junegunn/goyo.vim"
name = "goyo"
merged = false

[[custom_plugins]]
repo = "masukomi/vim-markdown-folding"
name = "markdown-folding"
merged = false
```

color scheme으로 Dracula를 사용했다. init.toml에서 추가 플러그인으로 설치했다.
nvim은 터미널의 color scheme에 영향을 받으므로 터미널의 color scheme도 바꿔 준다.
터미널 마다 그 설치 방법이 다르기 때문에 자신의 터미널에 맞게 dracula color scheme 홈페이지에서 알맞은 방법을 찾아 설정해야 한다.
그놈 터미널의 설정은 [이곳](https://draculatheme.com/gnome-terminal/)을 참고하면 된다.

### goyo, vim-markdown-folding plugin

* goyo plugin은 문서작업시 가독성을 높여주는 plugin이다. 자세한 정보는 [이곳](https://github.com/junegunn/goyo.vim)을 참고
* vim-markdown-folding은 markdown문서의 Heading을 기준으로 폴딩을 제공하는 plugin이다. 자세한 정보는 [이곳](https://github.com/masukomi/vim-markdown-folding)을 참고

## tmux

### 환경 설정

tmux의 환경 설정 파일은 ~/.tmux.conf 이다

```
# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'dracula/tmux'
set -g default-terminal "screen-256color" 

set -g @dracula-show-powerline true

# change the Window and Panes Base Index
set -g base-index 1
setw -g pane-base-index 1

# change prefix key binding
set -g prefix M-z
unbind C-b

# Remapping pane Movement Keys
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

set-option -g mouse on

## Use vim keybindings in copy mode
setw -g mode-keys vi
set-option -s set-clipboard off
bind P paste-buffer
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi y send-keys -X rectangle-toggle
unbind -T copy-mode-vi Enter
bind-key -T copy-mode-vi Enter send-keys -X copy-pipe-and-cancel 'xclip -se c -i'
bind-key -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel 'xclip -se c -i'

run '~/.tmux/plugins/tpm/tpm'
```

* vim/nvim 설정과 마찬가지로 color scheme을 일치 시켜주기 위해 tmux도 dracula color scheme을 사용했다.
* <Leader>키를 Alt+z로 변경했다. tmux <Leader>키의 Default 값은 Ctrl+b 이다.


## font 설치

spacevim의 상태바와 tmux dracula airline의 상태바들은 특수 문자를 사용하기 있기 때문에 Nerd font 계열이 필요하다.
한글을 사용하는 입장에서 현재 가장 좋은 터미널 mono 폰트는 D2Coding 이므로 D2Coding의 Nerd font를 구해야 한다.
구글에서 D2Coding Nerd font라고 입력해서 검색하면 어렵지 않게 찾을 수 있을 것이다.
font 설치 후 터미널이 설치된 font를 사용하도록 각 터미널에 맞게 font를 설정한다.

# 개발 도구 

## git

version control로 git을 사용한다. 대부분의 linux distro들은 기본 프로그램으로 제공하고 있기 때문에 따로
설치를 하지 않아도 되지만 만약 설치 되지 않았다면 git을 설치한다.

## cmake


