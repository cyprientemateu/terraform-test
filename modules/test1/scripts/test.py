import math
import datetime

# Variables for monthly compounding calculation
P = 0  # Initial principal
M = 200  # Monthly contribution
r = 0.13  # Annual interest rate (13%)
n = 12  # Compounding frequency (monthly)
t = 40  # Time in years

# Formula for compound interest with monthly contributions
def calculate_compound_interest(P, M, r, n, t):
    # Total accumulated amount
    A = P * (1 + r / n) ** (n * t) + M * (((1 + r / n) ** (n * t) - 1) / (r / n))
    return A

# Calculate the final amount
final_amount = calculate_compound_interest(P, M, r, n, t)
final_amount
print(f"Final accumulated amount after {t} years: ${final_amount:,.2f}")

# import math
# import datetime

# # Variables for monthly compounding calculation
# P = 0  # Initial principal
# M = 200  # Monthly contribution
# r = 0.13  # Annual interest rate (13%)
# n = 12  # Compounding frequency (monthly)
# t = 40  # Time in years

# # Formula for compound interest with monthly contributions
# def calculate_compound_interest(P, M, r, n, t):
#     # Total accumulated amount
#     A = P * (1 + r / n) ** (n * t) + M * (((1 + r / n) ** (n * t) - 1) / (r / n))
#     return A

# # Calculate the final amount
# final_amount = calculate_compound_interest(P, M, r, n, t)

# # Current date for additional context
# current_date = datetime.datetime.now()

# # Print the final accumulated amount with date and formatted output
# print(f"Calculation as of {current_date.strftime('%Y-%m-%d %H:%M:%S')}")
# print(f"Final accumulated amount after {t} years: ${final_amount:,.2f}")
