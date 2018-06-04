'use strict';

const functions = require('firebase-functions');
const admin = require('firebase-admin');
const nodemailer = require('nodemailer');

admin.initializeApp();
var db = admin.database();

const gmailEmail = functions.config().gmail.email;
const gmailPassword = functions.config().gmail.password;
const mailTransport = nodemailer.createTransport({
  service: 'Gmail',
  auth: {
    user: gmailEmail,
    pass: gmailPassword,
  },
});
exports.sendFileReportEmail = functions.database.ref('/filereport/{id}').onCreate((snapshot, context) => {
    var dataObject = Object.keys(snapshot.val());
    var sessionId = dataObject[0];
    var reporteeId = snapshot.child("/" + sessionId + "/reportee").val();
    var type = snapshot.child("/" + sessionId + "/type").val();
    var reason = snapshot.child("/" + sessionId + "/reason").val();
    var id = context.params.id;
    const records = [
      db.ref("/account/" + id).once("value"),
      db.ref("/student-info/" + id).once("value"),
      db.ref("/account/" + reporteeId).once("value"),
      db.ref("/student-info/" + reporteeId).once("value"),
      db.ref("/sessions/" + sessionId).once("value"),
      db.ref("filereport/" + id).remove(),
    ]
    return Promise.all(records).then(snapshots => {
      const reporter = generateUserReport(snapshots[0].val(), snapshots[1].val(), context.params.id);
      const reportee = generateUserReport(snapshots[2].val(), snapshots[3].val(), reporteeId);
      const session  = generateSessionData(snapshots[4].val(), type, reason, sessionId);
      return sendReportEmail(reporter, reportee, session, id);
    });
});
// [END onWrite]

//generates a stringified version of the user
function generateUserReport(account, student, id) {
  return "Name: " + student['nm'] + ", " + account['bd'] +  ", " + account['age']
   + "\n started QuickTutor: " + account['init']
   + "\n Student Rating: " + student['r']
   + "\n student bio: " + student['bio']
   + "\n School: " + student['sch']
   + "\n Id: " + id
}
//generates a stringified version of the session
function generateSessionData(session, type, reason, id) {
  return "\nSession id: " + id + " date: " + session['date'] + " StartTime: " + session['startTime'] + " EndTime: " + session['endTime']
  + "\n Subject: " + session['subject'] + " status: " + session['status'] + " type: " + session['type']
  + "\n receiver: " + session['receiverId']
  + "\n sender: " + session['senderId']
  + "\n price: " + session['price']
  + "\n type: " + type
  + "\n Reason for report: " + reason
}
//sends an email to QuickTutor customer service.
function sendReportEmail(reporter, reportee, session, type) {
  const mailOptions = {
    from: 'QuickTutor FileReport <noreply@firebase.com>',
    to: 'customerservice@quicktutor.com',
    subject: "QuickTutor - FileReport - " + type,
    text: "Reporter: " + reporter + "\n\n\nReportee: " + reportee + "\n\n\nSession Details: " + session,
  };
  mailOptions.subject = `QuickTutor - File Report`;
  return mailTransport.sendMail(mailOptions).then(() => {
    return console.log("File report email sent.")
  });
}
