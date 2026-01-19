# -*- coding: utf-8 -*-
import os
import sys
import readline
import atexit
import subprocess
import time
import importlib.util  # 引入用于静默检测的工具
from pathlib import Path
from tempfile import mkstemp
from code import InteractiveConsole

# --- 1. 魔法退出 ---
def patch_exit():
    import builtins
    for name in ('exit', 'quit'):
        obj = getattr(builtins, name, None)
        if obj:
            try:
                type(obj).__repr__ = lambda s: s()
            except Exception:
                pass

# --- 2. 颜色定义 ---
class C:
    YEL, GRN, RED, CYN, MAG, GRA, RST = (
        "\001\033[1;33m\002", "\001\033[1;32m\002", 
        "\001\033[1;31m\002", "\001\033[1;36m\002",
        "\001\033[1;35m\002", "\001\033[90m\002", "\001\033[0m\002"
    )

# --- 3. 增强型控制台 ---
class OptimizedConsole(InteractiveConsole):
    def __init__(self, *args, **kwargs):
        self.last_source = ""
        super().__init__(*args, **kwargs)

    def runsource(self, source, *args, **kwargs):
        self.last_source = source
        return super().runsource(source, *args, **kwargs)

    def raw_input(self, prompt=""):
        line = super().raw_input(prompt)
        if line.strip() == r"\e":
            return self._open_editor()
        return line

    def _open_editor(self):
        editor = os.environ.get("EDITOR", "vim")
        fd, tmpfl = mkstemp(".py")
        try:
            os.write(fd, self.last_source.encode("utf-8"))
            os.close(fd)
            subprocess.call([editor, tmpfl])
            with open(tmpfl, 'r') as f:
                content = f.read()
            if content.strip():
                print(f"{C.GRA}--- 执行编辑内容 ---{C.RST}")
                self._highlight_print(content)
                self.runsource(content)
            return "" 
        except Exception:
            return ""
        finally:
            if os.path.exists(tmpfl):
                os.unlink(tmpfl)

    def _highlight_print(self, code):
        """仅在真正需要时尝试导入 pygments"""
        if importlib.util.find_spec("pygments"):
            from pygments import highlight
            from pygments.lexers import PythonLexer
            from pygments.formatters import TerminalFormatter
            print(highlight(code, PythonLexer(), TerminalFormatter()).strip())
        else:
            print(code)

# --- 4. 功能辅助 ---
def qhelp():
    """极简帮助，使用 find_spec 检测依赖"""
    print(f"\n{C.GRA}快捷操作:{C.RST}")
    print(f"  {C.MAG}exit{C.RST} 直接退出 | {C.MAG}\\e{C.RST} 编辑器")
    
    # 静态检测，不触发 F401 警告
    missing = [pkg for pkg in ["rich", "pygments"] if importlib.util.find_spec(pkg) is None]
    
    if missing:
        # 这里的提示非常弱化，仅在 qhelp 中可见
        print(f"  {C.GRA}提示: 可选安装 {', '.join(missing)}{C.RST}")

def setup_runtime():
    # 补全
    import rlcompleter
    readline.set_completer(rlcompleter.Completer(globals()).complete)
    pattern = "bind ^I rl_complete" if 'libedit' in readline.__doc__ else "tab: complete"
    readline.parse_and_bind(pattern)

    # 历史
    hist_file = Path.home() / ".python_history"
    try:
        if hist_file.exists():
            readline.read_history_file(str(hist_file))
        atexit.register(readline.write_history_file, str(hist_file))
    except Exception:
        pass

    # 注入辅助
    import builtins
    builtins.qhelp = qhelp
    
    # 打印优化：仅在存在时导入
    if importlib.util.find_spec("rich"):
        from rich import pretty, traceback, inspect
        pretty.install()
        traceback.install(show_locals=False)
        builtins.i = inspect
    else:
        from pprint import pprint
        sys.displayhook = lambda v: [pprint(v), setattr(sys.modules['builtins'], '_', v)] if v is not None else None

# --- 5. 启动 ---
if __name__ == "__main__":
    patch_exit()
    setup_runtime()
    
    # 动态提示符
    sys.ps1 = type('P', (), {'__str__': lambda s: f"{C.GRA}[{time.strftime('%H:%M:%S')}]{C.RST} {C.YEL}🐍{C.RST} {C.GRN}❯{C.RST} "})()
    sys.ps2 = f"{C.RED}.. {C.RST}"
    
    version = sys.version.split()[0]
    banner = f"{C.GRA}Python {version} | {C.RST}{C.CYN}qhelp{C.RST}{C.GRA} 帮助{C.RST}"
    
    console = OptimizedConsole(locals=locals())
    console.interact(banner=banner, exitmsg="")
