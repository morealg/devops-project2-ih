import { ApplicationInsights } from '@microsoft/applicationinsights-web'

const connectionString = import.meta.env.VITE_APPINSIGHTS_CONNECTION_STRING

if (!connectionString) {
  console.warn('[Telemetry] VITE_APPINSIGHTS_CONNECTION_STRING is not set. Telemetry will be disabled.')
}

export const appInsights = new ApplicationInsights({
  config: {
    connectionString: connectionString ?? '',
    enableAutoRouteTracking: true,
    autoTrackPageVisitTime: true,
    enableCorsCorrelation: true,
    enableRequestHeaderTracking: true,
    enableResponseHeaderTracking: true,
    disableTelemetry: !connectionString,
    samplingPercentage: 100,
  }
})

if (connectionString) {
  appInsights.loadAppInsights()
  appInsights.trackPageView()
}
