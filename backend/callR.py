import subprocess

def call_rscript(script_path, *args):
    """call an R script from given script_path with args"""

    subprocess.call(["Rscript", script_path] + [str(arg) for arg in args])
