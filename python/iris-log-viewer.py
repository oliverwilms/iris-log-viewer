import numpy as np
import pandas as pd

def fileread(filename=""):
    if filename=="":
        print("filename is required")
        quit()
        file = open(filename,"r")
        atEnd = False
        time1 = round(datetime.timestamp(datetime.now()) * 1000)
        while not atEnd:
            line = file.readline()
            if not line:
                atEnd = True
        time2 = round(datetime.timestamp(datetime.now()) * 1000)
        file.close()
        print("fileread execution: ",((time2-time1)/1000),"s")

def maxqty(filename="QuantityOnHandSync.csv"):
    # Read data
    qohs = pd.read_csv(filename,",")

    # Set Qty to a NumPy array
    qty = qohs['Qty']

    # Use numpy to find the maximum qty
    max_qty = np.nanmax(qty)

    return str(max_qty)
