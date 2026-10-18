import type { CapacitorConfig } from '@capacitor/cli';

const config: CapacitorConfig = {
  appId: 'app.pianorush.game',
  appName: 'Piano Rush',
  webDir: 'www',
  android: {
    backgroundColor: '#0D0524',
    // Android 15+ forces edge-to-edge; this keeps the HUD clear of the status bar
    adjustMarginsForEdgeToEdge: 'auto',
    webContentsDebuggingEnabled: false,
    allowMixedContent: false
  },
  server: { androidScheme: 'https' }
};

export default config;
