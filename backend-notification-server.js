const express = require("express");
const cors = require("cors");
const admin = require("firebase-admin");
const app = express();
app.use(cors());
app.use(express.json());

// 🔐 Read Firebase key from environment variable
const serviceAccount = JSON.parse(process.env.FIREBASE_KEY);
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
});

app.post("/send", async (req, res) => {
  console.log("🔥 /send endpoint triggered at:", new Date().toISOString());
  try {
    const { tokens, title, body, url, sound } = req.body;
    if (!tokens || tokens.length === 0) {
      return res.status(400).send("No tokens provided");
    }

    console.log("Sending notification to:", tokens.length, "devices");
    console.log("Sound:", sound || "default");

    // ✅ FIXED MESSAGE (NO top-level notification)
    const message = {
      tokens: tokens,
      // 🔥 DATA ONLY (Flutter controls behavior)
      data: {
        title: title || "",
        body: body || "",
        url: url || "",
        sound: sound || "default", // 🔊 Add sound parameter
      },
      // 🌐 Web-specific settings
      webpush: {
        notification: {
          title: title || "",
          body: body || "",
          icon: "https://res.cloudinary.com/dxdskr55w/image/upload/v1771559986/Icon-192_irxg6z.png",
          sound: sound || "default", // 🔊 Add sound to webpush
        },
        fcmOptions: {
          link: url || "https://wash-ko-lang-sit.web.app",
        },
      },
    };

    const response = await admin.messaging().sendEachForMulticast(message);
    console.log("Success:", response.successCount);
    console.log("Failures:", response.failureCount);

    // 🧹 Clean invalid tokens
    if (response.failureCount > 0) {
      const invalidTokens = [];
      response.responses.forEach((resp, idx) => {
        if (!resp.success) {
          console.log("Invalid token:", tokens[idx]);
          invalidTokens.push(tokens[idx]);
        }
      });
      console.log("Invalid tokens to remove:", invalidTokens);
      // Optional: remove invalid tokens from Firestore here
    }

    res.status(200).send("Notification sent");
  } catch (error) {
    console.error("Push error:", error);
    res.status(500).send("Error sending notification");
  }
});

app.get("/", (req, res) => {
  res.send("Push server running 🚀");
});

app.listen(process.env.PORT || 3000, () => {
  console.log("Server running...");
});
