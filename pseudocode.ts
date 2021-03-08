function onSettingsChange(before, after) {
    if (!after.hasRemindersOn || after.reminderTime == null || before.hasRemindersOn) {
        return;
    }
    scheduleReminderAsTask(after.user, after.reminderTime);
}

function scheduleReminderAsTask(user, reminderTime) {
    // schedule a task with google's task sdk 
    payload = { userId: user.id }
    timeInMillis = nextReminderTime(reminderTime, user.lastKnownTimeZone)
    functionToCall = 'sendReminderNotification'
    scheduleTask(payload, timeInMillis, functionToCall);
}

// register this as a secure http function
function sendReminderNotification(request) {
    // verify authentication (must be service user)
    user = getUserDocFromFirestore(request.payload.user);
    if (!user.hasReminderOn) {
        // user must have turned notifications off at some point
        return;
    }

    // schedule the next reminder
    scheduleReminderAsTask(user, reminderTime);

    if (!isApproximatelyEqualToCurrentTimeOfDay(user.reminderTime, user.timeZone)) {
        // user must have changed their reminder time. 
        // no worries, we've already scheduled one for the updated time
        return;
    }
    // use FCM to send notification
}



function nextReminderTime(currentTime: millis, reminderTime: TimeOfDay, timezone: TimeZone) {
    // normalize time of day to utc
    // do some math to determine the millisecondsSinceEpoch
    // of the next occurunce of that time of day
    // find a library for this!

}

expect(nextReminderTime(05:30 3/6/2021 UTC, 13:30, UTC).toEqual(13:30 3/6/2020 UTC)
expect(nextReminderTime(14:30 3/6/2021 UTC, 13:30, UTC).toEqual(13:30 3/7/2020 UTC)
expect(nextReminderTime(12:00 3/6/2021 UTC, 13:30, NYC (UTC-5)).toEqual(18:30 3/6/2020 UTC)
