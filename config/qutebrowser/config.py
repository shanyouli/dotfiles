#!/usr/bin/env python3
"""
  qutebrowser config
"""
import os
# pylint: disable=C0111
c = c  # noqa: F821 pylint: disable=E0602,C0103,W0127
config = config  # noqa: F821 pylint: disable=E0602,C0103,W0127

# Change the argument to True to still load settings configured via autoconfig.yml
# config.load_autoconfig(False)
config.load_autoconfig = False

# If you are downloading files, confirm whether to exit.
c.confirm_quit = ['downloads']

# command aliases
c.aliases = {
    'q': 'quit',
    'w': 'session-save',
    'wq': 'quit --save'
}

# set searchengines
c.url.searchengines = {
    'DEFAULT': 'https://duckduckgo.com/?q={}',
    'gg': 'https://www.google.com/search?q={}',
    'no': 'https://search.nixos.org/options?query={}',
    'np': 'https://search.nixos.org/packages?query={}',
    'dg': 'https://www.dogedoge.com/results?q={}'
}

c.url.start_pages = 'about:black' # startup page
c.url.default_page = 'about:blank' # default page

### Font configuration
c.fonts.default_size = '8pt'
c.fonts.default_family = [
    "Monospace",
    "Fantasque Sans Mono",
    "FantasqueSansMono Nerd Font Mono",
    "mononoki",
    "mononoki Nerd Font Mono"
]
c.fonts.web.family.fixed = "Monospace"
c.fonts.web.family.sans_serif = "Sans"
c.fonts.web.family.serif = 'Serif'
c.fonts.web.family.standard = 'Sans'
c.fonts.web.size.default = 16
c.fonts.web.size.default_fixed = 12

c.fonts.completion.category = 'bold 8pt Monospace'
c.fonts.completion.entry = '8pt Monospace'
c.fonts.debug_console = '8pt Monospace'
c.fonts.downloads = '8pt Monospace'
c.fonts.hints = 'bold 10pt Monospace'
c.fonts.keyhint = '8pt monospace'
c.fonts.messages.error = '8pt monospace'
c.fonts.messages.info = '8pt monospace'
c.fonts.messages.warning = '8pt monospace'
c.fonts.prompts = '8pt sans-serif'
c.fonts.statusbar = '8pt monospace'
c.fonts.tabs.selected = '8pt monospace'
c.fonts.tabs.unselected = '9pt sans-serif'

### completion
c.completion.height = '38%'
c.completion.web_history.max_items = 1000
c.completion.quick = True
c.completion.scrollbar.padding = 0
c.completion.scrollbar.width = 6


c.content.mute = True              # mute tabs by default
c.content.autoplay = False          # Don't auto play
c.content.javascript.enabled = True
c.content.local_storage = True
c.content.plugins = True
# host blocking
c.content.host_blocking.lists = [
    'https://cdn.jsdelivr.net/gh/neoFelhz/neohosts@gh-pages/full/hosts',
    'https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts',
]
c.content.host_blocking.whitelist = []

c.downloads.location.directory = os.path.expanduser("~/Downloads")
c.downloads.location.prompt = False
c.downloads.position = 'bottom'

c.editor.encoding = 'utf-8' # editor encoding

# proxy configuration
c.content.proxy = "http://127.0.0.1:7890"

c.window.title_format = '{current_title} -- qute' # window title format

c.input.insert_mode.auto_load = False
c.new_instance_open_target = 'tab-silent'
c.prompt.filebrowser = False
c.prompt.radius = 0
c.scrolling.bar = 'when-searching'
c.scrolling.smooth = False
c.spellcheck.languages = ['en-US']
c.session.lazy_restore = False
c.statusbar.padding = {'top': 4, 'bottom': 4, 'left': 4, 'right': 4}
c.tabs.background = True
c.tabs.padding = {'top': 4, 'bottom': 4, 'left': 0, 'right': 3}
c.tabs.indicator.padding = {'top': 0, 'bottom': 0, 'left': 0, 'right': 5}
c.tabs.mousewheel_switching = False
c.tabs.show = 'multiple'
c.tabs.title.format = '{current_title}'
c.tabs.title.format_pinned = ''
c.tabs.indicator.width = 1

### Bindings for normal mode
config.bind('x', 'tab-close')
config.bind('X', 'undo')
config.bind('J', 'tab-prev')
config.bind('K', 'tab-next')
config.bind('d', 'scroll-page 0 0.5')
config.bind('u', 'scroll-page 0 -0.5')
config.bind('j', 'scroll-page 0 0.1')
config.bind('k', 'scroll-page 0 -0.1')
config.bind('i', 'enter-mode insert ;; spawn fcitx-remote -t')
config.bind('gi', 'hint inputs --first ;; spawn fcitx-remote -t')
config.bind('p', 'open -- {clipboard}')
config.bind('P', 'open -t -- {clipboard}')
config.unbind('gl')
config.unbind('gr')
config.bind('gj', 'tab-move -')
config.bind('gk', 'tab-move +')
config.bind('<Escape>', c.bindings.default['normal']['<Escape>'] + ' ;; fake-key <Escape> ;; clear-messages ;; jseval --quiet document.getSelection().empty()')

# Bindings for insert mode
config.bind('<Ctrl-a>', 'fake-key <Home>', mode='insert')
config.bind('<Ctrl-e>', 'fake-key <End>', mode='insert')
config.bind('<Ctrl-d>', 'fake-key <Delete>', mode='insert')
config.bind('<Ctrl-h>', 'fake-key <Backspace>', mode='insert')
config.bind('<Ctrl-k>', 'fake-key <Ctrl-Shift-Right> ;; fake-key <Backspace>', mode='insert')
config.bind('<Ctrl-f>', 'fake-key <Right>', mode='insert')
config.bind('<Ctrl-b>', 'fake-key <Left>', mode='insert')
config.bind('<Ctrl-n>', 'fake-key <Down>', mode='insert')
config.bind('<Ctrl-p>', 'fake-key <Up>', mode='insert')
config.bind('<Escape>', 'spawn fcitx-remote -t ;; leave-mode ;; fake-key <Escape>', mode='insert')
