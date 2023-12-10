class RSSIKalmanFilter {
  late double currentRSSI; // Current RSSI estimate
  late double covarianceMatrix; // Covariance matrix
  late double stateTransition; // State transition matrix
  late double measurementFunction; // Measurement function
  late double processNoiseCovariance; // Process noise covariance
  late double measurementNoise; // Measurement noise

  RSSIKalmanFilter() {
    // Initialize Kalman filter parameters for RSSI filtering
    currentRSSI = 0; // Initial RSSI estimate
    covarianceMatrix = 1; // Initial covariance
    stateTransition = 1; // State transition (assuming constant RSSI)
    measurementFunction = 1; // Measurement function (RSSI directly observed)
    processNoiseCovariance = 0.1; // Process noise covariance
    measurementNoise = 5; // Measurement noise
  }

  void predict() {
    // Prediction step
    currentRSSI = stateTransition * currentRSSI;
    covarianceMatrix = stateTransition * covarianceMatrix * stateTransition +
        processNoiseCovariance;
  }

  void update(double rssiMeasurement) {
    // Update step
    final double measurementResidual =
        rssiMeasurement - measurementFunction * currentRSSI;
    final double residualCovariance =
        measurementFunction * covarianceMatrix * measurementFunction +
            measurementNoise;

    final double kalmanGain =
        covarianceMatrix * measurementFunction / residualCovariance;

    currentRSSI = currentRSSI + kalmanGain * measurementResidual;
    covarianceMatrix =
        (1 - kalmanGain * measurementFunction) * covarianceMatrix;
  }

  List<double> filterRSSI(List<double> rssiMeasurements) {
    // Kalman filter loop for RSSI data
    final List<double> filteredRSSI = [];

    for (final rssiMeasurement in rssiMeasurements) {
      predict();
      update(rssiMeasurement);
      filteredRSSI.add(currentRSSI);
    }

    return filteredRSSI;
  }
}


  // // Example usage for filtering RSSI data
  // final RSSIKalmanFilter rssiKalmanFilter = RSSIKalmanFilter();

  // // Simulated RSSI measurements with noise
  // final List<double> rssiMeasurements = [-50, -52, -48, -55, -53];

  // // Filter the RSSI data
  // final List<double> filteredRSSI =
  //     rssiKalmanFilter.filterRSSI(rssiMeasurements);

  // // Display the filtered RSSI data
  // print("Original RSSI Measurements: $rssiMeasurements");
  // print("Filtered RSSI Data: $filteredRSSI");
