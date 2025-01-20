const functions = require("firebase-functions");
const admin = require("firebase-admin");

admin.initializeApp();

exports.sendRecrutementNotification = functions.firestore
    .document("Projets/{projectId}/Candidats/{freelanceId}")
    .onUpdate((change, context) => {
      const beforeData = change.before.data();
      const afterData = change.after.data();

      // Vérifier si le freelance a été recruté
      if (afterData.recruté === true && beforeData.recruté !== true) {
        const projectId = context.params.projectId;
        const freelanceId = context.params.freelanceId;

        // Récupérer le token de notification du freelance
        return admin
            .firestore()
            .doc(`Users/${freelanceId}`)
            .get()
            .then((freelanceDoc) => {
              const token = freelanceDoc.get("notificationToken");

              if (token) {
                // Récupérer le nom du projet
                return admin
                    .firestore()
                    .doc(`Projets/${projectId}`)
                    .get()
                    .then((projectDoc) => {
                      const projectName = projectDoc.get("titre");

                      // Envoyer la notification push
                      const message = {
                        notification: {
                          title: "Félicitations !",
                          body: `Vous avez été recruté pour "${projectName}"!`,
                        },
                        token: token,
                      };

                      return admin
                          .messaging()
                          .send(message)
                          .then((response) => {
                            console.log("Successfully sent message:", response);
                            return {success: true};
                          })
                          .catch((error) => {
                            console.error("Error sending message:", error);
                            return {success: false, error: error.message};
                          });
                    });
              } else {
                console.error(
                    "Token de notification non trouvé pour le freelance.",
                );
                return {success: false};
              }
            });
      } else {
        console.log("Le freelance n'a pas été recruté.");
        return {success: false};
      }
    });
