const admin = require("firebase-admin");
const {onRequest} = require("firebase-functions/v2/https");
const {initializeApp} = require("firebase-admin/app");

// Initialize the app if it hasn't been initialized yet
if (!admin.apps.length) {
  initializeApp();
}

exports.updateAuthConfig = onRequest(async (req, res) => {
  try {
    // Update the authentication configuration
    const config = {
      phoneNumber: {
        enableTesting: true,
        testPhoneNumbers: {
          "+916666666666": "123456",  // Add test phone numbers if needed
        }
      }
    };

    await admin.auth().updateConfig(config);

    // Also update the project configuration
    const projectConfig = {
      recaptchaEnforcementState: "OFF"
    };
    
    await admin.auth().updateProjectConfig(projectConfig);

    res.json({
      success: true, 
      message: "Auth config updated successfully",
      config: config,
      projectConfig: projectConfig
    });
  } catch (error) {
    console.error("Error updating auth config:", error);
    res.status(500).json({
      success: false, 
      error: error.message,
      stack: error.stack
    });
  }
});