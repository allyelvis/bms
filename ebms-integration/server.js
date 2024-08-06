const express = require('express');
const bodyParser = require('body-parser');

const loginRoute = require('./routes/login');
const getInvoiceRoute = require('./routes/getInvoice');
const addInvoiceRoute = require('./routes/addInvoice');
const checkTINRoute = require('./routes/checkTIN');

const app = express();
const port = 3000;

app.use(bodyParser.json());

app.use('/login', loginRoute);
app.use('/getInvoice', getInvoiceRoute);
app.use('/addInvoice', addInvoiceRoute);
app.use('/checkTIN', checkTINRoute);

app.listen(port, () => {
  console.log(`Server running on port ${port}`);
});
