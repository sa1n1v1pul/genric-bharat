const functions = require('firebase-functions');
const admin = require("firebase-admin");

// Initialize the app if it hasn't been initialized yet
if (!admin.apps.length) {
  admin.initializeApp();
}

exports.updateAuthConfig = functions.https.onRequest(async (req, res) => {
  try {
    const projectConfig = {
      recaptchaConfig: {  // Changed to recaptchaConfig instead of recaptchaEnterpriseConfig
        siteKey: "6LemjqQqAAAAALfZ_NJuTEwysxGwSWEBoBkhNiIQ",
        enableInAllowlistedDomains: true
      },
      smsRegionConfig: {
        allowlistedRegions: ["IN"],
        prohibitedRegions: []
      },
      mfa: {
        state: "DISABLED"
      },
      smsAuthOptions: {
        attemptLimitConfig: {
          maxAllowedAttempts: 5,
          resetInterval: "1h"
        }
      }
    };
    
    await admin.auth().updateProjectConfig(projectConfig);
    res.json({
      success: true, 
      message: "Auth config updated successfully",
      config: projectConfig
    });
  } catch (error) {
    console.error("Error updating auth config:", error);
    res.status(500).json({
      success: false,
      error: error.message,
      stack: process.env.NODE_ENV === 'development' ? error.stack : undefined
    });
  }
});