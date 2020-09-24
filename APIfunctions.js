const functions = require('firebase-functions');
const express = require('express');
const cors = require('cors');
//const { admin } = require('firebase-admin/lib/database');

const admin = require('firebase-admin');
const { snapshotConstructor } = require('firebase-functions/lib/providers/firestore');
admin.initializeApp();
const app = express();

app.get('/', async (req, res) => {
    const snapshot = await admin.firestore().collection('users').get();

    let users = [];
    snapshot.forEach(doc => {
      let id = doc.id;
      let data = doc.data();

      users.push({id, ...data});
    })

    res.status(200).send(JSON.stringify(users));
    const user = req.body;
});

app.get("/:id", async (req, res) => {
    const snapshot = await admin.firestore().collection('users').doc(req.params.id).get();
    const userId = snapshot.id;
    const userData = snapshot.data();
    res.status(200).send(JSON.stringify({id: userId, ...userData}));
});

app.post('/', async (req, res) => {
    const user = req.body;

    const result = await admin.firestore().collection('users').add(user);

    res.status(201).send();
});

app.put("/:id", async (req, res) => {
    const body = req.body;

    const result = await admin.firestore().collection('users').doc(req.params.id).update(body);
});

app.delete("/:id", async (req, res) => {
    await admin.firestore().collection("users").doc(req.params.id).delete();

    res.status(200).send();
});

exports.user = functions.https.onRequest(app);
// // Create and Deploy Your First Cloud Functions
// // https://firebase.google.com/docs/functions/write-firebase-functions
