import numpy as np
import pandas as pd

def source():
    return "ORG"

def target():
    return "GKH"

def maxqty(filename="QuantityOnHandSync.csv"):
    # Read data
    qohs = pd.read_csv(filename,",")

    # Set Qty to a NumPy array
    qty = qohs['Qty']

    # Use numpy to find the maximum qty
    max_qty = np.nanmax(qty)

    return str(max_qty)
