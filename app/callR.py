import subprocess

def call_rscript(script_path, *args):
    """run r script with arbitrary numbers of arguments"""

    print ("###########",
           subprocess.call(["Rscript", script_path] + [str(arg) for arg in args]))
