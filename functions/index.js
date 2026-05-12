const { onSchedule } = require("firebase-functions/v2/scheduler");
const { initializeApp } = require("firebase-admin/app");
const { getMessaging } = require("firebase-admin/messaging");

initializeApp();

// Envía la notificación de receta del día todos los días a las 8:00 AM (hora Colombia/Venezuela)
exports.sendDailyRecipeNotification = onSchedule(
  {
    schedule: "0 8 * * *",
    timeZone: "America/Bogota",
    region: "us-central1",
  },
  async () => {
    await getMessaging().send({
      topic: "receta_del_dia",
      notification: {
        title: "🥤 Tu batido del día",
        body: "Abre la app y prepara tu batido saludable de hoy.",
      },
      android: {
        priority: "high",
        notification: {
          channelId: "receta_diaria",
          sound: "default",
        },
      },
    });
  }
);
