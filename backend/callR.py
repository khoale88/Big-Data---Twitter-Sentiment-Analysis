import subprocess

def callR(input):
    subprocess.call(["Rscript","sample_R.r",input])