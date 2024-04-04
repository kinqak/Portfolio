import pandas as pd
import math
import numpy as np
import matplotlib.pyplot as plt
from statsmodels.tsa.stattools import adfuller
from sklearn.preprocessing import MinMaxScaler
from keras.models import Sequential
from keras.layers import Dense, LSTM
from sklearn.metrics import mean_squared_error

stock_data = pd.read_csv(filepath_or_buffer="apple_stock.csv", sep=';')

print(stock_data.head())
print(stock_data.tail())
stock_data.info()
print(stock_data.isna().sum())

# Reviewing the content of our data, we can see that the data is numeric and the date is the index of the data.
# Weekends are missing from the records.

stock_data['Date'] = pd.to_datetime(stock_data['Date'])

# Visualize the closing price history
plt.figure(figsize=(16, 8))
plt.title('Close Price History')
plt.plot(stock_data['Date'], stock_data['Close'], color='black', linewidth=1.0)
plt.grid(True, linestyle='--', alpha=0.5, color='gray')
plt.xlabel('Date')
plt.ylabel('Close Price USD ($)')
plt.show()

# Checking decomposition of trend, seasonality and residue of the original time series

# Calculating rolling mean and rolling standard deviation:
rolling_mean = stock_data['Close'].rolling(30).mean()
rolling_std_dev = stock_data['Close'].rolling(30).std()

plt.figure(figsize=(24, 6))
plt.plot(stock_data['Date'], rolling_mean, color='darkblue', label='Rolling Mean')
plt.plot(stock_data['Date'], rolling_std_dev, color='darkgreen', label='Rolling Std Dev')
plt.plot(stock_data['Date'], stock_data['Close'], color='darkred', label='Original Time Series')
plt.grid(True, linestyle='--', alpha=0.5, color='gray')
plt.legend(loc='best')
plt.title('Rolling Mean and Standard Deviation')
plt.show()

#H0: the time series is not stationary
#H1: the time series is stationary

adft = adfuller(stock_data['Close'], autolag="AIC")
output_adft = pd.DataFrame({"Values":[adft[0], adft[1], adft[2], adft[3],  adft[4]['1%'], adft[4]['5%'], adft[4]['10%']], "Metric":["Test Statistics", "p-value", "No. of lags used", "Number of observations used",
                                                        "critical value (1%)", "critical value (5%)", "critical value (10%)"]})
print(output_adft)

# We can see that our data is not stationary from the fact that our p-value is greater than 5 percent and the test statistic is greater than the critical value.


### Training the model

data = stock_data.reset_index()['Close']
print(len(data))

# Scale the data
scaler = MinMaxScaler(feature_range=(0, 1))
data = scaler.fit_transform(np.array(data).reshape(-1, 1))
print(data)

# Create the training data set
training_size = math.ceil(int(len(data) * .7))
test_size = len(data) - training_size
train_data, test_data = data[0:training_size, :], data[training_size: len(data), :1]

def create_dataset(dataset, time_steps = 1) :
    dataX, dataY = [], []
    for i in range(len(dataset)-time_steps - 1) :
        a = dataset[i:(i+time_steps), 0]
        dataX.append(a)
        dataY.append(dataset[i+time_steps, 0])
    return np.array(dataX), np.array(dataY)

time_steps = 100
X_train, y_train = create_dataset(train_data, time_steps)
X_test, y_test = create_dataset(test_data, time_steps)

X_train = X_train.reshape(X_train.shape[0], X_train.shape[1], 1)
X_test = X_test.reshape(X_test.shape[0], X_test.shape[1], 1)

# Build the LSTM model
model = Sequential()
model.add(LSTM(50, return_sequences=True, input_shape=(100, 1)))
model.add(LSTM(50, return_sequences=True))
model.add(LSTM(50))
model.add(Dense(1))

# Compile the model
model.compile(loss='mean_squared_error', optimizer='adam')

model.summary()

# Train the model
model.fit(X_train, y_train, validation_data=(X_test, y_test), epochs=100, batch_size=64, verbose=1)

# Prediction
train_predict = model.predict(X_train)
test_predict = model.predict(X_test)

train_predict = scaler.inverse_transform(train_predict)
test_predict = scaler.inverse_transform(test_predict)

# RMSE performance metrics

print(math.sqrt(mean_squared_error(y_train, train_predict)))

# Test data RMSE
print(math.sqrt(mean_squared_error(y_test, test_predict)))

plt.figure(figsize=(16, 8))
look_back = 100
train_predict_plot = np.empty_like(data)
train_predict_plot[:, :] = np.nan
train_predict_plot[look_back:len(train_predict) + look_back, :] = train_predict
test_predict_plot = np.empty_like(data)
test_predict_plot[:, :] = np.nan
test_predict_plot[len(train_predict) + (look_back*2) + 1:len(data) - 1, :] = test_predict
plt.plot(scaler.inverse_transform(data), label='Original Data', color='black', linewidth=1.5)
plt.plot(train_predict_plot, label='Training Prediction', color='green', linewidth=1.5)
plt.plot(test_predict_plot, label='Testing Prediction', color='red', linewidth=1.5)
plt.grid(True, linestyle='--', alpha=0.5, color='gray', linewidth=1.5)
plt.legend()
plt.show()


### Prediction for future 30 days

# Create input data for future days
x_input = test_data[-time_steps:].reshape((1, time_steps, 1))

# Generate predictions for future days
future_predictions = []
for i in range(30):
    future_prediction = model.predict(x_input, verbose=0)
    future_predictions.append(future_prediction[0, 0])
    x_input = np.append(x_input[:, 1:, :], future_prediction.reshape(1, 1, 1), axis=1)

# Inverse scaling of predictions
future_predictions = scaler.inverse_transform(np.array(future_predictions).reshape(-1, 1))

# Generate dates for future days
last_date = stock_data['Date'].values[-1]
future_dates = pd.date_range(start=last_date, periods=31)[1:]

# Plot predicted values for future days
plt.figure(figsize=(16, 8))
plt.plot(stock_data['Date'], stock_data['Close'], label='Historical Data', color='black', linewidth=1.0)
plt.plot(future_dates, future_predictions, label='Future Predictions', color='darkred', linewidth=1.0)
plt.grid(True, linestyle='--', alpha=0.5, color='gray', linewidth=1.0)
plt.xlabel('Date', fontsize=14)
plt.ylabel('Close Price USD ($)', fontsize=14)
plt.title('Future Price Predictions', fontsize=16)
plt.legend(fontsize=12)
plt.grid(True, linestyle='--', alpha=0.5)
plt.xticks(fontsize=12, rotation=45)
plt.yticks(fontsize=12)
plt.tight_layout()
plt.show()

# Plot predicted values for future days (last 30 days)
plt.figure(figsize=(16, 8))
plt.plot(stock_data['Date'][-30:], stock_data['Close'][-30:], label='Historical Data', color='black', linewidth=1.0)
plt.plot(future_dates[-30:], future_predictions[-30:], label='Future Predictions', color='darkred', linewidth=1.0)
plt.grid(True, linestyle='--', alpha=0.5, color='gray', linewidth=1.0)
plt.xlabel('Date', fontsize=14)
plt.ylabel('Close Price USD ($)', fontsize=14)
plt.title('Future Price Predictions (Last 30 Days)', fontsize=16)
plt.legend(fontsize=12)
plt.grid(True, linestyle='--', alpha=0.5)
plt.xticks(fontsize=12, rotation=45)
plt.yticks(fontsize=12)
plt.tight_layout()
plt.show()










