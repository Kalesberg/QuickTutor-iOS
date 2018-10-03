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

exports.sendMessageNotification = functions.database.ref('/messages/{messageId}').onCreate((snap, context) => {
  const data = snap.val();
  const receiverId = data.receiverId;
  const senderId = data.senderId;
  const receiverAccountType = data.receiverAccountType;

  const senderAccountType = (receiverAccountType === 'learner' ? 'tutor' : 'learner');

  let text = data.text;
  let sessionRequestId = data.sessionRequestId;
  let titleCompletion = ' messaged you.';

  if (text === undefined && sessionRequestId === undefined) {
    text = "Attachment: 1 image";
    titleCompletion = ' sent an image.'
  } else if (text === undefined) {
    text = "Session Request";
    titleCompletion = ' would like to have a session.'
  }

  console.log('Message added in database');
  

  return Promise.all([getFcmTokenForUid(receiverId), getUsernameForUid(senderId)]).then(results => {
    const fcmToken = results[0];
    const senderUsername = results[1];
    console.log('Sending notification');
    
    const title = senderUsername + titleCompletion;
    const data = {
      category: 'messages',
      identifier: 'textMessage',
      receiverId: receiverId,
      senderId: senderId,
      receiverAccountType: receiverAccountType,
      senderAccountType: senderAccountType
    }

    return sendNotificationTo(fcmToken, title, text, data);
  }).then((error) => {
    console.log(error);
    return error;
  });
});

function getUsernameForUid(uid) {
  return new Promise(((resolve, reject) => {
    admin.database().ref('student-info/' + uid + '/nm').once('value', (snapshot) => {
      let username = snapshot.val()
      if (username) {
        let lastInitialIndex = username.search(' ') + 2;
        let formattedName = username.slice(0, lastInitialIndex) + '.';
        resolve(formattedName);
      } else {
        reject(new Error('Could not get username for uid: ', uid));
      }
    });
  }));
}

function getFcmTokenForUid(uid) {
  return new Promise(((resolve, reject) => {
    admin.database().ref('account/' + uid + '/fcmToken').once('value', (snapshot) => {
      let fcmToken = snapshot.val()
      if (fcmToken) {
        resolve(fcmToken);
      } else {
        reject(new Error('Could not get fcm token.'));
      }
    });
  }));
}

function sendNotificationTo(fcmToken, title, body, data) {
  const payload = createNotificationPayload(title, body, data);

  return admin.messaging().sendToDevice(fcmToken, payload)
    .then((response) => {
      console.log('Successfully sent message');
      return 'successful';
    })
    .catch((error) => {
      console.log('Error sending message:', error);
    });
}

function createNotificationPayload(title, body, data) {
  return {
    notification: {
      title: title,
      sound: 'qtNotificationPop.aiff',
      body: body
    },
    data: data
  };
}

exports.sendConnectionRequestNotification = functions.database.ref('/connectionRequests/{receiverId}/{senderId}').onCreate((snap, context) => {
  const receiverId = context.params.receiverId;
  const senderId = context.params.senderId;

  return Promise.all([getFcmTokenForUid(receiverId), getUsernameForUid(senderId)]).then(results => {
    const fcmToken = results[0];
    const senderUsername = results[1];

    const title = `${senderUsername} would like to connect.`
    const data = {
      'receiverAccountType' : 'tutor'
    }

    return sendNotificationTo(fcmToken, title, null, data);
  });
});

exports.sendConnectionRequestAcceptedNotification = functions.database.ref('/connections/{receiverId}/{senderId}').onCreate((snap, context) => {
  const data = snap.val();
  const receiverId = context.params.receiverId;
  const senderId = context.params.senderId;

  return Promise.all([getFcmTokenForUid(receiverId), getUsernameForUid(senderId)]).then(results => {
    const fcmToken = results[0];
    const senderUsername = results[1];

    const title = `${senderUsername} accepted your connection request.`
    const data = {
      'receiverAccountType' : 'learner'
    }

    return sendNotificationTo(fcmToken, title, null, data);
  });
});

function getSessionById(sessionId) {
    return admin.database().ref(`sessions/${sessionId}`).once('value').then((snapshot) => {
        return snapshot.val();
    });
}

exports.sendSessionAcceptedNotification = functions.database.ref('/userSessions/{receiverId}/learner/{sessionId}').onCreate((snap, context) => {
  const data = snap.val();
  const receiverId = context.params.receiverId;
  const sessionId = context.params.sessionId;
  
  console.log(`ReceieverId: ${receiverId}`);
  
  return getSessionById(sessionId).then((session) => {
    const senderId = session.senderId;
    console.log(`SenderId: ${senderId}`);
    return Promise.all([getFcmTokenForUid(receiverId), getUsernameForUid(senderId)]).then(results => {
      const fcmToken = results[0];
      const senderUsername = results[1];
  
      const title = 'Session Request Accepted'
      const body = `${senderUsername} accepted your session request.`
  
      return sendNotificationTo(fcmToken, title, body, {});
    }).catch((error) => {
      console.log(error);
    });
  });

});

exports.sendSessionCancelNotification = functions.database.ref('/sessionCancels/{receiverId}/{cancelledById}').onCreate((snap, context) => {
  const data = snap.val();
  const receiverId = context.params.receiverId;
  const cancelledById = context.params.cancelledById;

  return Promise.all([getFcmTokenForUid(receiverId), getUsernameForUid(cancelledById)]).then(results => {
    const fcmToken = results[0];
    const senderUsername = results[1];

    const title = `Your session with ${senderUsername} has been cancelled.`

    return sendNotificationTo(fcmToken, title);
  });
});

// exports.sendManualStartNotification = functions.database.ref('/sessionStarts/{userId}/{sessionId}').onCreate((snap, context) => {
//   const userId = context.params.userId;
//   const sessionId = context.params.sessionId;  
//   console.log(`User id is ${userId}`);
  
//   return Promise.all([getSessionById(sessionId), getFcmTokenForUid(userId), getUsernameForUid(userId)]).then(results => {
//     const session = results[0];
//     const fcmToken = results[1];
//     const senderUsername = results[2];
    
//     const title = 'Session Starting Early';
//     const text = 'Accept or deny the early start.'
//     const data =  {
//       senderId: userId,
//       receiverAccountType: 'tutor'
//     }
//     console.log('Sending session start notification');
//     return sendNotificationTo(fcmToken, title, text, data);
//   }).then((error) => {
//     console.log(error);
//     return error;
//   });
// });