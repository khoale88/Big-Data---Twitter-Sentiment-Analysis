import subprocess

def callR(script_path, input):
    subprocess.call(["Rscript", script_path, input])