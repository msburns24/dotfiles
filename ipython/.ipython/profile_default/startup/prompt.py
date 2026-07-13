from pathlib import Path
from datetime import datetime
from pygments.token import Token
from IPython.terminal.prompts import Prompts


PromptList = list[tuple[Token, str]]


class CustomPrompt(Prompts):
    def in_prompt_tokens(self) -> PromptList:
        dir_name = Path.cwd().name
        time_fmt = datetime.now().strftime('%#I:%M:%S %p')
        exec_count = self.shell.execution_count
        return [
            (Token, f' {dir_name} | '),
            (Token, f'󰥔 {time_fmt} | '),
            (Token.Prompt, f'In[{exec_count}]\n'),
            (Token.String, f'   '),
        ]
    
    def continuation_prompt_tokens(
        self,
        width: int | None = None,
        *,
        lineno: int | None = None,
        wrap_count: int | None = None,
    )-> PromptList:
        return super().continuation_prompt_tokens(width)

    def rewrite_prompt_tokens(self) -> PromptList:
        return super().rewrite_prompt_tokens()
    
    def out_prompt_tokens(self) -> PromptList:
        # return super().out_prompt_tokens()
        return [(Token.Prompt, '\n')]


ip = get_ipython() # type: ignore
ip.prompts = CustomPrompt(ip)
