import re
from xkeysnail.transform import *

# CAPSLOCK interaction and LEFT_CTRL
define_multipurpose_modmap({
    Key.ENTER: [Key.ENTER, Key.RIGHT_CTRL],
    Key.CAPSLOCK: [Key.ESC, Key.LEFT_CTRL],
    Key.LEFT_CTRL: [Key.CAPSLOCK, Key.LEFT_CTRL],
    # Key.LEFT_CTRL: [Key.CAPSLOCK, Key.LEFT_CTRL],
    # Key.SPACE: [Key.SPACE, Key.LEFT_META],
    # Key.SYSRQ: [Key.SYSRQ, Key.RIGHT_META],
})

# 定义特定软件的多功能修饰键的按键映射
define_conditional_multipurpose_modmap(re.compile(r'Emacs'), {
    Key.ENTER: [Key.ENTER, Key.RIGHT_CTRL],
    Key.CAPSLOCK: [Key.ESC, Key.LEFT_CTRL],
    Key.LEFT_CTRL: [Key.CAPSLOCK, Key.LEFT_CTRL],
#    Key.TAB: [Key.TAB, Key.RIGHT_CTRL],
#    Key.LEFT_CTRL: [Key.ESC, Key.LEFT_CTRL],
#    Key.ENTER: [Key.ENTER, Key.RIGHT_SHIFT],
    Key.LEFT_SHIFT: [Key.F13, Key.LEFT_SHIFT],
 #    Key.SEMICOLON: [Key.SEMICOLON, Key.RIGHT_SHIFT],
})
