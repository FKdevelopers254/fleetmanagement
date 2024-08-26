import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import StandardScaler
from sklearn.ensemble import RandomForestRegressor
import joblib

# Assuming data is fetched and converted to DataFrame
maintenance_data = pd.read_csv('maintenance.dart')
fuel_data = pd.read_csv('fuel.dart')
trip_data = pd.read_csv('trip.dart')
routes_data = pd.read_csv('routes.dart')

# Merge dataframes on vehicleid
merged_data = maintenance_data.merge(fuel_data, on='vehicleid')
merged_data = merged_data.merge(trip_data, on='vehicleid')
merged_data = merged_data.merge(routes_data, on='vehicleid')

# Feature selection and preprocessing
features = merged_data[['amount', 'fueltype', 'cost', 'routeid']]
labels = merged_data['maintenance_cost']

X_train, X_test, y_train, y_test = train_test_split(features, labels, test_size=0.2)
scaler = StandardScaler().fit(X_train)
X_train_scaled = scaler.transform(X_train)
X_test_scaled = scaler.transform(X_test)

# Train the model
model = RandomForestRegressor()
model.fit(X_train_scaled, y_train)

# Save the model
joblib.dump(model, 'maintenance_model.pkl')
