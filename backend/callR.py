import subprocess

def callR(script_path, *args):
    """run r script with arbitrary numbers of arguments"""

    subprocess.call(["Rscript", script_path] + [str(arg) for arg in args])
