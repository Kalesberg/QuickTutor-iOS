const functions = require('firebase-functions');
const admin = require('firebase-admin');
admin.initializeApp();

const sgMail = require('@sendgrid/mail');
sgMail.setApiKey(functions.config().sendgrid.key);
sgMail.setSubstitutionWrappers("{{", "}}");


//sends email to user that filed report.
exports.sendReceivedReportEmail = functions.database.ref('filereport/{uid}/{reportId}').onWrite((change, context) => {
  const report = change.after.val();
  const tutorAdditionalMessage = "QuickTutor possesses strict safety guidelines and has a zero-tolerance policy for tutors who are unprofessional with their learners. We as a team, are committed to ensuring and policing the quality of the platform for both our learners and tutors.";
  const learnerAdditionalMessage = "QuickTutor possesses strict safety guidelines and has a zero-tolerance policy for learners who are unprofessional with their tutors. We as a team, are committed to ensuring and policing the quality of the platform for both our learners and tutors.";
  const lowRiskReports = ['My Tutor Cancelled','My Tutor Was Late','My Learner Cancelled','My Learner Was Late'];

  var additionalMessage = ""

  if (lowRiskReports.indexOf(report.type) < 0) {
    additionalMessage = ((report.userType === 'learner') ? tutorAdditionalMessage : learnerAdditionalMessage);
  }

  const msg = {
    from: "support@quicktutor.com",
    templateId: "d-1be5730b260c4fb19f3458c133f6b6ea",
    personalizations: [
      {
        to: [{
            email: report.email,
          }],
        dynamic_template_data: {
          name: report.name,
          subject: report.type,
          message : additionalMessage,
        },
      }],
    };
  return sgMail.send(msg).catch(err => console.error(err.message));
});

//sends email to support@quicktutor.com containing the details of what happened.
exports.sendSessionDetails = functions.database.ref('filereport/{uid}/{reportId}').onWrite((change, context) => {
  const reporterId = context.params.uid;
  const sessionId = context.params.reportId;
  const report = change.after.val();
  const reporteeId  = report.reportee;

  var promises = [
    getsession(sessionId),
    getAccountInfo(reporterId),
    getStudentInfo(reporterId),
    getTutorInfo(reporterId),
    getAccountInfo(reporteeId),
    getStudentInfo(reporteeId),
    getTutorInfo(reporteeId),
  ];
  return Promise.all(promises).then(results => {
    var session = results[0];
    var rAccount = results[1];
    var rLearner = results[2];
    var rTutor = results[3];

    var eAccount = results[4];
    var eLearner = results[5];
    var eTutor = results[6];
    const msg = {
      from: "support@quicktutor.com",
      templateId: "d-05dc6ed181714db58e6fc2227ac2de88",
      personalizations: [
        {
          to: [{
              email: report.email,
            }],
          dynamic_template_data: {
            //reporter Account details.
            rAge: rAccount.age,
            rEmail: rAccount.em,
            rBirthday: rAccount.bd,
            rStarted: new Date(rAccount.init * 1000).toGMTString(),
            rPhone: rAccount.phn,
            rOnline: new Date(eAccount.online * 1000).toGMTString(),

            //reporter Learner details.
            rName: rLearner.nm,
            rCustomerId: rLearner.cus,
            rRating: rLearner.r,
            rSchool: rLearner.sch,

            //reporter Tutor details
            rAccountId: rTutor.act,
            rUsername: rTutor.usr,

            //reportee Account details.
            eAge: eAccount.age,
            eEmail: eAccount.em,
            eBirthday: eAccount.bd,
            eStarted: new Date(eAccount.init * 1000).toGMTString(),
            ePhone: eAccount.phn,
            eOnline: new Date(eAccount.online * 1000).toGMTString(),

            //reportee Learner details.
            eName: eLearner.nm,
            eCustomerId: eLearner.cus,
            eRating: eLearner.r,
            eSchool: eLearner.sch,

            //reportee Tutor details
            eAccountId: eTutor.act,
            eUsername: eTutor.usr,
            //session Details
            date: new Date(session.date * 1000).toGMTString(),
            ended: new Date(session.endtime * 1000).toGMTString(),
            started: new Date(session.startTime * 1000).toGMTString(),
            type: session.type,
            expiration: new Date(session.expiration * 1000).toGMTString(),
            price: session.price,
            subject: session.subject,
          },
        }],
      };
    return sgMail.send(msg).catch(err => console.error(err.message));
  });
});
function getAccountInfo(id) {
  return admin.database().ref('account/' + id).once('value').then(snapshot => {
    return snapshot.val();
  });
}
function getsession(id) {
  return admin.database().ref('sessions/' + id).once('value').then(snapshot => {
    return snapshot.val();
  });
}
function getStudentInfo(id) {
  return admin.database().ref('student-info/' + id).once('value').then(snapshot => {
    return snapshot.val();
  });
}
function getTutorInfo(id) {
  return admin.database().ref('tutor-info/' + id).once('value').then(snapshot => {
    return snapshot.val();
  });
}
