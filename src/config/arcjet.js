import arcjet, { shield, detectBot, slidingWindow } from '@arcjet/node';

// Configure Arcjet based on environment
const isProduction = process.env.NODE_ENV === 'production';
const arcjetMode = isProduction ? 'LIVE' : 'DRY_RUN';

const aj = arcjet({
  // Get your site key from https://app.arcjet.com and set it as an environment
  // variable rather than hard coding.
  key: process.env.ARCJET_KEY,
  rules: [
    // Shield protects your app from common attacks e.g. SQL injection
    shield({ mode: arcjetMode }),
    // Create a bot detection rule
    detectBot({
      mode: arcjetMode, // In development: DRY_RUN (logs only), Production: LIVE (blocks)
      // Block all bots except the following
      allow: [
        'CATEGORY:SEARCH_ENGINE', // Google, Bing, etc
        'CATEGORY:PREVIEW', // Link previews e.g. Slack, Discord
        ...(isProduction ? [] : ['*']), // In development, allow all bots
      ],
    }),
    slidingWindow({
      mode: arcjetMode,
      interval: '2s',
      max: isProduction ? 5 : 1000, // Higher limit in development
    }),
  ],
});

export default aj;
