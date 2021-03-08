import * as functions from "firebase-functions";

const USER_DOCUMENT = "/users/{userId}";
const HAS_REMINDER_ON_KEY = "has_reminder_on";
const REMINDER_TIME_HOUR_KEY = "reminder_time_hour";
const REMINDER_TIME_MINUTE_KEY = "reminder_time_minute";

exports.onSettingsChange = functions.firestore
    .document(USER_DOCUMENT)
    .onWrite((change: any, context: any) => {
      const document = change.after.exists ? change.after.data() : null;
      const oldDocument = change.before.exists ? change.before.data() : null;

      if (!shouldScheduleReminder(document, oldDocument)) {
        return;
      }
      scheduleReminderTask(document);
    });

function shouldScheduleReminder(user: any, oldUser: any) {
  return (
    user != null &&
        user[HAS_REMINDER_ON_KEY] &&
        !oldUser[HAS_REMINDER_ON_KEY]
  );
}

function scheduleReminderTask(document: any) {
  const reminderHour = document[REMINDER_TIME_HOUR_KEY];
  const reminderMinute = document[REMINDER_TIME_MINUTE_KEY];

  console.log({reminderHour, reminderMinute});
}
