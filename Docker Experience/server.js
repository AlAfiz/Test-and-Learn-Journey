var express = require('express');
var path = require('path');
var MongoClient = require('mongodb').MongoClient;
var bodyParser = require('body-parser');
var app = express();

app.use(bodyParser.urlencoded({
    extended: true
}));
app.use(bodyParser.json());

app.use(express.static(__dirname));

app.get('/', function (req, res) {
    res.sendFile(path.join(__dirname, "index.html"));
});

app.get('/get-profile', function (req, res) {
    var response = res;

    // Connect to the db using IPv4 to avoid Windows lag
    MongoClient.connect('mongodb://admin:password@127.0.0.1:27017?authSource=admin&serverSelectionTimeoutMS=5000', function(err, client) {
        if (err) {
            console.error('MongoDB connection error:', err);
            response.status(500).send({ error: 'Database connection failed' });
            return;
        }

        var db = client.db('user-account');
        var query = { userid: 1 };
        db.collection('users').findOne(query, function(err, result) {
            if (err) {
                console.error('Database query error:', err);
                response.status(500).send({ error: 'Query failed' });
                client.close();
                return;
            }
            client.close();
            response.send(result);
        });
    });
});

app.post('/update-profile', function (req, res) {
    var userObj = req.body;
    var response = res;

    console.log('connecting to the db....');
    console.log('Received data:', userObj);

    // Connect to the db using IPv4
    MongoClient.connect('mongodb://admin:password@127.0.0.1:27017?authSource=admin&serverSelectionTimeoutMS=5000', function(err, client) {
        if (err) {
            console.error('MongoDB connection error:', err);
            response.status(500).send({ error: 'Database connection failed', details: err.message });
            return;
        }

        console.log('successfully connected to the user-account db');

        var db = client.db('user-account');
        userObj['userid'] = 1;
        var query = { userid: 1 };
        var newValues = { $set: userObj };

        // upsert: true means "Update if exists, Insert if it doesn't"
        db.collection('users').updateOne(query, newValues, {upsert: true}, function (err, result) {
            if (err) {
                console.error('Database update error:', err);
                response.status(500).send({ error: 'Update failed' });
                client.close();
                return;
            }
            console.log('successfully updated or inserted');
            client.close();
            response.send(userObj);
        });
    });
});

app.listen(3000, function () {
    console.log("app listening on port 3000!");
});